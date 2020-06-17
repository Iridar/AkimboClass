class X2Condition_DP_DualPistols extends X2Condition config(Akimbo); //this condition checks whether the soldier has dual pistols equipped. This is mostly necessary for Musashi's RPG Overhaul.

var config array<name> PistolCategories;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	if (HasDualPistolEquipped(UnitState)) return 'AA_Success';

	return 'AA_Whatever';
}

static public function bool IsPrimaryPistolWeaponState(XComGameState_Item ItemState)
{	
	return ItemState != none && 
		   ItemState.InventorySlot == eInvSlot_PrimaryWeapon && 
		   default.PistolCategories.Find(ItemState.GetWeaponCategory()) != INDEX_NONE;
}

static public function bool IsSecondaryPistolWeaponState(XComGameState_Item ItemState)
{	
	return ItemState != none && 
		   ItemState.InventorySlot == eInvSlot_SecondaryWeapon && 
		   default.PistolCategories.Find(ItemState.GetWeaponCategory()) != INDEX_NONE;
}

static public function bool HasDualPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon, SecondaryWeapon;

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);
	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);

	return 	IsPrimaryPistolWeaponState(PrimaryWeapon) &&
			IsSecondaryPistolWeaponState(SecondaryWeapon) &&
			PrimaryWeapon.GetWeaponCategory() == SecondaryWeapon.GetWeaponCategory(); // can dual wield guns only with the same WeaponCat
}	
