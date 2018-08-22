class X2AbilityCost_GKActionPoints extends X2AbilityCost_ActionPoints;

simulated function bool ConsumeAllPoints(XComGameState_Ability AbilityState, XComGameState_Unit AbilityOwner)
{
	if (AbilityOwner.HasSoldierAbility('DP_Quicksilver'))
	{
		return false;
	}
	return super.ConsumeAllPoints(AbilityState, AbilityOwner);
}