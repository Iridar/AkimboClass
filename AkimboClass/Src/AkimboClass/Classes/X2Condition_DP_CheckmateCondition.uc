class X2Condition_DP_CheckmateCondition extends X2Condition;	//simple condition that checks if the target is stunned, panicked or unconcsious


event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit UnitState;

	//UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	UnitState = XComGameState_Unit(kTarget);

	if (UnitState.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.StunnedName)) return 'AA_Success';
	if (UnitState.IsUnitAffectedByEffectName(class'X2StatusEffects'.default.UnconsciousName)) return 'AA_Success';
	if (UnitState.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.PanickedName)) return 'AA_Success';

	return 'AA_MissingRequiredEffect';
}

