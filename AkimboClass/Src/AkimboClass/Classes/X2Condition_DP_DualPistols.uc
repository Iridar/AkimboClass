class X2Condition_DP_DualPistols extends X2Condition config(Akimbo); //this condition checks whether the soldier has dual pistols equipped. This is mostly necessary for Musashi's RPG Overhaul.

var config array<name> PistolCategories;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	if (HasDualPistolEquipped(UnitState)) return 'AA_Success';

	return 'AA_Whatever';
}

static function bool IsPrimaryPistolWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	return WeaponTemplate != none &&
		WeaponTemplate.InventorySlot == eInvSlot_PrimaryWeapon &&
		default.PistolCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE;
}

static function bool IsSecondaryPistolWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	return WeaponTemplate != none &&
		WeaponTemplate.InventorySlot == eInvSlot_SecondaryWeapon &&
		default.PistolCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE;
}

static function bool HasDualPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local X2WeaponTemplate PrimaryTemplate, SecondaryTemplate;

	PrimaryTemplate = X2WeaponTemplate(UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState).GetMyTemplate());
	SecondaryTemplate = X2WeaponTemplate(UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState).GetMyTemplate());

	return IsPrimaryPistolWeaponTemplate(PrimaryTemplate) &&
		  IsSecondaryPistolWeaponTemplate(SecondaryTemplate) &&
		  PrimaryTemplate.WeaponCat == SecondaryTemplate.WeaponCat; // can dual wield guns only with the same WeaponCat
}
