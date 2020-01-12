class X2Condition_DP_AmmoCondition extends X2Condition;	//this condition allows to perform various ammo checks for the target's primary weapon

var int iAmmo;
var bool ExactMatch;
var bool WantsReload;
var bool NeedsReload;
var bool ForSpinningReload;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;
	local XComGameState_Item PrimaryWeapon;

	//`LOG("Dual Pistol Ammo Condition called by: " @ kAbility.GetMyTemplateName(),, 'AKIMBO');

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	//UnitState = XComGameState_Unit(kTarget);
	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	//this is for Spinning Reload Active - I want that ability to be available even at full ammo if the soldier doesn't have Quicksilver
	if (ForSpinningReload)
	{
		if (!UnitState.HasSoldierAbility('DP_Quicksilver')) return 'AA_Success';	//if the soldier doesn't have Quicksilver, we make Spinning Reload available regardless of ammo
		else 
		{
			if (PrimaryWeapon.Ammo < PrimaryWeapon.GetClipSize()) return 'AA_Success';	//if soldier does have Quicksilver, we make ability available only if weapon wants a reload
			else return 'AA_Whatever';
		}
	}

	//`LOG("Current ammo: " @ PrimaryWeapon.Ammo,, 'AKIMBO');

	if (WantsReload && (PrimaryWeapon.Ammo < PrimaryWeapon.GetClipSize())) 
	{
		//`LOG("We check if weapon WANTS reload and it does.",, 'AKIMBO');
		return 'AA_Success';
	}

	if (NeedsReload && (PrimaryWeapon.Ammo <= 0)) 
	{
		//`LOG("We check if weapon NEEDS reload and it does.",, 'AKIMBO');
		return 'AA_Success';
	}

	if (ExactMatch && (PrimaryWeapon.Ammo == iAmmo)) 
	{
		//`LOG("We check if weapon has exactly " @ iAmmo @ " ammo, and it does.",, 'AKIMBO');
		return 'AA_Success';
	}

	return 'AA_AbilityUnavailable';
}

defaultproperties
{
	iAmmo = 0
	ExactMatch = true
	WantsReload = false
	NeedsReload = false
	ForSpinningReload = false
}