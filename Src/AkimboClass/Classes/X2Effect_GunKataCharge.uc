//class X2Effect_GunKataCharge extends X2Effect_Persistent config (GameData_Soldierskills);
class X2Effect_GunKataCharge extends X2Effect_Persistent config(Akimbo);

var privatewrite name GunKataChargeValue, PreGunKataChargeValue;
var int MaxGunKataCharge;
/*
function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'GunKataCharge_Passive', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}*/

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local UnitValue GunKataCharge;
	local int QuicksilverCharge;

	EventMgr = `XEVENTMGR;

	if (kAbility.GetMyTemplateName() == 'DP_SpinningReload_Active' || kAbility.GetMyTemplateName() == 'DP_SpinningReload_Reactive')	//give 1 charge
	{
			SourceUnit.GetUnitValue(default.GunKataChargeValue, GunKataCharge);

			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AbilityState != None)
			{
				//EventMgr.TriggerEvent('GunKataCharge_Passive', AbilityState, SourceUnit, NewGameState);
				SourceUnit.SetUnitFloatValue(default.GunKataChargeValue, GunKataCharge.fValue + 1, eCleanup_BeginTactical);
			}
	}
	if (kAbility.GetMyTemplateName() == 'DP_GunKata_Active')	//give 3 charges
	{
			SourceUnit.GetUnitValue(default.GunKataChargeValue, GunKataCharge);

			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AbilityState != None)
			{
				QuicksilverCharge = 0;
				if(SourceUnit.HasSoldierAbility('DP_Quicksilver')) QuicksilverCharge = 1;
				//EventMgr.TriggerEvent('GunKataCharge_Passive', AbilityState, SourceUnit, NewGameState);
				SourceUnit.SetUnitFloatValue(default.GunKataChargeValue, GunKataCharge.fValue + 3 + QuicksilverCharge, eCleanup_BeginTactical);
			}
	}

	if(!SourceUnit.HasSoldierAbility('DP_Quicksilver'))	//make sure the number of Gun Kata charges doesn't exceed maximum
	{
		SourceUnit.GetUnitValue(default.GunKataChargeValue, GunKataCharge);
		if(GunKataCharge.fValue > MaxGunKataCharge) SourceUnit.SetUnitFloatValue(default.GunKataChargeValue, MaxGunKataCharge, eCleanup_BeginTactical);
	}

	return false;
}

defaultproperties
{
	GunKataChargeValue = "GunKataCharge"
	PreGunKataChargeValue = "PreGunKataCharge"
}

