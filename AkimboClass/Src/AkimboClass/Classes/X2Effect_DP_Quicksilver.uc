class X2Effect_DP_Quicksilver extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'X2Effect_DP_Quicksilver_Event', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit	OldUnitState;
	local XComGameState_Ability	QuicksilverAbilityState;
	local array<name>			ActionPoints;
	local X2EventManager		EventMgr;
	local int					iOriginalActionCost;
	local int j;

	OldUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SourceUnit.ObjectID));
	`LOG("Quicksilver post ability cost paid for: " @ SourceUnit.GetFullName() @ "and ability: " @ kAbility.GetMyTemplateName() @ "current Reserve AP:" @ SourceUnit.ReserveActionPoints.Length @ "previous: " @ OldUnitState.ReserveActionPoints.Length, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');

	//	We make sure beyond reasonable doubt that this ability has added some Reserve AP
	if (OldUnitState != none && SourceUnit.ReserveActionPoints.Length > OldUnitState.ReserveActionPoints.Length && AbilityReservesAP(kAbility))
	{
		// Figure out how many AP this ability should have cost.
		iOriginalActionCost = GetOriginalActionCost(kAbility, SourceUnit);

		//	Make sure this ability wasn't free
		if (iOriginalActionCost != 0)
		{
			`LOG("This ability's minimum AP cost is: " @ iOriginalActionCost @ "actual cost in this case: " @ (OldUnitState.ActionPoints.Length - SourceUnit.ActionPoints.Length) @ "unit had AP before activation: " @ OldUnitState.ActionPoints.Length, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');
			//	I'd love to do this check as well to be sure beyond reasonable doubt, but the ability can potentially cost more AP if it was activated with more AP than necessary, e.g. Overwatch without moving first.
			//	(PreCostActionPoints.Length - SourceUnit.ActionPoints.Length) == iOriginalActionCost

			//	Save pre-cost AP into a local array
			ActionPoints = OldUnitState.ActionPoints;

			//	Subtract the amount of AP the ability should have costed
			for (j = ActionPoints.Length; j >=0 ; j--)
			{
				if (ActionPoints[j] == class'X2CharacterTemplateManager'.default.StandardActionPoint ||
					ActionPoints[j] == class'X2CharacterTemplateManager'.default.RunAndGunActionPoint)
				{
					`LOG("Removing one AP of type: " @ ActionPoints[j], class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');
					ActionPoints.Remove(j, 1);

					iOriginalActionCost--;

					if (iOriginalActionCost <= 0) 
					{
						`LOG("Finished reapplying cost", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');
						break;
					}
				}
			}

			if (iOriginalActionCost > 0) 
			{
				`LOG("Error, Unit ran out of valid AP before the original ability cost could have been reapplied properly", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');
			}

			//	Restore the AP for the unit.
			SourceUnit.ActionPoints = ActionPoints;

			//	Trigger flyover
			QuicksilverAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (QuicksilverAbilityState != none)
			{
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent('X2Effect_DP_Quicksilver_Event', QuicksilverAbilityState, SourceUnit, NewGameState);
			}
		}
	}
	else `LOG("This ability DID NOT add Reserve AP", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIQUICKSILVER');
	return false;
}

static function bool AbilityReservesAP(const XComGameState_Ability AbilityState)
{
	local X2AbilityTemplate					Template;
	local X2Effect							Effect;

	//	Scan through all effects applied by the ability, and if one of them is X2Effect_ReserveOverwatchPoints, assume this is an Overwatch-like ability.
	Template = AbilityState.GetMyTemplate();

	foreach Template.AbilityTargetEffects(Effect)
	{
		if (X2Effect_ReserveOverwatchPoints(Effect) != none)
		{
			return true;
		}
	}
	foreach Template.AbilityShooterEffects(Effect)
	{
		if (X2Effect_ReserveOverwatchPoints(Effect) != none)
		{
			return true;
		}
	}
	return false;
}

simulated function int GetOriginalActionCost(const XComGameState_Ability AbilityState, const XComGameState_Unit AbilityOwner)
{
	local X2AbilityTemplate				Template;
	local X2AbilityCost					Cost;
	local X2AbilityCost_ActionPoints	ActionCost;
	local int							OriginalActionCost;
	local int							TotalOriginalActionCosts;

	Template = AbilityState.GetMyTemplate();

	foreach Template.AbilityCosts(Cost)
	{
		ActionCost = X2AbilityCost_ActionPoints(Cost);

		if (ActionCost != none)
		{
			OriginalActionCost = ActionCost.GetPointCost(AbilityState, AbilityOwner);

			if (ActionCost.bFreeCost)
			{
				//	See X2AbilityCost_Ammo_Phaser for context.
				TotalOriginalActionCosts = max(TotalOriginalActionCosts, OriginalActionCost);
			}
			else
			{
				TotalOriginalActionCosts += OriginalActionCost;
			}
		}
	}
	return TotalOriginalActionCosts;
}

defaultproperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "X2Effect_DP_Quicksilver_Effect"
}