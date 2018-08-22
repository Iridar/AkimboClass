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
}

static event OnPostTemplatesCreated()	//Making sure that single shot abilities use the right gun first after each reload
{										//Thanks to Mr. Nice for his advice with this
	local X2AbilityTemplateManager			AbilityTemplateManager;
	local X2AbilityTemplate					ReloadAbilityTemplate;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	ReloadAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('Reload');
	ReloadAbilityTemplate.BuildNewGameStateFn = CustomReloadAbility_BuildGameState;

	AddSoldierIntroMap();
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

simulated function XComGameState CustomReloadAbility_BuildGameState( XComGameStateContext Context )	//this is pretty much a copypaste of X2Ability_DefaultAbilitySet.ReloadAbility_BuildGameState
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState, NewWeaponState;
	local array<X2WeaponUpgradeTemplate> WeaponUpgrades;
	local bool bFreeReload;
	local int i;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);	
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID( AbilityContext.InputContext.AbilityRef.ObjectID ));

	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', WeaponState.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));	

	//HERE's THE CUSTOM PART
	UnitState.SetUnitFloatValue(class'X2Effect_DP_CycleGuns'.default.NextGunValue, 0, eCleanup_BeginTactical);	//making sure the right gun is shot first after each reload
	//END OF CUSTOM PART

	//  check for free reload upgrade
	bFreeReload = false;
	WeaponUpgrades = WeaponState.GetMyWeaponUpgradeTemplates();
	for (i = 0; i < WeaponUpgrades.Length; ++i)
	{
		if (WeaponUpgrades[i].FreeReloadCostFn != none && WeaponUpgrades[i].FreeReloadCostFn(WeaponUpgrades[i], AbilityState, UnitState))
		{
			bFreeReload = true;
			break;
		}
	}
	if (!bFreeReload)
		AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, UnitState, NewWeaponState, NewGameState);	

	//  refill the weapon's ammo	
	NewWeaponState.Ammo = NewWeaponState.GetClipSize();
	
	return NewGameState;	
}