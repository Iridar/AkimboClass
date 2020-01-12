class X2Effect_SpinningReloadAP extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'X2Effect_DP_SpinningReload_FlyoverEvent', TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability	AbilityState;
	local XComGameState_Item	PistolItemState;
	local X2EventManager		EventMgr;
	local StateObjectReference	AbilityRef;
	local XComGameState_Ability	PistolOverwatchAbilityState;
	local X2WeaponTemplate		WeaponTemplate;
	local XComGameStateHistory	History;
	local bool					bFlyover;

	`LOG("Spinning Reload -> Post Ability Cost Paid for: " @ kAbility.GetMyTemplateName(), class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');

	if (kAbility.GetMyTemplateName() == 'Reload')
	{
		History = `XCOMHISTORY;
		if (SourceWeapon != none)
		{
			WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
			if (WeaponTemplate != none && WeaponTemplate.iTypicalActionCost == 1)
			{
				`LOG("Giving one Reserve AP of type: " @ WeaponTemplate.OverwatchActionPoint, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');
				bFlyover = true;
				SourceUnit.ReserveActionPoints.AddItem(WeaponTemplate.OverwatchActionPoint);
			}
		}
		else	//	I think it's too powerful to have Spinning Reload give Overwatch to weapons that take 2 AP to fire
		{
			//	So check if the soldier has a pistol somewhere and activate its Overwatch instead.
			//	More or less same treatment as Ever Vigilant.
			//	I could look at secondary weapon specifically, but that wouldn't account for utility slot sidearms.
			AbilityRef = SourceUnit.FindAbility('PistolOverwatch');
			if (AbilityRef.ObjectID != 0)
			{
				PistolOverwatchAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
				if (PistolOverwatchAbilityState != none)
				{
					PistolItemState = PistolOverwatchAbilityState.GetSourceWeapon();
					if (PistolItemState != none)
					{
						WeaponTemplate = X2WeaponTemplate(PistolItemState.GetMyTemplate());

						if (WeaponTemplate != none && WeaponTemplate.iTypicalActionCost == 1)
						{
							`LOG("Giving one Reserve AP of type: " @ WeaponTemplate.OverwatchActionPoint, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');
							bFlyover = true;
							SourceUnit.ReserveActionPoints.AddItem(WeaponTemplate.OverwatchActionPoint);
						}
					}
				}
			}
		}
		if (bFlyover)
		{
			//	Trigger flyover
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AbilityState != none)
			{
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent('X2Effect_DP_SpinningReload_FlyoverEvent', AbilityState, SourceUnit, NewGameState);

				`LOG("Triggering event", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');

				//	Never gets called, probably, again, because Reload has a customb Build Viz.
				//AbilityContext.PostBuildVisualizationFn.AddItem(OverwatchAbility_BuildVisualization);
			}
		}
	}
	return false;
}

static function EventListenerReturn TriggerAbilityFlyover(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameState_Ability AbilityState;

	`LOG("Running listener.", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');

	UnitState = XComGameState_Unit(EventSource);
	AbilityState = XComGameState_Ability(EventData);

	if (UnitState != none && AbilityState != none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
		AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(AbilityState.Class, AbilityState.ObjectID));
		XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = OverwatchAbility_BuildVisualization;
		`TACTICALRULES.SubmitGameState(NewGameState);
	}
	return ELR_NoInterrupt;
}

static function OverwatchAbility_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          InteractingUnitRef;
	local VisualizationActionMetadata   EmptyTrack;
	local VisualizationActionMetadata   ActionMetadata;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local UnitValue						EverVigilantValue;
	local XComGameState_Unit			UnitState;
	local X2AbilityTemplate				AbilityTemplate;
	local string						FlyOverText, FlyOverImage;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	`LOG("Running build viz, context: " @ Context != none @ "Interacting Unit: " @ InteractingUnitRef.ObjectID, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if (UnitState != none)
	{		
		if (UnitState.GetUnitValue(class'X2Ability_SpecialistAbilitySet'.default.EverVigilantEffectName, EverVigilantValue) && EverVigilantValue.fValue > 0)
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('EverVigilant');
			if (UnitState.HasSoldierAbility('CoveringFire'))
				FlyOverText = class'XLocalizedData'.default.EverVigilantWithCoveringFire;
			else
				FlyOverText = AbilityTemplate.LocFlyOverText;
			FlyOverImage = AbilityTemplate.IconImage;
		}
		else if (UnitState.HasSoldierAbility('CoveringFire'))
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('CoveringFire');
			FlyOverText = AbilityTemplate.LocFlyOverText;
			FlyOverImage = AbilityTemplate.IconImage;
		}
		else if (UnitState.HasSoldierAbility('SkirmisherAmbush'))
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('SkirmisherAmbush');
			FlyOverText = AbilityTemplate.LocFlyOverText;
			FlyOverImage = AbilityTemplate.IconImage;
		}
		else
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);
			FlyOverText = AbilityTemplate.LocFlyOverText;
			FlyOverImage = AbilityTemplate.IconImage;
		}
		`LOG("Playing sound:" @ SoundCue(`CONTENT.DynamicLoadObject("SoundUI.OverwatchCue", class'SoundCue')) != none, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRISPINNINGRELOAD');
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(SoundCue(`CONTENT.DynamicLoadObject("SoundUI.OverwatchCue", class'SoundCue')), FlyOverText, '', eColor_Good, FlyOverImage);
	}
}