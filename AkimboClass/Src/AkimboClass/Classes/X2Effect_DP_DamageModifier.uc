class X2Effect_DP_DamageModifier extends X2Effect_Persistent config(Akimbo);

var config float LEG_SHOT_DAMAGE_MULTIPLIER;
var config float TRICK_SHOT_DAMAGE_MULTIPLIER;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float ExtraDamage;

	//`LOG("X2Effect_DP_DamageModifier::GetAttackingDamageModifier for ability: " @ AbilityState.GetMyTemplateName(),, 'IRIBUFF');

	if(class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
	{
		if (AbilityState.GetMyTemplateName() == 'DP_LegShot' || AbilityState.GetMyTemplateName() == 'DP_LegShotSecondary')
		{
			ExtraDamage = -1  * CurrentDamage * default.LEG_SHOT_DAMAGE_MULTIPLIER;
		}
		if (AbilityState.GetMyTemplateName() == 'DP_TrickShot')
		{
			ExtraDamage = CurrentDamage * default.TRICK_SHOT_DAMAGE_MULTIPLIER;
		}
	}
	//`LOG("default.LEG_SHOT_DAMAGE_MULTIPLIER: " @ default.LEG_SHOT_DAMAGE_MULTIPLIER,, 'IRIBUFF');
	//`LOG("default.TRICK_SHOT_DAMAGE_MULTIPLIER: " @ default.TRICK_SHOT_DAMAGE_MULTIPLIER,, 'IRIBUFF');
	//`LOG("ExtraDamage: " @ ExtraDamage,, 'IRIBUFF');
	return int(ExtraDamage);
}

defaultproperties
{
	bDisplayInSpecialDamageMessageUI = true
}
