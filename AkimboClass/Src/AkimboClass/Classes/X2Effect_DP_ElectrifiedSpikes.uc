class X2Effect_DP_ElectrifiedSpikes extends X2Effect_Shredder; //this effect replaces the usual ApplyWeaponDamage for melee attacks. 
//when the soidier has ElectrifiedSpikes ability, this effect provides 1 shred to each melee attack against stunned or disoriented enemies.

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue ShredValue;
	local XComGameState_Unit TargetUnit;

	ShredValue = EffectDamageValue;             //  in case someone has set other fields in here, but not likely

	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(TargetRef.ObjectID));

	if (SourceUnit.HasSoldierAbility('DP_ElectrifiedSpikes') &&
		(TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DisorientedName) ||
		 TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.StunnedName))) 
		{
			ShredValue.Shred += 1;
		}

	return ShredValue;
}
