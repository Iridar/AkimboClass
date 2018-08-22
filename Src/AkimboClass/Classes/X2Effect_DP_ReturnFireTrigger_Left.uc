class X2Effect_DP_ReturnFireTrigger_Left extends X2Effect_CoveringFire;

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="DP_ReturnFireTrigger"
	AbilityToActivate = "DP_GunKata_OverwatchShotLeft"
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = false
}