class X2Effect_DP_AmmoCost extends X2Effect;

var int iAmmo;

//this is a roundabout way of adding an ammuniton cost to some of the abilities, since the normal way doesn't work for whatever reason
simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item WeaponState, NewWeaponState;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none)
	{
		WeaponState = TargetUnit.GetItemInSlot(eInvSlot_PrimaryWeapon, NewGameState);
		if (WeaponState != none && WeaponState.Ammo > 0)
		{
			NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(WeaponState.Class, WeaponState.ObjectID));
			NewWeaponState.Ammo = WeaponState.Ammo - iAmmo;
		}
	}
}

defaultproperties
{
	iAmmo = 1
}