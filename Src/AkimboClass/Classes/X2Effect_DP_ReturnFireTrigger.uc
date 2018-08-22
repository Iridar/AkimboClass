class X2Effect_DP_ReturnFireTrigger extends X2Effect_CoveringFire;

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="DP_ReturnFireTrigger"
	AbilityToActivate = "DP_GunKata_OverwatchShotRight"
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = false
}
