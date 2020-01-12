class X2Effect_DP_LimitBreak extends X2Effect_Persistent config(Akimbo);

var privatewrite name BonusActionsValue;
var config int LIMIT_BREAK_ACTIONS_BEFORE_DAMAGE;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability AbilityState;
	local UnitValue BonusActions;
	local XComGameStateHistory History;
	local X2EventManager EventMgr;

	History = `XCOMHISTORY;
	EventMgr = `XEVENTMGR;

	if (SourceUnit.NumActionPoints() == 0 && PreCostActionPoints.Length > 0)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			//`Log("IRIDAR Granting bonus AP",, 'AkimboClass');
			SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			SourceUnit.GetUnitValue(default.BonusActionsValue, BonusActions);
			//`Log("IRIDAR BonusActionsValue: " @ BonusActions.fValue,, 'AkimboClass');
			SourceUnit.SetUnitFloatValue(default.BonusActionsValue, BonusActions.fValue + 1, eCleanup_BeginTactical);
			
			if (BonusActions.fValue + 1 > default.LIMIT_BREAK_ACTIONS_BEFORE_DAMAGE) EventMgr.TriggerEvent('DP_LimitBreak_SelfDamage', AbilityState, SourceUnit, NewGameState);
			return true;
		}
	}
	return false;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit UnitState;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	`XEVENTMGR.TriggerEvent('DP_LimitBreak_DealSoakedDamage', UnitState, UnitState);
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	BonusActionsValue = "DP_BonusActionsValue"
	EffectName = "DP_LimitBreak"
}
