class X2Effect_RemoveGunKataCharges extends X2Effect; //this effect is triggered by an ability at the beginning of new player turn

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local UnitValue GunKataCharge;
	local XComGameState_Item PrimaryWeapon;

	TargetUnit = XComGameState_Unit(kNewTargetState);

	if(TargetUnit != none)
	{
		if (TargetUnit.HasSoldierAbility('DP_SpinningReload_Active'))	//if the unit has Spinning Reaload and at least one charge remaining at the beginning of new turn
		{
			TargetUnit.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, GunKataCharge);
			//then trigger an event that will activate a Spinning Reload, if the soldier's ammo is not full already
			PrimaryWeapon = TargetUnit.GetItemInSlot(eInvSlot_PrimaryWeapon);
			if((GunKataCharge.fValue > 0) && (PrimaryWeapon.Ammo < PrimaryWeapon.GetClipSize())) `XEVENTMGR.TriggerEvent('DP_SpinningReload_EOT', TargetUnit, TargetUnit, NewGameState); 
		}


		//remove all remaining charges
		TargetUnit.SetUnitFloatValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, 0, eCleanup_BeginTactical);
	}

}

