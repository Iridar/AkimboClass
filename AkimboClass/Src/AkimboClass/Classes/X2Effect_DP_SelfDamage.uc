class X2Effect_DP_SelfDamage extends X2Effect_ApplyWeaponDamage config(Akimbo);

var config float DAMAGE_HEALTH_PERCENT;
var bool DealSoakedDamage;
var config float LIMIT_BREAK_AMPLIFY_DAMAGE;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local Damageable kNewTargetDamageableState;
	local int iDamage, iMitigated, NewRupture, NewShred; 
	local XComGameState_Unit TargetUnit;
	local array<Name> AppliedDamageTypes;
	local int bAmmoBypassesShields, bFullyImmune;
	local bool bDoesDamageIgnoreShields;
	local array<DamageModifierInfo> SpecialDamageMessages;
	local DamageResult ZeroDamageResult;
	local int Health;
	local UnitValue DamageSoaked;

	`Log("IRIDAR Self Damage Effect Triggered",, 'AkimboClass');

	TargetUnit = XComGameState_Unit(kNewTargetState);
	Health = TargetUnit.GetMaxStat(eStat_HP);
	`Log("IRIDAR Target max health: " @ Health,, 'AkimboClass');

	if (DealSoakedDamage)
	{
		TargetUnit.GetUnitValue('DP_LimitBreak_SoakedDamage', DamageSoaked);

		`Log("IRIDAR Self Damage Effect - Total Damage Soaked: " @ DamageSoaked.fValue,, 'AkimboClass');

		EffectDamageValue.Damage = DamageSoaked.fValue * default.LIMIT_BREAK_AMPLIFY_DAMAGE;
		TargetUnit.SetUnitFloatValue('DP_LimitBreak_SoakedDamage', 0, eCleanup_BeginTactical);	//just in case I want to make Limit Break usable more than once per turn. Also I dunno if UnitValues are preserved between missions
	}
	else 
	{
		EffectDamageValue.Damage = Round(default.DAMAGE_HEALTH_PERCENT * Health);
	}
	`Log("IRIDAR Applying damage: " @ EffectDamageValue.Damage,, 'AkimboClass');

	kNewTargetDamageableState = Damageable(kNewTargetState);
	

	if( kNewTargetDamageableState != none )
	{
		AppliedDamageTypes = DamageTypes;
		iDamage = CalculateDamageAmount(ApplyEffectParameters, iMitigated, NewRupture, NewShred, AppliedDamageTypes, bAmmoBypassesShields, bFullyImmune, SpecialDamageMessages, NewGameState);
		bDoesDamageIgnoreShields = (bAmmoBypassesShields > 0) || bBypassShields;
		
		if ((iDamage == 0) && (iMitigated == 0) && (NewRupture == 0) && (NewShred == 0))
		{
			// No damage is being dealt
			if (SpecialDamageMessages.Length > 0 || bFullyImmune != 0)
			{
				TargetUnit = XComGameState_Unit(kNewTargetState);
				if (TargetUnit != none)
				{
					ZeroDamageResult.bImmuneToAllDamage = bFullyImmune != 0;
					ZeroDamageResult.Context = NewGameState.GetContext();
					ZeroDamageResult.SourceEffect = ApplyEffectParameters;
					ZeroDamageResult.SpecialDamageFactors = SpecialDamageMessages;
					TargetUnit.DamageResults.AddItem(ZeroDamageResult);
				}
			}
			return;
		}
		AppliedDamageTypes = DamageTypes;
		iDamage = CalculateDamageAmount(ApplyEffectParameters, iMitigated, NewRupture, NewShred, AppliedDamageTypes, bAmmoBypassesShields, bFullyImmune, SpecialDamageMessages, NewGameState);
		bDoesDamageIgnoreShields = (bAmmoBypassesShields > 0) || bBypassShields;
	
		if (NewRupture > 0)
		{
			kNewTargetDamageableState.AddRupturedValue(NewRupture);
		}
		
		kNewTargetDamageableState.TakeEffectDamage(self, iDamage, iMitigated, NewShred, ApplyEffectParameters, NewGameState, false, true, bDoesDamageIgnoreShields, AppliedDamageTypes, SpecialDamageMessages);
		`Log("IRIDAR Damage applied.",, 'AkimboClass');
	}
}

DefaultProperties
{
	DealSoakedDamage = false;
}
