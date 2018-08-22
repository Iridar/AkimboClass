class X2Effect_SpinningReloadEffect extends X2Effect_Persistent;


function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Item WeaponState, NewWeaponState;
	local UnitValue GunKataCharge;


	SourceUnit.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge);
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));

	if(GunKataCharge.fValue > 1 && NewWeaponState.Ammo == 0)
	{	
		NewWeaponState.Ammo = NewWeaponState.GetClipSize();
		NewGameState.AddStateObject(NewWeaponState);
		SourceUnit.SetUnitFloatValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge.fValue - 1, eCleanup_BeginTactical);

	}
	return false;
}


/*
simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item WeaponState, NewWeaponState;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none)
	{
		WeaponState = TargetUnit.GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);
		if (WeaponState != none)
		{
			NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));
			NewWeaponState.Ammo = NewWeaponState.GetClipSize();
			NewGameState.AddStateObject(NewWeaponState);
		}
	}
}*/
/*
simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local X2Action_PlayAnimation		PlayAnimation;
	local XComGameStateContext_Ability  Context;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(BuildTrack, Context));
	PlayAnimation.Params.AnimName = 'HL_Reload';
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "Weapon reloaded.", 'Reloading', eColor_Good);

}*/
/*
simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	`XEVENTMGR.TriggerEvent(default.SpinningReloadTriggeredEventName, kNewTargetState, kNewTargetState, NewGameState);
}*/
/*
defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="SpinningReloadEffect"
	AbilityToActivate = "DP_SpinningReload_RldConv"
	GrantActionPoint = "standard"
	MaxPointsPerTurn = 1
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = false
	SpinningReloadTriggeredEventName = "SpinningReloadEnded"
}*/