class X2Condition_DP_TrickShot extends X2Condition;	

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget) //this condition returns true if target can be flanked in principle, but right now is in cover
{
	local XComGameState_Unit				SourceUnit, TargetUnit;
	local GameRulesCache_VisibilityInfo		VisInfo;
	
	TargetUnit = XComGameState_Unit(kTarget);
	SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	
	if (TargetUnit != none && SourceUnit != none)
	{
		if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(SourceUnit.ObjectID, TargetUnit.ObjectID, VisInfo)) //this condition will fail if ability owner cannot see the target
		{
			if (TargetUnit.CanTakeCover() && VisInfo.TargetCover != CT_None) return 'AA_Success';

		}
	}
	return 'AA_Whatever';
}

