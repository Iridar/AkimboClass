class X2AbilityToHitCalc_DPMelee extends X2AbilityToHitCalc_StandardMelee;	

function int GetWeaponRangeModifier(XComGameState_Unit Shooter, XComGameState_Unit Target, XComGameState_Item Weapon)
{
    return 0;
}

//this class removes weapon aim bonuses from melee attacks based on distance to the target
//without this basically any melee attack attached to a pistol would always hit due to crazy aim bonuses that pistols get at close ranges