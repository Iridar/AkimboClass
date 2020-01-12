class X2Effect_DP_PistolWhipCost extends X2Effect_Persistent;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit, PrevSourceUnit;
	local XComGameState_Ability AbilityState;
	local int j;

	History = `XCOMHISTORY;

	//  if under the effect of Limit Break, let that handle restoring the full action cost
	if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_DP_LimitBreak'.default.EffectName)) 
	{
		`Log("IRIDAR Pistol Whip overridden by Limit Break", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
		return false;
	}
						
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	`Log("IRIDAR Pistol Whip effect triggered by: " @ kAbility.GetMyTemplateName(), class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
	
	if (AbilityState != none)
	{
		//works only for Pistol Whip
		if (kAbility.GetMyTemplateName() == 'DP_PistolWhip')
		{
			TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
			//  get the unit state for the soldier before he activated pistol whip to correctly measure the distance
			// jesus christ robojumper, is there anything you don't know?!
			PrevSourceUnit = XComGameState_Unit(History.GetGameStateFromHistory(AbilityContext.EventChainStartIndex).GetGameStateForObjectID(SourceUnit.ObjectID));

			`Log("IRIDAR TargetUnit != None: " @ TargetUnit != None, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
			`Log("IRIDAR PrevSourceUnit != None: " @ PrevSourceUnit != None, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
			`Log("IRIDAR Source Unit ID: " @ SourceUnit.ObjectID, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
			`Log("IRIDAR Target Unit ID: " @ AbilityContext.InputContext.PrimaryTarget.ObjectID, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
			`Log("IRIDAR Tile distance: " @ PrevSourceUnit.TileDistanceBetween(TargetUnit), class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');

			if (TargetUnit != None && (PrevSourceUnit == None || PrevSourceUnit.TileDistanceBetween(TargetUnit) <= 1))	//if Pistol Whip was activated from within 1 tile range
			{
				`Log("IRIDAR Restoring all actions points", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
				SourceUnit.ActionPoints = PreCostActionPoints;
				SourceUnit.ReserveActionPoints = PreCostReservePoints;

				for (j=0; j < SourceUnit.ActionPoints.Length; j++)
				{
					if (SourceUnit.ActionPoints[j] == class'X2CharacterTemplateManager'.default.StandardActionPoint)
					{
						`Log("IRIDAR Removing one standard action point", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'AkimboClass');
						SourceUnit.ActionPoints.Remove(j, 1);
						return false;
					}
				}
			}
			
		}
	}
	return false;
}