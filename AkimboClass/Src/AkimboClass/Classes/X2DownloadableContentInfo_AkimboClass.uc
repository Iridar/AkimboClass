//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AkimboClass.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AkimboClass extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}
/*
static function bool AbilityTagExpandHandler(string InString, out string OutString)	//I don't even know what this does, TBH. Copypasted it from New Skirmisher mod
{
	local name Type;

	Type = name(InString);
	switch (Type)
	{
		case 'GUNKATACHARGE_MAX':
			OutString = string(class'X2Ability_AkimboAbilitySet'.default.GUNKATACHARGE_MAX);
			break;  
		default:
            return false;
	}
	return true;
}*/

static event OnPostTemplatesCreated()
{
	AddSoldierIntroMap();
	PatchPistolAbilityTemplates();
}

static event AddSoldierIntroMap()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2FacilityTemplate FacilityTemplate;
	local AuxMapInfo MapInfo;
	local array<X2DataTemplate> AllHangarTemplates;
	local X2DataTemplate Template;
 	// Grab manager
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
 	// Find all armory/hangar templates
	StratMgr.FindDataTemplateAllDifficulties('Hangar', AllHangarTemplates);
 	foreach AllHangarTemplates(Template)
	{
		// Add Aux Maps to the template
		FacilityTemplate = X2FacilityTemplate(Template);
		MapInfo.MapName = "CIN_SoldierIntros_Akimbo";
		MapInfo.InitiallyVisible = true;
		FacilityTemplate.AuxMaps.AddItem(MapInfo);
	}
}

static function PatchPistolAbilityTemplates()
{
	local X2AbilityTemplateManager			AbilityTemplateManager;
	local X2AbilityTemplate					Ability;
	local int i;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	//	Patch Fan Fire for RPGO so it works with Bullet Time.
	Ability = AbilityTemplateManager.FindAbilityTemplate('FanFire');
	if (Ability != none)
	{
		for (i = 0; i < Ability.AbilityCosts.Length; i++)
		{
			if ( X2AbilityCost_ActionPoints(Ability.AbilityCosts[i]) != none )
			{
				X2AbilityCost_ActionPoints(Ability.AbilityCosts[i]).DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
				//break; //	don't exit in case there are several Action Costs
			}
		}
	}

	//	Patch Secondary Pistol Shot
	Ability = AbilityTemplateManager.FindAbilityTemplate('PistolStandardShot_Secondary');
	if (Ability != none)
	{
		//	That will trigger Spinning Reload after an Overwatch Shot if the primary weapon has no ammo left and there are enough Overwatch AP left
		//	this will technically make it possible to trigger the event during player's turn, but shouldn't be a problem.
		Ability.PostActivationEvents.AddItem('DP_SpinningReload_Reactive');
	}

	//	Patch Reload so it grants an Overwatch AP if the soldier has Spinning Reload
	//	Pointless, reload has a custom Build Game State and doesn't apply effects normally.
	/*
	Ability = AbilityTemplateManager.FindAbilityTemplate('Reload');
	if (Ability != none)
	{
		Ability.AddShooterEffect(new class'X2Effect_SpinningReloadAP');
	}*/
	
	//	Patch Pistol Standard Shot to work with Bullet Time
	Ability = AbilityTemplateManager.FindAbilityTemplate('PistolStandardShot');
	if (Ability != none)
	{
		for (i = 0; i < Ability.AbilityCosts.Length; i++)
		{
			if ( X2AbilityCost_ActionPoints(Ability.AbilityCosts[i]) != none )
			{
				X2AbilityCost_ActionPoints(Ability.AbilityCosts[i]).DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
				//break;	//	don't exit in case there are several Action Costs
			}
		}
	}
	if (i > Ability.AbilityCosts.Length) `redscreen("Warning, PatchPistolAbilityTemplates in Akimbo OPTC didn't find expected Action Point Ability Cost in PistolStandardShot.-Iridar");
}


//	Add Spinning Reload animation if the soldier has this ability
static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
    if(!UnitState.IsSoldier())
    {
        return;
    }
	if (UnitState.HasSoldierAbility('DP_SpinningReload_Passive', true))
	{
		CustomAnimSets.AddItem(AnimSet(`CONTENT.DynamicLoadObject("WP_Akimbo.Anims.AS_SpinningReload", class'AnimSet')));
	}
}

/*
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local int Index;
	local XComGameState_Item	ItemState;
	local StateObjectReference	PrimaryWeaponRef;
	
	if (!UnitState.IsSoldier())	return;

	//	If Soldier has Gun Kata
	if (UnitState.HasSoldierAbility('DP_GunKata_Active', true))
	{
		//	Grab the Reference to the soldier's primary weapon
		ItemState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
		if (ItemState == none) return;
		PrimaryWeaponRef = ItemState.GetReference();

		//	Cycle through all abilities avaialable to the soldier
		for (Index = SetupData.Length - 1; Index >= 0; Index--)
		{
			//	If there is an Overwatch or Pistol Overwatch ability applied to the primary weapon, replace it with Gun Kata.
			if (SetupData[Index].SourceWeaponRef == PrimaryWeaponRef &&
				(SetupData[Index].TemplateName == 'Overwatch' || SetupData[Index].TemplateName == 'PistolOverwatch' || SetupData[Index].TemplateName == 'SniperRifleOverwatch'))
			{
				SetupData.Remove(Index, 1);
				break;
			}
		}
	}
}
*/