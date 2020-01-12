class X2Effect_DP_ReserveActionPoints extends X2Effect_ReserveOverwatchPoints;

//	Same as the original X2Effect_ReserveOverwatchPoints, except we take away only one Action Point if the soldier has Quicksilver.
//	Have to do it here and through DoNotConsumeAllSoldierAbilities array in the Overwatch's Ability Cost to prevent conflicts
//	with mods that change Overwatch's Ability Cost, like Mitzruti's Perk Pack.

//	Don't take away ANY action points. Used by Spinning Reload.
var bool bFreeCost;

var array<name> FallbackArray;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit	TargetUnitState;
	
	local name					OverwatchPointName;
	local int					OverwatchPointsToGive;
	local array<name>			ValidActionPointNames;
	local int					iTypicalActionCost;
	local int i;
	
	

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if (TargetUnitState != none)
	{
		//	Give Reserve AP
		OverwatchPointsToGive = GetNumPoints(TargetUnitState);
		OverwatchPointName = GetReserveType(ApplyEffectParameters, NewGameState);
		`LOG("X2Effect_DP_ReserveActionPoints applied to: " @ TargetUnitState.GetFullName() @ "gonna give this amount of Reserve AP: " @ OverwatchPointsToGive @ "of type: " @ OverwatchPointName, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AKIMBO');
		for (i = 0; i < OverwatchPointsToGive; ++i)
		{
			TargetUnitState.ReserveActionPoints.AddItem(OverwatchPointName);
		}

		//	Remove AP
		if (!bFreeCost)
		{
			if (TargetUnitState.HasSoldierAbility('DP_Quicksilver', true))
			{
				ValidActionPointNames = GetValidActionPointNames(ApplyEffectParameters.AbilityStateObjectRef);
				iTypicalActionCost = GetTypicalActionCost(ApplyEffectParameters.ItemStateObjectRef);

				`LOG("Soldier has Quicksilver.", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AKIMBO');

				//	If Soldier has Quicksilver, take away only one AP
				for (i = 0; i < TargetUnitState.ActionPoints.Length; i++)
				{
					if (ValidActionPointNames.Find(TargetUnitState.ActionPoints[i]) != INDEX_NONE)
					{
						`LOG("Removed one Action Point of type:" @ TargetUnitState.ActionPoints[i], class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AKIMBO');
						TargetUnitState.ActionPoints.Remove(i, 1);
						iTypicalActionCost--;
						if (iTypicalActionCost <= 0) break;
					}
				}
			}
			else
			{
				`LOG("Removed all Action Points.", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AKIMBO');
				// Take away all AP otherwise.
				TargetUnitState.ActionPoints.Length = 0;
			}
		}
	}
}

static function array<name> GetValidActionPointNames(StateObjectReference AbilityRef)
{
	local XComGameState_Ability			AbilityState;
	local X2AbilityTemplate				Template;
	local X2AbilityCost					Cost;
	local X2AbilityCost_ActionPoints	ActionCost;

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
	if (AbilityState != none)
	{	
		Template = AbilityState.GetMyTemplate();
		
		foreach Template.AbilityCosts(Cost)
		{
			ActionCost = X2AbilityCost_ActionPoints(Cost);
			if (ActionCost != none)
			{
				return ActionCost.AllowedTypes;
			}
		}
	}
	return default.FallbackArray;
}

static function int GetTypicalActionCost(StateObjectReference ItemRef)
{
	local XComGameState_Item	ItemState;
	local X2WeaponTemplate		Template;

	ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ItemRef.ObjectID));
	if (ItemState != none)
	{	
		Template = X2WeaponTemplate(ItemState.GetMyTemplate());
		if (Template != none)
		{
			return Template.iTypicalActionCost;
		}		
	}
	return 1;
}

//	Provide double amount of points if the soldier has Gun Kata.
simulated protected function int GetNumPoints(XComGameState_Unit UnitState)
{
	if (UnitState.HasSoldierAbility('DP_GunKata_Active', true))
	{
		return 2 * super.GetNumPoints(UnitState);
	}
	else
	{
		return super.GetNumPoints(UnitState);
	}	
}

defaultproperties
{
	FallbackArray(0) = "standard"
	FallbackArray(1) = "runandgun"
}