class X2Effect_DP_HuntersInstinct extends X2Effect_Persistent;

var int BonusDamage;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit;
	local GameRulesCache_VisibilityInfo VisInfo;

	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (TargetUnit != None && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		if (AbilityState.GetSourceWeapon() != none)
		{
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo))
			{	
				if (Attacker.CanFlank() && TargetUnit.CanTakeCover() && VisInfo.TargetCover == CT_None || AbilityState.IsMeleeAbility() || AbilityState.GetMyTemplateName() == 'DP_TrickShot')
				{	//provides bonus damage if enemy is flankable and flanked, or if activating ability is melee, or if it's Trick Shot
					return BonusDamage;
				}
			}
		}
	}
	return 0;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	//bDisplayInSpecialDamageMessageUI = true	//this triggers flyover text
}
