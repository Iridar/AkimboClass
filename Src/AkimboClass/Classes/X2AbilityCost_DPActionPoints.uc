class X2AbilityCost_DPActionPoints extends X2AbilityCost_ActionPoints;

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if (AbilityOwner.HasSoldierAbility('DP_BulletTime'))
	{
		return false;
	}
	return super.ConsumeAllPoints(AbilityState, AbilityOwner);
}