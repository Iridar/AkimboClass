class X2AbilityCost_GunKataCharge extends X2AbilityCost;

var int RequiredGunKataCharge;

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
	local UnitValue GunKataCharge;

	ActivatingUnit.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge);
	if (GunKataCharge.fValue >= RequiredGunKataCharge)
	{
		return 'AA_Success';
	}
	return 'AA_CannotAfford_GunKataCharge';
}

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local XComGameState_Unit ActivatingUnit;
	local UnitValue GunKataCharge;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	ActivatingUnit = XComGameState_Unit(AffectState);
	ActivatingUnit.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge);
	ActivatingUnit.SetUnitFloatValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge.fValue - RequiredGunKataCharge, eCleanup_BeginTactical);

	//this will trigger a spinning reload after a reaction shot if the soldier has 0 ammo
	//if(ActivatingUnit.HasSoldierAbility('DP_SpinningReload_Active')) `XEVENTMGR.TriggerEvent('DP_SpinningReload_Reactive', ActivatingUnit, ActivatingUnit, NewGameState); 
}

