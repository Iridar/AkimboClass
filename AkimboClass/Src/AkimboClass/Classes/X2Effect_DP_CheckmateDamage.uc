class X2Effect_DP_CheckmateDamage extends X2Effect_DeadeyeDamage config(Akimbo);

var config float CHECKMATE_DAMAGE_MULTIPLIER_DUAL_WIELDING;
var config float CHECKMATE_DAMAGE_MULTIPLIER;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage;

	if(class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		if (AbilityState.GetMyTemplateName() == 'DP_Checkmate')
		{
			if (class'X2Condition_DP_DualPistols'.static.HasDualPistolEquipped(Attacker, NewGameState))
			{
				ExtraDamage = CurrentDamage * default.CHECKMATE_DAMAGE_MULTIPLIER_DUAL_WIELDING;
			}
			else
			{
				ExtraDamage = CurrentDamage * default.CHECKMATE_DAMAGE_MULTIPLIER;
			}
		}		
	}
	return int(ExtraDamage);
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
