class X2Effect_ForceDodge extends X2Effect_Persistent;

//this persistent effect turns any hits into misses at the cost of Gun Kata Charges

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local Object				EffectObj;
	local X2EventManager		EventMgr;
	local XComGameState_Unit	SourceUnitState;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	SourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'IRI_GunKata_Flyover', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted,, SourceUnitState);
}

function bool ChangeHitResultForTarget(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, bool bIsPrimaryTarget, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local X2EventManager		EventMgr;
	local XComGameState_Ability	GunKataAbilityState;
	local int j;

	/*local XComGameStateContext_Ability          AbilityContext;
	local XComGameStateContext					Context;

	`Log("IRIDAR ChangeHitResultForTarget 1 Triggered: ",, 'AkimboClass');

	Context = AbilityState.GetParentGameState().GetContext();
	AbilityContext = XComGameStateContext_Ability(Context);

	`Log("IRIDAR Effects #: " @ AbilityContext.ResultContext.TargetEffectResults.Effects.Length,, 'AkimboClass');

	for (j = 0; j < AbilityContext.ResultContext.TargetEffectResults.Effects.Length; ++j)
	{
		`Log("IRIDAR Effect: " @ AbilityContext.ResultContext.TargetEffectResults.Effects[j],, 'AkimboClass');
	}*/

	if(TargetUnit.IsAbleToAct())	//I assume this checks our soldier isn't stunned / bound / etc
	{
		for (j = TargetUnit.ReserveActionPoints.Length - 1; j >= 0; --j)	//go through all reserve action point types the soldier has
		{
			if (TargetUnit.ReserveActionPoints[j] == class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint ||
				TargetUnit.ReserveActionPoints[j] == class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint)	//if one of them is an overwatch AP
			{
				if (class'XComGameStateContext_Ability'.static.IsHitResultHit(CurrentResult))	//and the enemy attack would've been a hit
				{
					TargetUnit.ReserveActionPoints.Remove(j, 1);	//apply action point cost
					NewHitResult = eHit_LightningReflexes;					

					//trigger a spinning reload when getting shot. it will go through only if the soldier has 0 ammo and enough Overwatch AP.
					`XEVENTMGR.TriggerEvent('DP_SpinningReload_Reactive', TargetUnit, TargetUnit); 
					
					GunKataAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(TargetUnit.FindAbility('GunKata_Passive').ObjectID));
					if (GunKataAbilityState != none)
					{
						EventMgr = `XEVENTMGR;
						EventMgr.TriggerEvent('IRI_GunKata_Flyover', GunKataAbilityState, TargetUnit, TargetUnit.GetParentGameState());
					}
					return true;
				}
			}
		}
	}
	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "DP_ForceDodge"
}