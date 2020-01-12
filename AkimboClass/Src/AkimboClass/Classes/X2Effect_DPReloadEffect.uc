class X2Effect_DPReloadEffect extends X2Effect; //when applied, this effect reloads target's primary weapon

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item WeaponState, NewWeaponState;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none)
	{
		WeaponState = TargetUnit.GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);
		NewWeaponState =  XComGameState_Item(NewGameState.GetGameStateForObjectID(WeaponState.ObjectID));
		if (NewWeaponState == none)
		{
			NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', WeaponState.ObjectID));
		}
		if (NewWeaponState != none)
		{
			NewWeaponState.Ammo = NewWeaponState.GetClipSize();
		}
	}
}