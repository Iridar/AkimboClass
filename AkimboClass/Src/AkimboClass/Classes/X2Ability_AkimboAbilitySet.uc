class X2Ability_AkimboAbilitySet extends X2Ability config(Akimbo);

var config int PISTOL_WHIP_MELEE_AIM_BONUS;
var config bool TRICK_SHOT_ONLY_AGAINST_COVER;
var config bool TRICK_SHOT_USES_SPECIAL_AIM;
var config int TRICK_SHOT_CRIT_CHANCE_BONUS;
var config int UNLOAD_COOLDOWN;
var config int UNLOAD_AIM_PENALTY;
var config int UNLOAD_ACTION_POINT_COST;
var config int QUICKSILVER_AIM_BONUS;
var config int ELECTRIFIED_SPIKES_DISORIENT_CHANCE;
var config int ELECTRIFIED_SPIKES_STUN_CHANCE;
var config int DIRTY_KICK_COOLDOWN;
var config array<config int> ConsciousChance;

var config bool DUAL_PISTOL_SPECIALIZATION_IS_AWC;	
var config bool CHECKMATE_IS_AWC;
var config bool GUN_KATA_IS_AWC;	
var config bool LIMIT_BREAK_IS_AWC;	
var config bool SPINNING_RELOAD_IS_AWC;	
var config bool DIRTY_KICK_IS_AWC;	
var config bool QUICKSILVER_IS_AWC;	
var config bool ENABLE_LOGGING;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	//Squaddie Perks
	Templates.AddItem(Create_DP_DualPistols());

	//Gun Fu
	Templates.AddItem(Create_DP_TrickShot());
	Templates.AddItem(Create_DP_BulletTime());
	Templates.AddItem(Create_GunKata_Passive());

	Templates.AddItem(Create_DP_SpinningReload_Passive());
	Templates.AddItem(Create_DP_SpinningReload_Reactive());
	Templates.AddItem(Create_DP_SpinningReload_EOT());

	Templates.AddItem(Create_DP_Quicksilver());
	Templates.AddItem(Create_DP_Unload());

	//	SCRAPPER TREE
	Templates.AddItem(Create_DP_PistolWhip());
	Templates.AddItem(Create_DP_PistolWhipSecondary());
	Templates.AddItem(Create_DP_BonusMeleeAim());

	Templates.AddItem(Create_DP_CQCSupremacy());
	Templates.AddItem(Create_DP_CQCSupremacyAttack());
	Templates.AddItem(Create_DP_CQCSupremacyAttackSecondary());

	Templates.AddItem(Create_DP_TakeInitiative());
	Templates.AddItem(Create_DP_TakeInitiativeStrike());
	Templates.AddItem(Create_DP_TakeInitiativeStrikeLeft());

	Templates.AddItem(Create_DP_ElectrifiedSpikes());
	Templates.AddItem(Create_DP_Checkmate());
	Templates.AddItem(Create_DP_CheckmatePassive());

	Templates.AddItem(Create_DP_LimitBreak());
	Templates.AddItem(Create_DP_LimitBreak_SelfDamage());
	Templates.AddItem(Create_DP_LimitBreak_SoakDamage());
	Templates.AddItem(Create_DP_LimitBreak_DealSoakedDamage());

	Templates.AddItem(Create_DP_TrickLegShotDamagePassive());

	//SUPPLEMENTAL
	Templates.AddItem(Create_DP_LegShot());
	Templates.AddItem(Create_DP_LegShotSecondary());
	Templates.AddItem(Create_DP_DirtyKick());
	Templates.AddItem(Create_DP_DirtyKick_Passive());
	Templates.AddItem(Create_DP_HuntersInstinct());
	
	return Templates;
}

// =======================================================================
// =======================================================================
//								SHARED ABILITY SET
// =======================================================================
// =======================================================================

//	Removes Aim Penalty from offhand pistol attacks
static function X2AbilityTemplate Create_DP_DualPistols()
{
	local X2AbilityTemplate                 Template;

	Template = PurePassive('DP_DualPistols', "img:///WP_Akimbo.UIIcons.DualPistols", true, 'eAbilitySource_Perk');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.bDontDisplayInAbilitySummary = false;

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');

	Template.bCrossClassEligible = default.DUAL_PISTOL_SPECIALIZATION_IS_AWC;

	return Template;
}

// =======================================================================
// =======================================================================
//							GUN FU ABILITY SET
// =======================================================================
// =======================================================================

static function X2AbilityTemplate Create_DP_TrickShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2Condition_UnitEffects			SuppressedCondition;
	local X2AbilityToHitCalc_TrickShot		SpecialToHitCalc;
	local X2Condition_DP_TrickShot			TrickShotCondition;

	Template = class'X2Ability_AkimboAbilitySet'.static.SingleShot('DP_TrickShot', "DualRight");

	Template.IconImage = "img:///WP_Akimbo.UIIcons.TrickShot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';

	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bAllowCrit = true;
	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).BuiltInCritMod = default.TRICK_SHOT_CRIT_CHANCE_BONUS;
	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bIgnoreCoverBonus = true;
	
	if(default.TRICK_SHOT_USES_SPECIAL_AIM)	//not sure this works
	{
		SpecialToHitCalc = new class'X2AbilityToHitCalc_TrickShot';	//custom aim table - does not benefit from weapon range bonuses
		SpecialToHitCalc.bAllowCrit = true;
		SpecialToHitCalc.BuiltInCritMod = default.TRICK_SHOT_CRIT_CHANCE_BONUS;
		SpecialToHitCalc.bIgnoreCoverBonus = true;
		Template.AbilityToHitCalc = SpecialToHitCalc;
	}

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
	//ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
	Template.AbilityCosts.AddItem(ActionPointCost);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.DisorientedName, 'AA_UnitIsDisoriented');
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	if(default.TRICK_SHOT_ONLY_AGAINST_COVER)
	{
		TrickShotCondition = new class'X2Condition_DP_TrickShot';
		Template.AbilityTargetConditions.AddItem(TrickShotCondition);
	}

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AdditionalAbilities.AddItem('DP_DualPistols_TrickShotPassive');

	return Template;
}

static function X2AbilityTemplate Create_DP_TrickLegShotDamagePassive()
{
	local X2AbilityTemplate             Template;
	local X2Effect_DP_DamageModifier	DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_DualPistols_TrickShotPassive');

	Template.IconImage = "img:///WP_Akimbo.UIIcons.DualPistols";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;
	Template.bUniqueSource = true;

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');

	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bDontDisplayInAbilitySummary = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//	Damage modifier for Leg Shot and Trick Shot
	DamageEffect = new class'X2Effect_DP_DamageModifier';
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(DamageEffect);

	//DPEffect = new class'X2Effect_DualPistolBonus';	//have this prepped in case I want Akimbo to have a passive stat bonus
	//DPEffect.BuildPersistentEffect(1, true);
	//Template.AddTargetEffect(DPEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate Create_DP_BulletTime()	//this ability doesn't have to do anything
{															//ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime') in other abilities will check if the soldier has this ability and act accordingly
	local X2AbilityTemplate Template;

	Template = PurePassive('DP_BulletTime', "img:///WP_Akimbo.UIIcons.BulletTime", false, 'eAbilitySource_Perk', true);

	return Template;
}

static function X2AbilityTemplate Create_GunKata_Passive()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ForceDodge					ForceDodgeEffect;
	local X2Effect_DP_GunKata					GunKataEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_GunKata');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///WP_Akimbo.UIIcons.GunKata";

	Template.ConcealmentRule = 	eConceal_Always;            //  Always retain Concealment
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	
	//dodge enemy shots at the cost of reserved action points
	ForceDodgeEffect = new class'X2Effect_ForceDodge';
	ForceDodgeEffect.BuildPersistentEffect(1, true, false, false);
	ForceDodgeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(ForceDodgeEffect);

	//	Grants an extra Overwatch AP after using Overwatch-like abilities.
	GunKataEffect = new class'X2Effect_DP_GunKata';
	GunKataEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddShooterEffect(GunKataEffect);

	Template.bCrossClassEligible = default.GUN_KATA_IS_AWC; //makes this ability available to other classes as an AWC perk. 
	Template.AbilityPointCost = 15;
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = none;
	return Template;
}

static function X2AbilityTemplate Create_DP_SpinningReload_Passive()	//this ability exists just to have an icon in lower left corner of the tactical to remind the soldier has Spinning Reload
{
	local X2AbilityTemplate                 Template;
	local X2Effect_SpinningReloadAP			Effect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_SpinningReload_Passive');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///WP_Akimbo.UIIcons.SpinningReload";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	Effect = new class'X2Effect_SpinningReloadAP';
	Effect.BuildPersistentEffect(1, true);
	Effect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddShooterEffect(Effect);
	
	Template.bCrossClassEligible = default.SPINNING_RELOAD_IS_AWC; //makes this ability available to other classes as an AWC perk. 
	Template.AbilityPointCost = 15;

	Template.AdditionalAbilities.AddItem('DP_SpinningReload_EOT');
	Template.AdditionalAbilities.AddItem('DP_SpinningReload_Reactive');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

//	This ability skips visualization for some reason
static function X2AbilityTemplate Create_DP_SpinningReload_Reactive()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2AbilityTrigger_EventListener	TurnEndTrigger;
	local X2Condition_DP_AmmoCondition		AmmoCondition;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_SpinningReload_Reactive');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

    Template.AbilityTargetStyle = default.SelfTarget;	//	must be able to target enemies in order to react to their movement, duh
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	

	AmmoCondition = new class'X2Condition_DP_AmmoCondition';	//this makes the ability trigger only when soldier has no ammo at all	
	AmmoCondition.NeedsReload = true;				
	Template.AbilityShooterConditions.AddItem(AmmoCondition);

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint);
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	//	Trigger on a special event that gets activated after a successful Gun Kata dodge or after Secondary Shot (patched in OPTC of this mod).
	Trigger = new class'X2AbilityTrigger_EventListener';		//trigger on a dodge - probably will never happen in actual game
	Trigger.ListenerData.EventID = 'DP_SpinningReload_Reactive';//since you need to get shot while having 0 ammo and still have at least 2 Overwatch AP remaining
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	TurnEndTrigger = new class'X2AbilityTrigger_EventListener';	//activate automatically if we ended turn with no ammo
	TurnEndTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	TurnEndTrigger.ListenerData.EventID = 'PlayerTurnEnded';
	TurnEndTrigger.ListenerData.Filter = eFilter_Player;
	TurnEndTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(TurnEndTrigger);

	Template.AddShooterEffect(new class'X2Effect_DPReloadEffect');

	Template.bSkipExitCoverWhenFiring  = true;
	Template.CustomSelfFireAnim = 'HL_SpinningReload';
	Template.CustomFireAnim = 'HL_SpinningReload';
	Template.ActivationSpeech = 'Reloading';

	Template.CinescriptCameraType="GenericAccentCam";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	

	return Template;
}

static function X2AbilityTemplate Create_DP_SpinningReload_EOT() //This ability is the auotomatic reload that triggers at the beginning of player's turn
{																//if there are still some Overwatch Action Points remaining from the previous turn
	local X2AbilityTemplate                 Template;
	local X2Effect_DPReloadEffect			DPReload;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2Condition_DP_AmmoCondition		AmmoCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_SpinningReload_EOT');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

    Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';	//imagine my surprise that it just werks
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint);
	ReserveActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);

	AmmoCondition = new class'X2Condition_DP_AmmoCondition';
	AmmoCondition.ExactMatch = false;
	AmmoCondition.WantsReload = true;
	Template.AbilityShooterConditions.AddItem(AmmoCondition);

	Trigger = new class'X2AbilityTrigger_EventListener';	
	Trigger.ListenerData.EventID = 'PlayerTurnBegun';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	DPReload = new class 'X2Effect_DPReloadEffect';
	Template.AddShooterEffect(DPReload);

	Template.bSkipExitCoverWhenFiring  = true;
	Template.CustomFireAnim = 'HL_Reload';
	Template.ActivationSpeech = 'Reloading';

	Template.CinescriptCameraType = "GenericAccentCam";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate Create_DP_Quicksilver()
{
	local X2AbilityTemplate					Template;
	local X2Effect_ModifyReactionFire		ReactionFire;
	local X2Effect_DP_Quicksilver			QuicksilverEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_Quicksilver');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///WP_Akimbo.UIIcons.Quicksilver";

	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	//Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');	
	//this will make sure tha aim/crit bonus is provided only for Dual Pistols. Otherwise it would be directly superior to CuP in RPGO.
	//edit: reworked to not give crit on overwatch

	ReactionFire = new class'X2Effect_ModifyReactionFire';
	ReactionFire.bAllowCrit = false;
	ReactionFire.ReactionModifier = default.QUICKSILVER_AIM_BONUS;
	ReactionFire.BuildPersistentEffect(1, true, true, true);
	ReactionFire.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddShooterEffect(ReactionFire);

	QuicksilverEffect = new class'X2Effect_DP_Quicksilver';
	QuicksilverEffect.BuildPersistentEffect(1, true, false);
	Template.AddShooterEffect(QuicksilverEffect);

	Template.bCrossClassEligible = default.QUICKSILVER_IS_AWC;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate Create_DP_Unload()	
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_Shredder			        WeaponDamageEffect;
	local X2AbilityMultiTarget_BurstFire    BurstFireMultiTarget;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitEffects			SuppressedCondition;

	Template = class'X2Ability_AkimboAbilitySet'.static.SingleShot('DP_Unload', "DualRight");

	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bAllowCrit = false;
	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).BuiltInHitMod = default.UNLOAD_AIM_PENALTY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	X2AbilityCost_Ammo(Template.AbilityCosts[0]).iAmmo = 3;

	Template.IconImage = "img:///WP_Akimbo.UIIcons.Unload";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.DisorientedName, 'AA_UnitIsDisoriented');
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.UNLOAD_ACTION_POINT_COST;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
	//ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
	Template.AbilityCosts.AddItem(ActionPointCost);	

	WeaponDamageEffect = new class'X2Effect_Shredder';
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	
	BurstFireMultiTarget = new class'X2AbilityMultiTarget_BurstFire';
	BurstFireMultiTarget.NumExtraShots = 2;
	Template.AbilityMultiTargetStyle = BurstFireMultiTarget;

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.UNLOAD_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.ActivationSpeech = 'FanFire';
	Template.CustomFireAnim = 'FF_FireMultiShotConv';

	Template.DamagePreviewFn = UnloadDamagePreview;

	return Template;
}


// =======================================================================
// =======================================================================
//								SCRAPPER ABILITY SET
// =======================================================================
// =======================================================================

static function X2AbilityTemplate Create_DP_PistolWhip()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	//just testing
	//local X2Effect_Persistent				UnconsciousEffect;
	//local X2Effect_Knockback				KnockbackEffect;
	//end of testing

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_PistolWhip', "DualRight");

	Template.IconImage = "img:///WP_Akimbo.UIIcons.PistolWhip";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.DamagePreviewFn = PistolWhipDamagePreview;

	// just testing
	/*
	Template.CustomFireAnim = 'MV_Dive2CoverA';
	Template.CustomFireKillAnim = 'MV_Dive2CoverA';
	Template.CustomMovingFireAnim = 'MV_Dive2CoverA';
	Template.CustomMovingFireKillAnim = 'MV_Dive2CoverA';
	Template.CustomMovingTurnLeftFireAnim = 'MV_Dive2CoverA';
	Template.CustomMovingTurnLeftFireKillAnim = 'MV_Dive2CoverA';
	Template.CustomMovingTurnRightFireAnim = 'MV_Dive2CoverA';
	Template.CustomMovingTurnRightFireKillAnim = 'MV_Dive2CoverA';

	UnconsciousEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
	UnconsciousEffect.bRemoveWhenSourceDies = false;
	Template.AddTargetEffect(UnconsciousEffect);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 1;
	KnockbackEffect.OnlyOnDeath = false;
	Template.AddTargetEffect(KnockbackEffect);*/
	//end of testing

	//Template.AdditionalAbilities.AddItem('DP_BonusMeleeAim');
	Template.AdditionalAbilities.AddItem('DP_PistolWhipSecondary');

	Template.PostActivationEvents.AddItem('DP_PistolWhipSecondary');
	Template.PostActivationEvents.AddItem('DP_TakeInitiativeStrike');

	return Template;
}

static function X2AbilityTemplate Create_DP_PistolWhipSecondary()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	AbilityTrigger;

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_PistolWhipSecondary', "DualLeft");

	AbilityTrigger = new class'X2AbilityTrigger_EventListener';
	AbilityTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	AbilityTrigger.ListenerData.EventID = 'DP_PistolWhipSecondary';
	AbilityTrigger.ListenerData.Filter = eFilter_Unit;
	AbilityTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(AbilityTrigger);

	return Template;
}

static function X2AbilityTemplate Create_DP_BonusMeleeAim()
{
	local X2AbilityTemplate					Template;
	local X2Effect_ToHitModifier            HitModEffect;
	local X2Effect_DP_PistolWhipCost		DPEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_BonusMeleeAim');
	Template.IconImage = "img:///WP_Akimbo.UIIcons.DP_MeleeAim";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');

	HitModEffect = new class'X2Effect_ToHitModifier';
	HitModEffect.AddEffectHitModifier(eHit_Success, default.PISTOL_WHIP_MELEE_AIM_BONUS, Template.LocFriendlyName, , true, false, true, true);
	HitModEffect.BuildPersistentEffect(1, true, false, false);
	HitModEffect.EffectName = 'PistolWhipAim';
	Template.AddTargetEffect(HitModEffect);

	DPEffect = new class'X2Effect_DP_PistolWhipCost';	//this effect makes Pistol Whip not consume all action points when used against enemy within 1 tile
	DPEffect.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(DPEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate Create_DP_TakeInitiative()
{
	local X2AbilityTemplate                 Template;

	Template = PurePassive('DP_TakeInitiative', "img:///WP_Akimbo.UIIcons.TakeInitiative", false, 'eAbilitySource_Perk');

	Template.PrerequisiteAbilities.AddItem('DP_PistolWhip');

	Template.AdditionalAbilities.AddItem('DP_TakeInitiativeStrike');
	Template.AdditionalAbilities.AddItem('DP_TakeInitiativeStrikeLeft');

	return Template;
}

static function X2AbilityTemplate Create_DP_TakeInitiativeStrike()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	AbilityTrigger;
	local X2Condition_UnitProperty			AdjacencyCondition;	
	local X2Effect_Persistent               BladestormTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource BladestormTargetCondition;

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_TakeInitiativeStrike', "Right");
	Template.CustomFireAnim = 'FF_MeleeSingleRightFaster';
	Template.CustomFireKillAnim = 'FF_MeleeSingleRightFasterKill';
	X2AbilityToHitCalc_DPMelee(Template.AbilityToHitCalc).bReactionFire = true;

	AbilityTrigger = new class'X2AbilityTrigger_EventListener';
	AbilityTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	AbilityTrigger.ListenerData.EventID = 'DP_TakeInitiativeStrike';
	AbilityTrigger.ListenerData.Filter = eFilter_Unit;
	AbilityTrigger.ListenerData.EventFn = TakeInitiativeListener;
	Template.AbilityTriggers.AddItem(AbilityTrigger);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

	AdjacencyCondition = new class'X2Condition_UnitProperty'; // Target Conditions - can target enemies within 1.5 tiles
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);

	BladestormTargetEffect = new class'X2Effect_Persistent';
	BladestormTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	BladestormTargetEffect.EffectName = 'BladestormTarget';	//we don't care about effect name, since condition will check who applied it, so it won't interfere with actual Bladestorms from other soldiers
	BladestormTargetEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(BladestormTargetEffect);
	
	BladestormTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	BladestormTargetCondition.AddExcludeEffect('BladestormTarget', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(BladestormTargetCondition);

	//Template.bSkipExitCoverWhenFiring  = false;	//when commented out, everything works, except soldier doesn't turn to next target (same when = true). when = false soldier teleports at ability's end

	Template.BuildVisualizationFn = TakeInitiative_BuildVisualization;
	Template.MergeVisualizationFn = SequentialShot_MergeVisualization;

	Template.PostActivationEvents.AddItem('DP_TakeInitiativeStrikeLeft');

	return Template;
}
static function X2AbilityTemplate Create_DP_TakeInitiativeStrikeLeft()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	AbilityTrigger;
	local X2Condition_UnitProperty			AdjacencyCondition;	
	local X2Effect_Persistent               BladestormTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource BladestormTargetCondition;

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_TakeInitiativeStrikeLeft', "Left");
	X2AbilityToHitCalc_DPMelee(Template.AbilityToHitCalc).bReactionFire = true;

	AbilityTrigger = new class'X2AbilityTrigger_EventListener';
	AbilityTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	AbilityTrigger.ListenerData.EventID = 'DP_TakeInitiativeStrike';
	AbilityTrigger.ListenerData.Filter = eFilter_Unit;
	AbilityTrigger.ListenerData.EventFn = TakeInitiativeListener;
	Template.AbilityTriggers.AddItem(AbilityTrigger);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	AdjacencyCondition = new class'X2Condition_UnitProperty'; // Target Conditions - can target enemies within 1.5 tiles
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);

	BladestormTargetEffect = new class'X2Effect_Persistent';
	BladestormTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	BladestormTargetEffect.EffectName = 'BladestormTarget2';
	BladestormTargetEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(BladestormTargetEffect);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	
	BladestormTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	BladestormTargetCondition.AddExcludeEffect('BladestormTarget2', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(BladestormTargetCondition);

	Template.MergeVisualizationFn = SequentialShot_MergeVisualization;
	Template.BuildVisualizationFn = TakeInitiative_BuildVisualization;

	Template.PostActivationEvents.AddItem('DP_TakeInitiativeStrike');

	return Template;
}

static function X2AbilityTemplate Create_DP_CQCSupremacy()
{
	local X2AbilityTemplate                 Template;

	Template = PurePassive('DP_CQCSupremacy', "img:///WP_Akimbo.UIIcons.CQCSupremacy", false, 'eAbilitySource_Perk');

	Template.AdditionalAbilities.AddItem('DP_CQCSupremacyAttack');
	Template.AdditionalAbilities.AddItem('DP_CQCSupremacyAttackSecondary');

	return Template;
}


static function X2AbilityTemplate Create_DP_CQCSupremacyAttack()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	Trigger;
	local X2Effect_Persistent               CQCSupremacyTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource CQCSupremacyTargetCondition;
	local X2Condition_UnitProperty          SourceNotConcealedCondition;
	local X2Condition_Visibility			TargetVisibilityCondition;
	local X2Condition_UnitEffects			UnitEffectsCondition;
	local X2Condition_UnitProperty			ExcludeSquadmatesCondition;
	local X2Condition_UnitProperty			AdjacencyCondition;	

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_CQCSupremacyAttack', "DualRight");

	// Mr. Nice: It's not a move ending melee
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Mr. Nice: No BuildInterruptGameStateFn for non-activated abilities
	Template.BuildInterruptGameStateFn = none;

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	X2AbilityToHitCalc_DPMelee(Template.AbilityToHitCalc).bReactionFire = true;
	//  trigger on movement
	/*
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);
	*/
	//Trigger on movement - interrupt the move

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	//  trigger on an attack
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalAttackListener;
	Template.AbilityTriggers.AddItem(Trigger);

	//  it may be the case that enemy movement caused a concealment break, which made Bladestorm applicable - attempt to trigger afterwards
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitConcealmentBroken';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'X2Ability_RangerAbilitySet'.static.BladestormConcealmentListener;
	Trigger.ListenerData.Priority = 55;
	Template.AbilityTriggers.AddItem(Trigger);

	// Target Conditions
	AdjacencyCondition = new class'X2Condition_UnitProperty';
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);
	
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());	//this PROBABLY excludes enemies with shadowstep and similar stuff

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	// Adding exclusion condition to prevent friendly CQCSupremacy fire when panicked.
	ExcludeSquadmatesCondition = new class'X2Condition_UnitProperty';
	ExcludeSquadmatesCondition.ExcludeSquadmates = true;
	//ExcludeSquadmatesCondition.IsScampering = false; //so it doesn't trigger against enemies if you pulled an enemy pod by moving near them
	Template.AbilityTargetConditions.AddItem(ExcludeSquadmatesCondition);

	//Don't trigger when the source is concealed
	SourceNotConcealedCondition = new class'X2Condition_UnitProperty';
	SourceNotConcealedCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(SourceNotConcealedCondition);

	// Don't trigger if the unit has vanished
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddExcludeEffect('Vanish', 'AA_UnitIsConcealed');
	UnitEffectsCondition.AddExcludeEffect('VanishingWind', 'AA_UnitIsConcealed');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	CQCSupremacyTargetEffect = new class'X2Effect_Persistent';	//makes the TakeInitiative ignore enemy that was already struck by CQC Supremacy
	CQCSupremacyTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	CQCSupremacyTargetEffect.EffectName = 'BladestormTarget';
	CQCSupremacyTargetEffect.bApplyOnMiss = true; //Only one chance, even if you miss (prevents crazy flailing counter-attack chains with a Muton, for example)
	Template.AddTargetEffect(CQCSupremacyTargetEffect);

	CQCSupremacyTargetEffect = new class'X2Effect_Persistent';
	CQCSupremacyTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	CQCSupremacyTargetEffect.EffectName = 'BladestormTarget2';
	CQCSupremacyTargetEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(CQCSupremacyTargetEffect);
	
	CQCSupremacyTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	CQCSupremacyTargetCondition.AddExcludeEffect('BladestormTarget', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(CQCSupremacyTargetCondition);

	CQCSupremacyTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	CQCSupremacyTargetCondition.AddExcludeEffect('BladestormTarget2', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(CQCSupremacyTargetCondition);

	Template.PostActivationEvents.AddItem('DP_CQCSupremacyAttackSecondary');
	Template.PostActivationEvents.AddItem('DP_SpinningReload_Reactive');	//	adding it here for an Edge case if you Bladestorm someone without having ammo
	return Template;
}

static function X2AbilityTemplate Create_DP_CQCSupremacyAttackSecondary()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger_EventListener	AbilityTrigger;

	Template = class'X2Ability_AkimboAbilitySet'.static.PistolWhip('DP_CQCSupremacyAttackSecondary', "DualLeft");
	X2AbilityToHitCalc_DPMelee(Template.AbilityToHitCalc).bReactionFire = true;

	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());	//this PROBABLY excludes enemies with shadowstep and similar stuff

	AbilityTrigger = new class'X2AbilityTrigger_EventListener';
	AbilityTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	AbilityTrigger.ListenerData.EventID = 'DP_CQCSupremacyAttackSecondary';
	AbilityTrigger.ListenerData.Filter = eFilter_Unit;
	AbilityTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(AbilityTrigger);

	return Template;
}

static function X2AbilityTemplate  Create_DP_ElectrifiedSpikes()	//this perk doesn't do anything by itself. 
{																	//Pistol Whip melee attack template tries to apply DP_ElectrifiedSpikes effect, which won't do anything unless the soldier has this perk
	local X2AbilityTemplate                 Template;

	Template = PurePassive('DP_ElectrifiedSpikes', "img:///WP_Akimbo.UIIcons.ElectrifiedSpikes", false, 'eAbilitySource_Perk', true);

	return Template;
}

static function name DP_ElectrifiedSpikes_Disorient_ChanceCheck(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit, SourceUnit;
	local UnitValue PistolWhipValue;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	//only if the soldier has the relevant passive ability and the enemy is not already disoriented or stunned...
	if (!SourceUnit.HasSoldierAbility('DP_ElectrifiedSpikes')) return 'AA_NoRelevantPassive';
	if (TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DisorientedName)) return 'AA_EnemyAlreadyDisoriented';
	if (TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.StunnedName)) return 'AA_EnemyStunned';

	TargetUnit.GetUnitValue('DP_PistolWhip', PistolWhipValue);			//this unit value is used to avoid one hit being able to disorient and stun at the same time
	if (PistolWhipValue.fValue == 0) return 'AA_UnitValueNotPresent';	//normal melee attacks apply it, while chance checks consume it
	else
	{
		TargetUnit.SetUnitFloatValue('DP_PistolWhip', 0, eCleanup_BeginTurn);
		//... we get to roll a chance to disorient the enemy.
		if (`SYNC_RAND_STATIC(100) <= default.ELECTRIFIED_SPIKES_DISORIENT_CHANCE) return 'AA_Success';
	}
	return 'AA_EffectChanceFailed';
}

static function name DP_ElectrifiedSpikes_Stun_ChanceCheck(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit, SourceUnit;
	local UnitValue PistolWhipValue;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	//only if the soldier has the relevant passive ability and the enemy is not already stunned, but already disoriented
	if (!SourceUnit.HasSoldierAbility('DP_ElectrifiedSpikes')) return 'AA_NoRelevantPassive';
	if (TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.StunnedName)) return 'AA_EnemyAlreadyStunned';
	if (TargetUnit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DisorientedName)) 
	{
		TargetUnit.GetUnitValue('DP_PistolWhip', PistolWhipValue);
		if (PistolWhipValue.fValue == 0) return 'AA_UnitValueNotPresent';
		else
		{
			TargetUnit.SetUnitFloatValue('DP_PistolWhip', 0, eCleanup_BeginTurn);
			//... we get to roll a chance to stun the enemy.
			if (`SYNC_RAND_STATIC(100) <= default.ELECTRIFIED_SPIKES_STUN_CHANCE) return 'AA_Success';
		}
	}
	return 'AA_EffectChanceFailed';
}

static function X2AbilityTemplate Create_DP_Checkmate()
{
	local X2AbilityTemplate                 Template;

	local X2Effect_Shredder			        WeaponDamageEffect;
	local X2Condition_DP_CheckmateCondition	CheckmateCondition;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_UnitProperty			AdjacencyCondition;	
	local X2AbilityToHitCalc_StandardAim	ToHitCalc;
	local X2AbilityCost_Ammo             AmmoCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_Checkmate');

	Template.bDontDisplayInAbilitySummary = false;
	Template.IconImage = "img:///WP_Akimbo.UIIcons.Checkmate";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	//Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                     // color of the icon
	//Template.bDisplayInUITooltip = true;
	//Template.bDisplayInUITacticalText = true;

	Template.bAllowFreeFireWeaponUpgrade = true;  //Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects
	Template.bAllowAmmoEffects = true;		//bonus effects from utility item ammo
	Template.bAllowBonusWeaponEffects = true;	//bonus effects from weapon itself, e.g. bonus crit from Shadowkeeper, maybe from scopes too

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.bAllowCrit = true;
	ToHitCalc.bHitsAreCrits = true;
	ToHitCalc.bGuaranteedHit = true;
	Template.AbilityToHitCalc = ToHitCalc;

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
	//ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;	// Only at single targets that are in range.
	AdjacencyCondition = new class'X2Condition_UnitProperty';
	AdjacencyCondition.RequireWithinRange = true;
	AdjacencyCondition.WithinRange = 144; //1.5 tiles in Unreal units, allows attacks on the diag
	Template.AbilityTargetConditions.AddItem(AdjacencyCondition);

	CheckmateCondition = new class'X2Condition_DP_CheckmateCondition';	//only usable against stunned, panicked or unconscious 
	Template.AbilityTargetConditions.AddItem(CheckmateCondition);

	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// Targeting Details
	// Can only shoot visible enemies
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	//Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');
	
	WeaponDamageEffect = new class'X2Effect_Shredder';	//bonus damage is handled by always active persistent effect DP_CheckmateDamage
	WeaponDamageEffect.bAllowFreeKill = true;	//allow Repeater instakill
	Template.AddTargetEffect(WeaponDamageEffect);
	
	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 1;
	Template.AddTargetEffect(KnockbackEffect);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	//Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';

	//Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.CustomFireAnim = 'Checkmate';
	Template.CustomFireKillAnim = 'Checkmate';
	Template.ActivationSpeech = 'Reaper';
	//Template.bSkipExitCoverWhenFiring = true; looks worse

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	
	Template.AdditionalAbilities.AddItem('DP_Checkmate_Passive');

	Template.bCrossClassEligible = default.CHECKMATE_IS_AWC;

	return Template;
}

static function X2AbilityTemplate Create_DP_CheckmatePassive()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_DP_CheckmateDamage		CheckmateDamageEffect;

	Template = PurePassive('DP_Checkmate_Passive', "img:///WP_Akimbo.UIIcons.Checkmate", false, 'eAbilitySource_Perk');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.bDontDisplayInAbilitySummary = true;

	CheckmateDamageEffect = new class'X2Effect_DP_CheckmateDamage';
	CheckmateDamageEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(CheckmateDamageEffect);

	return Template;
}

static function X2AbilityTemplate Create_DP_LimitBreak()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_DP_LimitBreak			LimitBreakEffect;
	local X2Effect_SetUnitValue             UnitValueEffect;
	local X2AbilityCost_Charges				ChargeCost;
	local X2AbilityCharges					Charges;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_LimitBreak');

	// Icon Properties
	Template.IconImage = "img:///WP_Akimbo.UIIcons.LimitBreak";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon
	Template.ConcealmentRule = eConceal_Never; //breaks concealment
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);	

	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = 1;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	LimitBreakEffect = new class 'X2Effect_DP_LimitBreak';
	LimitBreakEffect.BuildPersistentEffect (1, false, false, false, eGameRule_PlayerTurnBegin);
	LimitBreakEffect.SetDisplayInfo(ePerkBuff_Bonus,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	Template.AddTargetEffect(LimitBreakEffect);

	UnitValueEffect = new class'X2Effect_SetUnitValue';	//this unit value tracks the amount of actions granted by Limit Break
	UnitValueEffect.UnitName = class'X2Effect_DP_LimitBreak'.default.BonusActionsValue;
	UnitValueEffect.CleanupType = eCleanup_BeginTactical;
	UnitValueEffect.NewValueToSet = -1;					//we set a negative value because Limit Break consumes actions points, and will regrant one action point immediately. 
	Template.AddTargetEffect(UnitValueEffect);			//it's easier to track from 0, since this way we'll be counting actions taken after Limit Break was activated.

	UnitValueEffect = new class'X2Effect_SetUnitValue';	//resetting the amount of recorded damage the unit has taken
	UnitValueEffect.UnitName = 'DP_LimitBreak_SoakedDamage';
	UnitValueEffect.CleanupType = eCleanup_BeginTactical;
	UnitValueEffect.NewValueToSet = 0;	
	Template.AddTargetEffect(UnitValueEffect);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	

	Template.bCrossClassEligible = default.LIMIT_BREAK_IS_AWC;	//makes this ability available to all classes as an AWC perk
	Template.AbilityPointCost = 25;

	Template.AdditionalAbilities.AddItem('DP_LimitBreak_SelfDamage');
	Template.AdditionalAbilities.AddItem('DP_LimitBreak_SoakDamage');
	Template.AdditionalAbilities.AddItem('DP_LimitBreak_DealSoakedDamage');
	return Template;
}

static function X2AbilityTemplate Create_DP_LimitBreak_SelfDamage()		//this ability will deal damage to the soldier when he pushes Limit Break too far
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger_EventListener	EventTrigger;
	local X2Effect_DP_SelfDamage			SelfDamage;
	local X2Effect_Persistent				UnconsciousEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_LimitBreak_SelfDamage');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'DP_LimitBreak_SelfDamage';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	UnconsciousEffect = class'X2StatusEffects'.static.CreateUnconsciousStatusEffect();
	UnconsciousEffect.bRemoveWhenSourceDies = true;
	UnconsciousEffect.ApplyChanceFn = DP_LimitBreak_Unconscious_ChanceCheck;
	Template.AddTargetEffect(UnconsciousEffect);

	SelfDamage = new class'X2Effect_DP_SelfDamage';
	SelfDamage.bBypassShields = true;
	SelfDamage.bIgnoreArmor = true;
	Template.AddTargetEffect(SelfDamage);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	

	return Template;
}

static function X2AbilityTemplate Create_DP_LimitBreak_SoakDamage()	//this ability triggers whenever the soldier is affected by Limit Break and takes damage from any source
{																	//it will trigger a special Event Listener which will restore soldier's health and record how much damage was supposed to be taken
	local X2AbilityTemplate                 Template;				
	local X2AbilityTrigger_EventListener	EventTrigger;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_LimitBreak_SoakDamage');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = SoakDamageListener;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	

	return Template;
}

static function EventListenerReturn SoakDamageListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit;
	local UnitValue LastEffectDamage, DamageThisTurn;
	local UnitValue DamageSoaked;
	local int Health;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit != none)
	{
		if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_DP_LimitBreak'.default.EffectName))	//making sure the ability triggers only when there's Limit Break effect on the soldier
		{
			SourceUnit.GetUnitValue('LastEffectDamage', LastEffectDamage);
			SourceUnit.GetUnitValue('DamageThisTurn', DamageThisTurn);
	
			if(default.ENABLE_LOGGING) `Log("IRIDAR LastEffectDamage: " @ LastEffectDamage.fValue,, 'AkimboClass');
			if(default.ENABLE_LOGGING) `Log("IRIDAR DamageThisTurn: " @ DamageThisTurn.fValue,, 'AkimboClass');
			if(default.ENABLE_LOGGING) `Log("IRIDAR Triggering ability: " @ AbilityContext.InputContext.AbilityTemplateName,, 'AkimboClass');	//EventData creates none

			if(AbilityContext.InputContext.AbilityTemplateName != 'DP_LimitBreak_SelfDamage' && AbilityContext.InputContext.AbilityTemplateName != 'DP_LimitBreak_DealSoakedDamage')
			{
				if(default.ENABLE_LOGGING) `Log("IRIDAR Triggered NOT by Self Damage" ,, 'AkimboClass');

				Health = SourceUnit.GetCurrentStat(eStat_HP);
				if (Health > 0)	//if the unit wasn't killed by the last attack
				{
					if(default.ENABLE_LOGGING) `Log("IRIDAR Restoring Health to: " @ LastEffectDamage.fValue,, 'AkimboClass');
					SourceUnit.ModifyCurrentStat(eStat_HP, LastEffectDamage.fValue);
				}

				SourceUnit.GetUnitValue('DP_LimitBreak_SoakedDamage', DamageSoaked);
				SourceUnit.SetUnitFloatValue('DP_LimitBreak_SoakedDamage', DamageSoaked.fValue + LastEffectDamage.fValue, eCleanup_BeginTactical);
			}
		}
	}
	return ELR_NoInterrupt;
}

static function name DP_LimitBreak_Unconscious_ChanceCheck(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit UnitState;
	local UnitValue BonusActions;
	local int ChanceToStayConscious;

	if(default.ENABLE_LOGGING) `Log("IRIDAR LimitBreak_Unconscious_ChanceCheck Triggered",, 'AkimboClass');

	UnitState = XComGameState_Unit(kNewTargetState);
	UnitState.GetUnitValue(class'X2Effect_DP_LimitBreak'.default.BonusActionsValue, BonusActions);

	if(default.ENABLE_LOGGING) `Log("IRIDAR Bonus Actions taken: " @ BonusActions.fValue,, 'AkimboClass');

	if(default.ConsciousChance.Length > 0)
    {
        if(BonusActions.fValue < default.ConsciousChance.Length)
        {
            ChanceToStayConscious = default.ConsciousChance[BonusActions.fValue];
        }
        else //Use last value
        {
            ChanceToStayConscious = default.ConsciousChance[default.ConsciousChance.Length - 1];
        }
		if(default.ENABLE_LOGGING) `Log("IRIDAR Chance to stay awake: " @ ChanceToStayConscious,, 'AkimboClass');
		if (`SYNC_RAND_STATIC(100) > ChanceToStayConscious) return 'AA_Success';	//soldier will be knocked unconscious

	}

	return 'AA_EffectChanceFailed';
}

static function X2AbilityTemplate Create_DP_LimitBreak_DealSoakedDamage()	//this ability triggers when Limit Break falls off the soldier, applying damage that was soaked before
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger_EventListener	EventTrigger;
	local X2Effect_DP_SelfDamage			SelfDamage;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_LimitBreak_DealSoakedDamage');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = 'DP_LimitBreak_DealSoakedDamage';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(EventTrigger);

	SelfDamage = new class'X2Effect_DP_SelfDamage';
	SelfDamage.bBypassShields = true;
	SelfDamage.bIgnoreArmor = true;
	SelfDamage.DealSoakedDamage = true;
	Template.AddTargetEffect(SelfDamage);

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	

	return Template;
}


// **************************************************************************
// ***                    SUPPLEMENTAL ABILITIES                          ***
// **************************************************************************


static function X2AbilityTemplate Create_DP_LegShot()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2Effect_PersistentStatChange		MobilityDamageEffect;

	Template = class'X2Ability_AkimboAbilitySet'.static.SingleShot('DP_LegShot', "DualRight");

	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bAllowCrit = false; //cannot crit

	Template.IconImage = "img:///WP_Akimbo.UIIcons.LegShot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
	//ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
	Template.AbilityCosts.AddItem(ActionPointCost);

	MobilityDamageEffect = new class 'X2Effect_PersistentStatChange';
	MobilityDamageEffect.BuildPersistentEffect (1, false, false, false, eGameRule_PlayerTurnEnd);
	MobilityDamageEffect.SetDisplayInfo(ePerkBuff_Penalty,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	MobilityDamageEffect.AddPersistentStatChange (eStat_Mobility, -10);
	MobilityDamageEffect.DuplicateResponse = eDupe_Allow;
	MobilityDamageEffect.EffectName = 'LegShotEffect';
	Template.AddTargetEffect(MobilityDamageEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger); 

	Template.DamagePreviewFn = LegShotDamagePreview;

	Template.AdditionalAbilities.AddItem('DP_LegShotSecondary');
	Template.PostActivationEvents.AddItem('DP_LegShotSecondary');

	Template.AdditionalAbilities.AddItem('DP_DualPistols_TrickShotPassive');

	return Template;
}

static function X2AbilityTemplate Create_DP_LegShotSecondary()
{
	local X2AbilityTemplate	Template;
	local X2AbilityTrigger_EventListener    Trigger;
	local X2Effect_PersistentStatChange		MobilityDamageEffect;

	Template = class'X2Ability_AkimboAbilitySet'.static.SingleShot('DP_LegShotSecondary', "DualLeft");

	X2AbilityToHitCalc_StandardAim(Template.AbilityToHitCalc).bAllowCrit = false; //cannot crit

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'DP_LegShotSecondary';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(Trigger);

	MobilityDamageEffect = new class 'X2Effect_PersistentStatChange';
	MobilityDamageEffect.BuildPersistentEffect (1, false, false, false, eGameRule_PlayerTurnEnd);
	MobilityDamageEffect.SetDisplayInfo(ePerkBuff_Penalty,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	MobilityDamageEffect.AddPersistentStatChange (eStat_Mobility, -10);
	MobilityDamageEffect.DuplicateResponse = eDupe_Allow;
	MobilityDamageEffect.EffectName = 'LegShotEffect';
	Template.AddTargetEffect(MobilityDamageEffect);

	return Template;
}

/*
static function X2AbilityTemplate Create_DP_LegShot()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2Effect_DP_ApplySecondaryWeaponDamage	 WeaponDamageEffect2;
	local X2Effect_PersistentStatChange		MobilityDamageEffect;

	Template = class'X2Ability_AkimboAbilitySet'.static.SingleShot('DP_LegShot', "DualRight");

	X2AbilityToHitCalc_DPMelee(Template.AbilityToHitCalc).bAllowCrit = false; //cannot crit

	// Icon Properties
	Template.IconImage = "img:///WP_Akimbo.UIIcons.LegShot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';                                       // color of the icon

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('DP_BulletTime');
	Template.AbilityCosts.AddItem(ActionPointCost);

	MobilityDamageEffect = new class 'X2Effect_PersistentStatChange';
	MobilityDamageEffect.BuildPersistentEffect (1, false, false, false, eGameRule_PlayerTurnEnd);
	MobilityDamageEffect.SetDisplayInfo(ePerkBuff_Penalty,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	MobilityDamageEffect.AddPersistentStatChange (eStat_Mobility, -20);
	MobilityDamageEffect.DuplicateResponse = eDupe_Allow;
	MobilityDamageEffect.EffectName = 'IronCurtainEffect';
	Template.AddTargetEffect(MobilityDamageEffect);

	WeaponDamageEffect2 = new class'X2Effect_DP_ApplySecondaryWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect2);

	return Template;	
}*/

static function X2AbilityTemplate Create_DP_DirtyKick()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityToHitCalc_DPMelee		StandardMelee;
	local X2Effect_Stunned					StunEffect;
	local X2AbilityCooldown                 Cooldown;
	local X2Condition_UnitProperty			UnitPropertyCondition;
	local X2Condition_UnitEffects			DisorientedCondition;
	//local X2Effect_ApplyWeaponDamage        WeaponDamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_DirtyKick');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///WP_Akimbo.UIIcons.DirtyKick";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	/*
	Template.bHideOnClassUnlock = false;
	Template.bUniqueSource = true;
	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
    Template.DisplayTargetHitChance = true;*/

	//Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
	//WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	//WeaponDamageEffect.bIgnoreBaseDamage = true;	
	//WeaponDamageEffect.ExtraDamageValue = 1;
	//Template.AddTargetEffect(WeaponDamageEffect);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.DIRTY_KICK_COOLDOWN;
	Template.AbilityCooldown = Cooldown;
	
	StandardMelee = new class'X2AbilityToHitCalc_DPMelee';
	Template.AbilityToHitCalc = StandardMelee;

	DisorientedCondition = new class'X2Condition_UnitEffects';			//CANNOT be used while disoriented or stunned
	DisorientedCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.DisorientedName, 'AA_UnitIsDisoriented');
	DisorientedCondition.AddExcludeEffect(class'X2AbilityTemplateManager'.default.StunnedName, 'AA_UnitIsStunned');
	Template.AbilityShooterConditions.AddItem(DisorientedCondition);

   // Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;
	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	// Target Conditions
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);
	// The Target must be alive and a humanoid
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeLargeUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	StunEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(3, 100); // # ACTIONS, % chance
	StunEffect.bRemoveWhenSourceDies = false;
	Template.AddTargetEffect(StunEffect);

	Template.ActivationSpeech = 'StunTarget';
	Template.SourceMissSpeech = 'SwordMiss';
	Template.bSkipMoveStop = false;
	Template.CustomFireAnim = 'DirtyKick';
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.bSkipExitCoverWhenFiring = true;

	Template.bCrossClassEligible = default.DIRTY_KICK_IS_AWC;	//makes this available to all classes as an AWC perk
	Template.AbilityPointCost = 10;

    Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;

	Template.AdditionalAbilities.AddItem('DP_DirtyKick_Passive');

	return Template;
}

static function X2AbilityTemplate Create_DP_DirtyKick_Passive()	//this ability exists just to add an animset to make Dirty Kick play its animation when used by other classes
{
	local X2AbilityTemplate                 Template;
	local X2Effect_AdditionalAnimSets		AnimSetEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_DirtyKick_Passive');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("WP_OffhandPistol_CV.Anims.AS_DirtyKick");	//have to add an animset to make Spinning Reload play its animation even with other classes
	AnimSetEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(AnimSetEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate Create_DP_HuntersInstinct()
{
	local X2AbilityTemplate						Template;
	local X2Effect_DP_HuntersInstinct       DamageModifier;
	//local X2Effect_BonusWeaponDamage			DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DP_HuntersInstinct');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_forwardoperator";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	DamageModifier = new class'X2Effect_DP_HuntersInstinct';
	DamageModifier.BonusDamage = 1;
	DamageModifier.BuildPersistentEffect(1, true, true, true);
	DamageModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageModifier);

	//This doesn't work!
	//DamageEffect = new class'X2Effect_BonusWeaponDamage';
	//DamageEffect.BonusDmg = 10;
	//DamageEffect.BuildPersistentEffect(1, true, false, false);
	//DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	//Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

// **************************************************************************
// ***                            SHARED CODE                             ***
// **************************************************************************


//basic template for single shots that come from only one weapon, it has no triggers and no costs besides ammo
static function X2AbilityTemplate SingleShot(name TemplateName, string Hand)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo             AmmoCost;
	local X2Effect_Shredder			        WeaponDamageEffect;
	local X2Effect_Knockback				KnockbackEffect;
	local X2AbilityToHitCalc_StandardAim    ToHitCalc;
	local array<name>                       SkipExclusions;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	// Icon Properties
	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_standardpistol";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_PISTOL_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailableOrNoTargets;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';    // color of the icon
	Template.bHideOnClassUnlock = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.Hostility = eHostility_Offensive;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	AmmoCost = new class'X2AbilityCost_Ammo';	
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	//Mr. Nice: These two moved here so "dualleft" can change them
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	if (Hand == "Right")
	{
		Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
		Template.CustomFireAnim = 'FF_SingleShotRight';
		AmmoCost.iAmmo = 1;
	}
	if (Hand == "Left")
	{
		Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
		Template.CustomFireAnim = 'FF_SingleShotLeft';
		AmmoCost.iAmmo = 0;
	}
	if (Hand == "DualRight")
	{
		Template.CustomFireAnim = 'FF_DualShot';
		Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
		AmmoCost.iAmmo = 1;
	}
	if (Hand == "DualLeft")
	{
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
		Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
		//Don't skip the fire action, we want it to anchor the applydamage actions
		//Do skip exitcover & perk
		//Template.bSkipFireAction = true;
		Template.bSkipExitCoverWhenFiring=true;
		Template.bShowActivation = false;
		Template.bSkipPerkActivationActions=true;
		Template.MergeVisualizationFn = SharedAnimation_MergeVisualization;
		AmmoCost.iAmmo = 0;
		AmmoCost.bFreeCost = true;
		//Will be entirely contained within the first shots cinescript, an extra one will just get in the way
		Template.CinescriptCameraType = "";
		//Non-activated abilities sholdn't have this set;
		Template.BuildInterruptGameStateFn = none;
	}
	
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName); 	// Status condtions that do *not* prohibit this action.
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');
	// Targeting Details
	// Can only shoot visible enemies
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityCosts.AddItem(AmmoCost);
	 
	// Weapon Upgrade Compatibility
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;
	Template.bAllowFreeFireWeaponUpgrade = true;  //Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage); //guaranteed damage on missed shots attachment (stock)

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.AddTargetEffect(class'X2Ability_Chosen'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());

	WeaponDamageEffect = new class'X2Effect_Shredder';	//this will shred only if the soldier actually has the Shredder ability from AWC, otherwise it behaves identically to ApplyWeaponDamage
	WeaponDamageEffect.bAllowFreeKill = true;	//allow Repeater instakill
	Template.AddTargetEffect(WeaponDamageEffect);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 1;
	Template.AddTargetEffect(KnockbackEffect);

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.BuildNewGameStateFn = DualPistols_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	


	return Template;	
}

static function X2AbilityTemplate PistolWhip(name TemplateName, string Hand)
{
	local X2AbilityTemplate                 Template;
	local X2AbilityToHitCalc_DPMelee		StandardMelee;
	local array<name>                       SkipExclusions;
	local X2Effect_PersistentStatChange		DisorientedEffect;
	local X2Effect_Stunned					StunEffect;
	local X2Effect_SetUnitValue				UnitValueEffect;
	local X2Effect_DP_ElectrifiedSpikes		WeaponDamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.SourceMissSpeech = 'SwordMiss';
	
	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	StandardMelee = new class'X2AbilityToHitCalc_DPMelee';	//using a custom melee ToHitCalc to remove pistols' range bonuses from melee attacks
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);	//target conditions
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);		// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_DP_DualPistols');
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);				//can be used while burning, just like default sword ability
	Template.AddShooterEffectExclusions(SkipExclusions);

	//apply weapon damage replacement
	WeaponDamageEffect = new class'X2Effect_DP_ElectrifiedSpikes';
	WeaponDamageEffect.bAllowFreeKill = false;		//Repeater instakill
	Template.AddTargetEffect(WeaponDamageEffect); // this just deals damage by default, and shreds armor if the soldier has Electrified Spikes.
	
	Template.bAllowFreeFireWeaponUpgrade = false;	//pistol melee attacks are not intended to benefit from any weapon upgrades or ammo bonuses
	Template.bAllowAmmoEffects = false;				
	Template.bAllowBonusWeaponEffects = false;	

	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	DisorientedEffect.ApplyChanceFn = DP_ElectrifiedSpikes_Disorient_ChanceCheck;
	DisorientedEffect.iNumTurns = 1;
	DisorientedEffect.bRemoveWhenSourceDies = false;
	Template.AddTargetEffect(DisorientedEffect);

	StunEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100); // # ACTIONS, % chance
	StunEffect.bRemoveWhenSourceDies = false;
	StunEffect.ApplyChanceFn = DP_ElectrifiedSpikes_Stun_ChanceCheck;
	Template.AddTargetEffect(StunEffect);

	UnitValueEffect = new class'X2Effect_SetUnitValue';	//this unit value is consumed during Disorient and Stun chance checks
	UnitValueEffect.NewValueToSet = 1;
	UnitValueEffect.UnitName = 'DP_PistolWhip';
	UnitValueEffect.CleanupType = eCleanup_BeginTurn;
	Template.AddTargetEffect(UnitValueEffect);

	Template.bSkipMoveStop = false;	//whether the soldier should play stop animation before playing attack animation. most of the time requires a additional MV_ animations in order to not look weird.	

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	if (Hand == "DualRight")
	{
		Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
		Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
		Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
		Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;	

		Template.bSkipMoveStop = true;
		Template.CinescriptCameraType = "Ranger_Reaper";

		Template.CustomFireAnim = 'FF_MeleeNoWhack';
		Template.CustomFireKillAnim = 'FF_MeleeNoWhackKill';
		Template.CustomMovingFireAnim = 'MV_PistolWhip';
		Template.CustomMovingFireKillAnim = 'MV_PistolWhipKill';
		Template.CustomMovingTurnLeftFireAnim = 'MV_PistolWhip';
		Template.CustomMovingTurnLeftFireKillAnim = 'MV_PistolWhipKill';
		Template.CustomMovingTurnRightFireAnim = 'MV_PistolWhip';
		Template.CustomMovingTurnRightFireKillAnim = 'MV_PistolWhipKill';
	}
	if (Hand == "DualLeft")
	{
		Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
		Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
		Template.MergeVisualizationFn = SharedAnimation_MergeVisualization;
		//Don't skip the fire action, we want it to anchor the applydamage actions
		//Do skip exitcover & perk
		//Template.bSkipFireAction = true;
		Template.bSkipExitCoverWhenFiring = true;
		Template.bSkipPerkActivationActions=true;
		Template.bShowActivation = false;
	}
	if (Hand == "Right")
	{
		Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
		Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
		Template.CustomFireAnim = 'FF_MeleeSingleRight';
		Template.CustomFireKillAnim = 'FF_MeleeSingleRightKill';
		Template.CinescriptCameraType = "Ranger_Reaper";
	}
	if (Hand == "Left")
	{
		Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
		Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
		//Template.CustomFireAnim = 'CQCSupremacy';
		Template.CustomFireAnim = 'FF_MeleeSingleLeft';
		Template.CustomFireKillAnim = 'FF_MeleeSingleLeftKill';
		Template.CinescriptCameraType = "Ranger_Reaper";
	}
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

/*
Doesn't display crit damage. How to fix:
oh, you can pass crit info through the old system, but it's left blank by the original code, and hence by most DamagePreviewFn :stuck_out_tongue:
@Iridar the Copy Ninja your DamagePreviewFn returns MinDamagePreview and MaxDamagePreview
as full weapondamage structs, they can have the crit field filled in, and EI does use it if non-zero
It won't get "nice" labelling in the breakdown of course, since it doesn't know the source of it at all. Nonetheless, if you fill in the crit field of both with the total crit of the two weapons, it will at least show a representative value (even if it doesn't account for talon rounds and other effects, that's possible but is noticably more code :stuck_out_tongue: ). Breakdown entries it can't find a good label for get just labelled with the abilities friendly name. That looks ok in general, because usually "unlabelled" damage modifiers come from non-weapon abilities.
*/
//Thanks to Musashi for this
static function bool DualShotDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference DualSlashSecondaryRef;
	local XComGameState_Ability DualSlashSecondaryAbility;
	local XComGameStateHistory History;

	AbilityState.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	DualSlashSecondaryRef = AbilityOwner.FindAbility('DP_DualShotSecondary');
	DualSlashSecondaryAbility = XComGameState_Ability(History.GetGameStateForObjectID(DualSlashSecondaryRef.ObjectID));

	if (DualSlashSecondaryAbility != none)
	{
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}

	return true;
}

static function bool LegShotDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference DualSlashSecondaryRef;
	local XComGameState_Ability DualSlashSecondaryAbility;
	local XComGameStateHistory History;

	AbilityState.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	DualSlashSecondaryRef = AbilityOwner.FindAbility('DP_LegShotSecondary');
	DualSlashSecondaryAbility = XComGameState_Ability(History.GetGameStateForObjectID(DualSlashSecondaryRef.ObjectID));

	if (DualSlashSecondaryAbility != none)
	{
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}

	return true;
}

static function bool UnloadDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference DualSlashSecondaryRef;
	local XComGameState_Ability DualSlashSecondaryAbility;
	local XComGameStateHistory History;

	AbilityState.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	DualSlashSecondaryRef = AbilityOwner.FindAbility('PistolStandardShot_Secondary');
	DualSlashSecondaryAbility = XComGameState_Ability(History.GetGameStateForObjectID(DualSlashSecondaryRef.ObjectID));

	if (DualSlashSecondaryAbility != none)
	{
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}
	//	Hack hack hack
	//	can't be bothered to figure out why this damage preview is being called twice
	//	most likely AbilityState.NormalDamagePreview calls this function again
	//MinDamagePreview.Damage /= 2;
	//MaxDamagePreview.Damage /= 2;
	//	apparently not necessary after all

	return true;
}

static function bool PistolWhipDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out WeaponDamageValue MinDamagePreview, out WeaponDamageValue MaxDamagePreview, out int AllowsShield)
{
	local XComGameState_Unit AbilityOwner;
	local StateObjectReference DualSlashSecondaryRef;
	local XComGameState_Ability DualSlashSecondaryAbility;
	local XComGameStateHistory History;

	AbilityState.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);

	History = `XCOMHISTORY;
	AbilityOwner = XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	DualSlashSecondaryRef = AbilityOwner.FindAbility('DP_PistolWhipSecondary');
	DualSlashSecondaryAbility = XComGameState_Ability(History.GetGameStateForObjectID(DualSlashSecondaryRef.ObjectID));

	if (DualSlashSecondaryAbility != none)
	{
		DualSlashSecondaryAbility.NormalDamagePreview(TargetRef, MinDamagePreview, MaxDamagePreview, AllowsShield);
	}

	return true;
}

function SharedAnimation_MergeVisualization(X2Action BuildTree, out X2Action VisualizationTree)
{
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_MarkerNamed MarkerNamed, JoinMarker, SecondJoin, FireReplace;
	local array<X2Action> arrActions;
	local X2Action Action, FirstFireAction, SecondFireAction, SpacerAction;// EnterAction, ExitAction;
	local int i, iBestHistoryIndex;
	local VisualizationActionMetadata ActionMetadata;
	local XComGameStateContext_Ability AbilityContext, FirstAbilityContext, SecondAbilityContext;//, ProxyAbilityContext;
	local AbilityInputContext InputContext, TestContext;
	local StateObjectReference Source, Target;
	local name FirstAbilityName;

	VisMgr = `XCOMVISUALIZATIONMGR;

	SecondFireAction = VisMgr.GetNodeOfType(BuildTree, class'X2Action_Fire');
	SecondAbilityContext=XComGameStateContext_Ability(BuildTree.StateChangeContext);
	InputContext=SecondAbilityContext.InputContext;
	FirstAbilityName=name(Repl(InputContext.AbilityTemplateName, "Secondary", ""));
	Source=InputContext.SourceObject;
	Target=InputContext.PrimaryTarget;
	//Mr. Nice with possible overwatch in the runup of pistolwhip, muton counterattacks etc, the VisTree
	//may be messier then you think! Careful to find right X2Action_Fire by matching abilityname, source & target
	VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_Fire', arrActions, , , true);
	iBestHistoryIndex = -1;
	foreach arrActions(Action)
	{
		AbilityContext=XComGameStateContext_Ability(Action.StateChangeContext);
		TestContext=AbilityContext.InputContext;
		if (TestContext.AbilityTemplateName==FirstAbilityName
			&& TestContext.PrimaryTarget==Target
			&& TestContext.SourceObject==Source
			&& (FirstFireAction==none || AbilityContext.AssociatedState.HistoryIndex > iBestHistoryIndex))
		{
			FirstFireAction=Action;
			FirstAbilityContext=AbilityContext;
			iBestHistoryIndex=AbilityContext.AssociatedState.HistoryIndex;
		}
	}

	if (FirstFireAction == none || SecondFireAction==none)
	{
		//Mr. Nice: If this happens who knows what's going on? Just keep VisMgr happy with the most generic merge...
		XComGameStateContext_Ability(BuildTree.StateChangeContext).SuperMergeIntoVisualizationTree(BuildTree, VisualizationTree);
		return;
	}
	
	VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_MarkerNamed', arrActions, , , true);
	for (i = 0; i < arrActions.Length; ++i)
	{
		MarkerNamed = X2Action_MarkerNamed(arrActions[i]);
		if (MarkerNamed.MarkerName == 'Join' && MarkerNamed.StateChangeContext.AssociatedState.HistoryIndex == iBestHistoryIndex)
		{
			JoinMarker = MarkerNamed;
			break;
		}
	}

	`assert(JoinMarker != none);
	
	VisMgr.GetNodesOfType(BuildTree, class'X2Action_MarkerNamed', arrActions, , , true);
	for (i = 0; i < arrActions.Length; ++i)
	{
		MarkerNamed = X2Action_MarkerNamed(arrActions[i]);
		if (MarkerNamed.MarkerName == 'Join')
		{
			SecondJoin = MarkerNamed;
		}
	}

	//Mr. Nice: If Second hit misses animate first hit, otherwise animate second hit
	//Means that if we kill on the second shot, we correctly get the death anim
	//Well, that was the theory, but hiding hits is hard, and if you hide the first one, you don't get the projectile blood
	if(IsContextMiss(SecondAbilityContext))
	{
		VisMgr.GetNodesOfType(BuildTree, class'X2Action_ApplyWeaponDamageToUnit', arrActions,, Target.ObjectID);
		foreach arrActions(Action)
		{
			if(Action.ParentActions[0]==SecondFireAction)
			{
				X2Action_ApplyWeaponDamageToUnit(Action).bPlayDamageAnim=false;
			}
		}
	}
	else
	{
		VisMgr.GetNodesOfType(VisualizationTree, class'X2Action_ApplyWeaponDamageToUnit', arrActions,, Target.ObjectID);
		if (IsContextMiss(FirstAbilityContext))
		{
			foreach arrActions(Action)
			{
				if(Action.ParentActions[0]==FirstFireAction)
				{
					X2Action_ApplyWeaponDamageToUnit(Action).bPlayDamageAnim=false;
				}
			}
		}
		
		//Mr. Nice: This makes sure you can see the counter, whether the second shot kills them or not
		else if(FirstAbilityContext.ResultContext.HitResult==eHit_CounterAttack)
		{
			foreach arrActions(Action)
			{
				if (Action.ParentActions[0]==FirstFireAction)
				{
					if(default.ENABLE_LOGGING) `Log("Found miss/counter action...");
					if(XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Target.ObjectID,, SecondAbilityContext.AssociatedState.HistoryIndex)).IsDead())
					{
						//Mr. Nice: If the second hit kills, stil want to show the counter animation before the unit animates its death
						SpacerAction=Action;
					}
					else
					{
						
						//Mr. Nice: If the second hit does not kill, want the counter animation, not the flinch animation, to get priority
						//Spacer both keeps the sets of damageotunit's from being siblings if both miss,
						//and helpfully makes sure you see the counter anim, not the flinch anim when you have a counter & hit result
						ActionMetaData=FirstFireAction.Metadata;
						SpacerAction=class'X2Action_ApplyDamageSpacer'.static.AddToVisualizationTree(ActionMetadata, FirstAbilityContext,, FirstFireAction);
						VisMgr.DisconnectAction(Action);
						VisMgr.ConnectAction(Action, VisualizationTree,, SpacerAction);
						SpacerAction=FirstFireAction;
					}
					break;
				}
			}
		}
	}

	//If the second shot has a join created, then just slot it in above the first shots join
	if (SecondJoin!=none)
	{
		VisMgr.ConnectAction(SecondJoin, VisualizationTree,,, JoinMarker.ParentActions);
		VisMgr.ConnectAction(JoinMarker, BuildTree,, SecondJoin);
	}
	//If the second shot does not have a join, then connect the leaf nodes to the first shots join
	else
	{
		VisMgr.GetAllLeafNodes(BuildTree, arrActions);
		VisMgr.ConnectAction(JoinMarker,BuildTree,,, arrActions);
	}
	//Mr. Nice, ok, want to connect children of secondfireaction, to firstfireaction
	arrActions=SecondFireAction.ChildActions;
	//If first hit was countered, then the attachment point for second hit applydamagetounit will have been set
	//Otherwise, create a new SpacerAction for them
	if (SpacerAction==none)
	{
		ActionMetaData=SecondFireAction.Metadata;
		SpacerAction=class'X2Action_ApplyDamageSpacer'.static.AddToVisualizationTree(ActionMetadata, SecondAbilityContext,, FirstFireAction);
	}
	//if(default.ENABLE_LOGGING) `Log(`showvar(arrActions.Length));
	foreach arrActions(Action)
	{
		//MakeIntoLeaf(Action, BuildTree);
		//VisMgr.DisconnectAction(Action);
		VisMgr.ConnectAction(Action, VisualizationTree,, X2Action_ApplyWeaponDamageToUnit(Action)!=none ? SpacerAction : FirstFireAction);
	}
	//For correct counter attack animations, need to be able to trace from BuildTree down to the second shots apply damages, without
	//encountering the first shot's applydamages. So swap out the SecondFireAction for a marker, just to keep BuildTree traceable.
	FireReplace = X2Action_MarkerNamed(class'X2Action'.static.CreateVisualizationActionClass(class'X2Action_MarkerNamed', SecondAbilityContext));
	FireReplace.SetName("FireActionSharedAnimStub");
	VisMgr.ReplaceNode(FireReplace, SecondFireAction);	
	//VisMgr.ConnectAction(FirstFireAction, BuildTree,,, SecondFireAction.ParentActions);
	//Mr. Nice we have swapped out the SecondFireAction,
	//So can destroy it now without "stranding" any other actions
	VisMgr.DestroyAction(SecondFireAction);
	//VisMgr.ConnectAction(MarkerStart, VisualizationTree,, FirstMarkerStart);
}

//Mr. Nice: Just AbilityContext.IsResultContextHit() isn't good enough, since Unload multitargets
//The primary target, so have to check the multitarget results too
//Also, for animation purposes we want to treat a counterattack result as a hit, not miss
static function bool IsContextMiss(XComGameStateContext_Ability AbilityContext)
{
	local int MultiIndex;

	if (AbilityContext.IsResultContextHit() || AbilityContext.ResultContext.HitResult==eHit_CounterAttack)
	{
		return false;
	}
		
	for (MultiIndex = 0; MultiIndex < AbilityContext.InputContext.MultiTargets.Length; ++MultiIndex)
	{
		if (AbilityContext.IsResultContextMultiHit(MultiIndex))
		{
			return false;
		}
	}
	return true;
}

// Curtesy of Cinematic Rapid Fire
static function MakeIntoLeaf(X2Action Action, out X2Action Tree)
{
	local array<X2Action> ParentActions, ChildActions;
	local X2Action ChildAction;
	local XComGameStateVisualizationMgr VisMgr;

	VisMgr = `XCOMVISUALIZATIONMGR;
	ChildActions=Action.ChildActions;
	foreach ChildActions(ChildAction)
	{
		ParentActions=ChildAction.ParentActions;
		ParentActions.RemoveItem(Action);
		VisMgr.DisconnectAction(ChildAction);
		VisMgr.ConnectAction(ChildAction, Tree,,, ParentActions);
		VisMgr.ConnectAction(ChildAction, Tree,,, Action.ParentActions);
	}
}

// This is Musashi-san's code <3 <3 <3
/*
function MergeVisualization(X2Action BuildTree, out X2Action VisualizationTree)
{
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action_ApplyWeaponDamageToUnit MarkerStart;
	local X2Action_Fire FoundEndMarker;
	
	VisMgr = `XCOMVISUALIZATIONMGR;

	MarkerStart = X2Action_ApplyWeaponDamageToUnit(VisMgr.GetNodeOfType(BuildTree, class'X2Action_ApplyWeaponDamageToUnit'));
	FoundEndMarker = X2Action_Fire(VisMgr.GetNodeOfType(VisualizationTree, class'X2Action_Fire'));
	//SecondaryFireAction = X2Action_Fire(VisMgr.GetNodeOfType(BuildTree, class'X2Action_Fire'));

	if(MarkerStart != none && FoundEndMarker != None)
	{
		VisMgr.DisconnectAction(MarkerStart);
		VisMgr.ConnectAction(MarkerStart, VisualizationTree, false, FoundEndMarker);
		//VisMgr.DestroyAction(SecondaryFireAction);
		// adding a new miss flyover since the original wont play for whatever reason
		//AbilityContext = XComGameStateContext_Ability(MarkerStart.StateChangeContext);
		//if (AbilityContext.ResultContext.HitResult == eHit_Miss)
		//{
		//	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, AbilityContext));
		//	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'XLocalizedData'.default.MissedMessage, '', eColor_Bad);
		//	VisMgr.DisconnectAction(SoundAndFlyOver);
		//	VisMgr.ConnectAction(SoundAndFlyOver, VisualizationTree, false, FoundEndMarker);
		//}
	}
}*/

static function TakeInitiative_BuildVisualization(XComGameState VisualizeGameState)
{	
	//general
	local XComGameStateHistory	History;
	local XComGameStateVisualizationMgr VisualizationMgr;

	//visualizers
	local Actor	TargetVisualizer, ShooterVisualizer;

	//actions
	local X2Action							AddedAction;
	local X2Action							FireAction;
	local X2Action_MoveTurn					MoveTurnAction;
	local X2Action_MoveTurn					FaceEnemy;					//this is the only thing I added to this copypaste of Typical Ability Build Vis. 
	local X2Action_PlaySoundAndFlyOver		SoundAndFlyover;
	local X2Action_ExitCover				ExitCoverAction;
	local X2Action_MarkerNamed				JoinActions;
	local array<X2Action>					LeafNodes;
	local X2Action_WaitForAnotherAction		WaitForFireAction;
	//state objects
	local XComGameState_Ability				AbilityState;
	local XComGameState_EnvironmentDamage	EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;
	local XComGameState_InteractiveObject	InteractiveObject;
	local XComGameState_BaseObject			TargetStateObject;
	local XComGameState_Item				SourceWeapon;
	local StateObjectReference				ShootingUnitRef;

	//interfaces
	local X2VisualizerInterface			TargetVisualizerInterface, ShooterVisualizerInterface;

	//contexts
	local XComGameStateContext_Ability	Context;
	local AbilityInputContext			AbilityContext;

	//templates
	local X2AbilityTemplate	AbilityTemplate;
	local X2AmmoTemplate	AmmoTemplate;
	local X2WeaponTemplate	WeaponTemplate;
	local array<X2Effect>	MultiTargetEffects;

	//Tree metadata
	local VisualizationActionMetadata   InitData;
	local VisualizationActionMetadata   BuildData;
	local VisualizationActionMetadata   SourceData, InterruptTrack;

	local XComGameState_Unit TargetUnitState;	
	local name         ApplyResult;

	//indices
	local int	EffectIndex, TargetIndex;
	local int	WindowBreakTouchIndex;

	//flags
	local bool	bSourceIsAlsoTarget;
	local bool	bMultiSourceIsAlsoTarget;
	local bool  bPlayedAttackResultNarrative;
			
	// good/bad determination
	local bool bGoodAbility;

	History = `XCOMHISTORY;
	VisualizationMgr = `XCOMVISUALIZATIONMGR;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.AbilityRef.ObjectID));
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter, part I. We split this into two parts since
	//in some situations the shooter can also be a target
	//****************************************************************************************
	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);
	ShooterVisualizerInterface = X2VisualizerInterface(ShooterVisualizer);

	SourceData = InitData;
	SourceData.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceData.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if (SourceData.StateObject_NewState == none)
		SourceData.StateObject_NewState = SourceData.StateObject_OldState;
	SourceData.VisualizeActor = ShooterVisualizer;	

	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.ItemObject.ObjectID));
	if (SourceWeapon != None)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
	}

	bGoodAbility = XComGameState_Unit(SourceData.StateObject_NewState).IsFriendlyToLocalPlayer();

	if( Context.IsResultContextMiss() && AbilityTemplate.SourceMissSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceMissSpeech, bGoodAbility ? eColor_Bad : eColor_Good);
	}
	else if( Context.IsResultContextHit() && AbilityTemplate.SourceHitSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceHitSpeech, bGoodAbility ? eColor_Good : eColor_Bad);
	}

				//Ginger and Robojumper - I love you guys, thanks for making it possible
				FaceEnemy = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(SourceData, Context, false, SourceData.LastActionAdded));
				FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID)).TileLocation);
				if(default.ENABLE_LOGGING) `Log("IRIDAR Ability: " @ AbilityState.GetMyTemplateName(),, 'AkimboClass');
				if(default.ENABLE_LOGGING) `Log("IRIDAR Turning to: " @ `XWORLD.GetPositionFromTileCoordinates(XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID)).TileLocation),, 'AkimboClass');

	if( !AbilityTemplate.bSkipFireAction || Context.InputContext.MovementPaths.Length > 0 )
	{
		ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceData, Context));
		ExitCoverAction.bSkipExitCoverVisualization = AbilityTemplate.bSkipExitCoverWhenFiring;

		// if this ability has a built in move, do it right before we do the fire action
		if(Context.InputContext.MovementPaths.Length > 0)
		{			
			
		}
		else
		{
			//If we were interrupted, insert a marker node for the interrupting visualization code to use. In the move path version above, it is expected for interrupts to be 
			//done during the move.
			if (!AbilityTemplate.bSkipFireAction)
			{	
				
				/*
						FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, SourceData.LastActionAdded));
						FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
						FaceEnemy.ForceSetPawnRotation = true;
						FaceEnemy.UpdateAimTarget = true;*/
				// no move, just add the fire action. Parent is exit cover action if we have one
				AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTree(SourceData, Context, false, SourceData.LastActionAdded);
			}			
		}
		/*turns to wrong target
		FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		FaceEnemy.ForceSetPawnRotation = true;
		FaceEnemy.UpdateAimTarget = true;*/

					

		if( !AbilityTemplate.bSkipFireAction )
		{
			FireAction = AddedAction;

			class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackBegin', FireAction.ParentActions[0]);

			if( AbilityTemplate.AbilityToHitCalc != None )
			{
								
								//FaceEnemy.ForceSetPawnRotation = true;
								//FaceEnemy.UpdateAimTarget = true;	

				X2Action_Fire(AddedAction).SetFireParameters(Context.IsResultContextHit());
			}
		}
	}
	/*
		FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		FaceEnemy.ForceSetPawnRotation = true;
		FaceEnemy.UpdateAimTarget = true;*/

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, SourceData, Context.FindShooterEffectApplyResult(AbilityTemplate.AbilityShooterEffects[EffectIndex]));		
	}
	//****************************************************************************************

	//Configure the visualization track for the target(s). This functionality uses the context primarily
	//since the game state may not include state objects for misses.
	//****************************************************************************************	
	bSourceIsAlsoTarget = AbilityContext.PrimaryTarget.ObjectID == AbilityContext.SourceObject.ObjectID; //The shooter is the primary target
	if (AbilityTemplate.AbilityTargetEffects.Length > 0 &&			//There are effects to apply
		AbilityContext.PrimaryTarget.ObjectID > 0)				//There is a primary target
	{
		TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);
		TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

		if( bSourceIsAlsoTarget )
		{
			BuildData = SourceData;
		}
		else
		{
			BuildData = InterruptTrack;        //  interrupt track will either be empty or filled out correctly
		}

		BuildData.VisualizeActor = TargetVisualizer;

		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID, 
															   BuildData.StateObject_OldState, BuildData.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(BuildData.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
			BuildData.StateObject_NewState = BuildData.StateObject_OldState;
		}

		// if this is a melee attack, make sure the target is facing the location he will be melee'd from
		if(!AbilityTemplate.bSkipFireAction 
			&& !bSourceIsAlsoTarget 
			&& AbilityContext.MovementPaths.Length > 0
			&& AbilityContext.MovementPaths[0].MovementData.Length > 0
			&& XGUnit(TargetVisualizer) != none)
		{
			MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(BuildData, Context, false, ExitCoverAction));
			MoveTurnAction.m_vFacePoint = AbilityContext.MovementPaths[0].MovementData[AbilityContext.MovementPaths[0].MovementData.Length - 1].Position;
			MoveTurnAction.m_vFacePoint.Z = TargetVisualizerInterface.GetTargetingFocusLocation().Z;
			MoveTurnAction.UpdateAimTarget = true;

			// Jwats: Add a wait for ability effect so the idle state machine doesn't process!
			WaitForFireAction = X2Action_WaitForAnotherAction(class'X2Action_WaitForAnotherAction'.static.AddToVisualizationTree(BuildData, Context, false, MoveTurnAction));
			WaitForFireAction.ActionToWaitFor = FireAction;
		}

		//Pass in AddedAction (Fire Action) as the LastActionAdded if we have one. Important! As this is automatically used as the parent in the effect application sub functions below.
		if (AddedAction != none && AddedAction.IsA('X2Action_Fire'))
		{
			BuildData.LastActionAdded = AddedAction;
		}
		/*
		FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		FaceEnemy.ForceSetPawnRotation = true;
		FaceEnemy.UpdateAimTarget = true;
		*/
		//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
		//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
		//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);

			// Target effect visualization
			if( !Context.bSkipAdditionalVisualizationSteps )
			{
				AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
			}

			// Source effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
		}

		//the following is used to handle Rupture flyover text
		TargetUnitState = XComGameState_Unit(BuildData.StateObject_OldState);
		if (TargetUnitState != none &&
			XComGameState_Unit(BuildData.StateObject_OldState).GetRupturedValue() == 0 &&
			XComGameState_Unit(BuildData.StateObject_NewState).GetRupturedValue() > 0)
		{
			//this is the frame that we realized we've been ruptured!
			class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildData);
		}

		if (AbilityTemplate.bAllowAmmoEffects && AmmoTemplate != None)
		{
			for (EffectIndex = 0; EffectIndex < AmmoTemplate.TargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(AmmoTemplate.TargetEffects[EffectIndex]);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
		}
		if (AbilityTemplate.bAllowBonusWeaponEffects && WeaponTemplate != none)
		{
			for (EffectIndex = 0; EffectIndex < WeaponTemplate.BonusWeaponEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[EffectIndex]);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}
		}

		if (Context.IsResultContextMiss() && (AbilityTemplate.LocMissMessage != "" || AbilityTemplate.TargetMissSpeech != ''))
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, AbilityTemplate.TargetMissSpeech, bGoodAbility ? eColor_Bad : eColor_Good);
		}
		else if( Context.IsResultContextHit() && (AbilityTemplate.LocHitMessage != "" || AbilityTemplate.TargetHitSpeech != '') )
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(BuildData, Context, false, BuildData.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocHitMessage, AbilityTemplate.TargetHitSpeech, bGoodAbility ? eColor_Good : eColor_Bad);
		}

		if (!bPlayedAttackResultNarrative)
		{
			class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackResult');
			bPlayedAttackResultNarrative = true;
		}

		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
		}

		if( bSourceIsAlsoTarget )
		{
			SourceData = BuildData;
		}
	}

	if (AbilityTemplate.bUseLaunchedGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState)).LaunchedGrenadeEffects;
	}
	else if (AbilityTemplate.bUseThrownGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetMyTemplate()).ThrownGrenadeEffects;
	}
	else
	{
		MultiTargetEffects = AbilityTemplate.AbilityMultiTargetEffects;
	}

	//  Apply effects to multi targets - don't show multi effects for burst fire as we just want the first time to visualize
	if( MultiTargetEffects.Length > 0 && AbilityContext.MultiTargets.Length > 0 && X2AbilityMultiTarget_BurstFire(AbilityTemplate.AbilityMultiTargetStyle) == none)
	{
		for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
		{	
			bMultiSourceIsAlsoTarget = false;
			if( AbilityContext.MultiTargets[TargetIndex].ObjectID == AbilityContext.SourceObject.ObjectID )
			{
				bMultiSourceIsAlsoTarget = true;
				bSourceIsAlsoTarget = bMultiSourceIsAlsoTarget;				
			}

			TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

			if( bMultiSourceIsAlsoTarget )
			{
				BuildData = SourceData;
			}
			else
			{
				BuildData = InitData;
			}
			BuildData.VisualizeActor = TargetVisualizer;

			// if the ability involved a fire action and we don't have already have a potential parent,
			// all the target visualizations should probably be parented to the fire action and not rely on the auto placement.
			if( (BuildData.LastActionAdded == none) && (FireAction != none) )
				BuildData.LastActionAdded = FireAction;

			TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
			if( TargetStateObject != none )
			{
				History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID, 
																	BuildData.StateObject_OldState, BuildData.StateObject_NewState,
																	eReturnType_Reference,
																	VisualizeGameState.HistoryIndex);
				`assert(BuildData.StateObject_NewState == TargetStateObject);
			}			
			else
			{
				//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
				//and show no change.
				BuildData.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				BuildData.StateObject_NewState = BuildData.StateObject_OldState;
			}
		
			//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
			//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
			//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
			for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindMultiTargetEffectApplyResult(MultiTargetEffects[EffectIndex], TargetIndex);

				// Target effect visualization
				MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, ApplyResult);

				// Source effect visualization
				MultiTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceData, ApplyResult);
			}			

			//the following is used to handle Rupture flyover text
			TargetUnitState = XComGameState_Unit(BuildData.StateObject_OldState);
			if (TargetUnitState != none && 
				XComGameState_Unit(BuildData.StateObject_OldState).GetRupturedValue() == 0 &&
				XComGameState_Unit(BuildData.StateObject_NewState).GetRupturedValue() > 0)
			{
				//this is the frame that we realized we've been ruptured!
				class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildData);
			}
			
			if (!bPlayedAttackResultNarrative)
			{
				class'XComGameState_NarrativeManager'.static.BuildVisualizationForDynamicNarrative(VisualizeGameState, false, 'AttackResult');
				bPlayedAttackResultNarrative = true;
			}

			if( TargetVisualizerInterface != none )
			{
				//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
				TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildData);
			}

			if( bMultiSourceIsAlsoTarget )
			{
				SourceData = BuildData;
			}			
		}
	}
	//****************************************************************************************
		/*FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		FaceEnemy.ForceSetPawnRotation = true;
		FaceEnemy.UpdateAimTarget = true;*/ //turn is no longer instant, but still happens after attack
	//Finish adding the shooter's track
	//****************************************************************************************
	if( !bSourceIsAlsoTarget && ShooterVisualizerInterface != none)
	{
		ShooterVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, SourceData);				
	}	

	//  Handle redirect visualization
	TypicalAbility_AddEffectRedirects(VisualizeGameState, SourceData);

	//****************************************************************************************

	//Configure the visualization tracks for the environment
	//****************************************************************************************

	if (ExitCoverAction != none)
	{
		ExitCoverAction.ShouldBreakWindowBeforeFiring( Context, WindowBreakTouchIndex );
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		BuildData = InitData;
		BuildData.VisualizeActor = none;
		BuildData.StateObject_NewState = EnvironmentDamageEvent;
		BuildData.StateObject_OldState = EnvironmentDamageEvent;

		// if this is the damage associated with the exit cover action, we need to force the parenting within the tree
		// otherwise LastActionAdded with be 'none' and actions will auto-parent.
		if ((ExitCoverAction != none) && (WindowBreakTouchIndex > -1))
		{
			if (EnvironmentDamageEvent.HitLocation == AbilityContext.ProjectileEvents[WindowBreakTouchIndex].HitLocation)
			{
				BuildData.LastActionAdded = ExitCoverAction;
			}
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');	
		}
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		BuildData = InitData;
		BuildData.VisualizeActor = none;
		BuildData.StateObject_NewState = WorldDataUpdate;
		BuildData.StateObject_OldState = WorldDataUpdate;

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildData, 'AA_Success');	
		}
	}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification. 
		// Move logic is taken from MoveAbility_BuildVisualization, which only has special case handling for AI patrol movement ( which wouldn't happen here )
		if ( Context.InputContext.MovementPaths.Length > 0 || (InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim()) ) //Is this a closed door?
		{
			BuildData = InitData;
			//Don't necessarily have a previous state, so just use the one we know about
			BuildData.StateObject_OldState = InteractiveObject;
			BuildData.StateObject_NewState = InteractiveObject;
			BuildData.VisualizeActor = History.GetVisualizer(InteractiveObject.ObjectID);

			class'X2Action_BreakInteractActor'.static.AddToVisualizationTree(BuildData, Context);
		}
	}
	
	//Add a join so that all hit reactions and other actions will complete before the visualization sequence moves on. In the case
	// of fire but no enter cover then we need to make sure to wait for the fire since it isn't a leaf node
	VisualizationMgr.GetAllLeafNodes(VisualizationMgr.BuildVisTree, LeafNodes);

	if (!AbilityTemplate.bSkipFireAction)
	{	
		/*
			if(default.ENABLE_LOGGING) `Log("IRIDAR Attempting to trigger move turn action",, 'AkimboClass');
			MoveTurnAction2 = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTree(SourceData, Context, false));
			MoveTurnAction2.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
			MoveTurnAction2.ForceSetPawnRotation = true;
			MoveTurnAction2.UpdateAimTarget = true;
			if(default.ENABLE_LOGGING) `Log("IRIDAR Triggered. Coords: " @ `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation),, 'AkimboClass');*/

			// Jwats: Add a wait for ability effect so the idle state machine doesn't process!
			//WaitForFireAction = X2Action_WaitForAnotherAction(class'X2Action_WaitForAnotherAction'.static.AddToVisualizationTree(BuildData, Context, false, MoveTurnAction2));
			//WaitForFireAction.ActionToWaitFor = FireAction;
			/* turn is too snappy and happens after attack
		FaceEnemy = X2Action_FaceEnemy(class'X2Action_FaceEnemy'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		FaceEnemy.m_vFacePoint = `XWORLD.GetPositionFromTileCoordinates(TargetUnitState.TileLocation);
		FaceEnemy.ForceSetPawnRotation = true;
		FaceEnemy.UpdateAimTarget = true;*/

		if (!AbilityTemplate.bSkipExitCoverWhenFiring)
		{			
			LeafNodes.AddItem(class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceData, Context, false, FireAction));
		}
		else
		{
			LeafNodes.AddItem(FireAction);
		}
	}
	
	if (VisualizationMgr.BuildVisTree.ChildActions.Length > 0)
	{
		JoinActions = X2Action_MarkerNamed(class'X2Action_MarkerNamed'.static.AddToVisualizationTree(SourceData, Context, false, none, LeafNodes));
		JoinActions.SetName("Join");
	}
}

static function EventListenerReturn TakeInitiativeListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit;
	local int i;
	local XComGameState_Ability AbilityState;
	local GameRulesCache_Unit UnitCache;

	//thanks to Robojumper for figuring out how to get this working

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	AbilityState = XComGameState_Ability(CallbackData);	//this is how we get the Ability State for the ability we want to re-trigger. If we used EventData, we would get the ability that cause this ability to trigger instead.
	if(default.ENABLE_LOGGING) `Log("IRIDAR Trying to retrigger ability: " @ AbilityState.GetMyTemplateName(),, 'AkimboClass');
	
	if (AbilityContext != none && AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt)
	{
		SourceUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

		if (`TACTICALRULES.GetGameRulesCache_Unit(SourceUnit.GetReference(), UnitCache))	//we get UnitCache for the soldier that triggered this ability
		{
			for (i = 0; i < UnitCache.AvailableActions.Length; ++i)	//then in all actions available to him
			{

				if (UnitCache.AvailableActions[i].AbilityObjectRef.ObjectID == AbilityState.ObjectID)	//we find our ability
				{
					if (UnitCache.AvailableActions[i].AvailableCode == 'AA_Success')	//and trigger it on the first available target
					{
						class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[i], `SYNC_RAND_STATIC(UnitCache.AvailableActions[i].AvailableTargets.Length));
						break;
					}
					break;
				}
			}
		}
	}
	return ELR_NoInterrupt;
}

static function XComGameState DualPistols_BuildGameState(XComGameStateContext Context)	//custom function to correctly apply ammo cost
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_Ability ShootAbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;
	local int TargetIndex;	

	local XComGameState_BaseObject AffectedTargetObject_OriginalState;	
	local XComGameState_BaseObject AffectedTargetObject_NewState;
	local XComGameState_BaseObject SourceObject_OriginalState;
	local XComGameState_BaseObject SourceObject_NewState;
	local XComGameState_Item       SourceWeapon, SourceWeapon_NewState, PrimaryWeapon, NewPrimaryWeapon;
	local XComGameState_Unit Unit;
	local X2AmmoTemplate           AmmoTemplate;
	local X2GrenadeTemplate        GrenadeTemplate;
	local X2WeaponTemplate         WeaponTemplate;
	local EffectResults            MultiTargetEffectResults, EmptyResults;
	local EffectTemplateLookupType MultiTargetLookupType;
	local OverriddenEffectsByType OverrideEffects, EmptyOverride;

	History = `XCOMHISTORY;	

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);

	//Build the new game state frame, and unit state object for the acting unit
	`assert(NewGameState != none);
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	ShootAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));	
	AbilityTemplate = ShootAbilityState.GetMyTemplate();
	SourceObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID);	
	SourceWeapon = ShootAbilityState.GetSourceWeapon();
	ShootAbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(ShootAbilityState.Class, ShootAbilityState.ObjectID));

	//Any changes to the shooter / source object are made to this game state
	SourceObject_NewState = NewGameState.ModifyStateObject(SourceObject_OriginalState.Class, AbilityContext.InputContext.SourceObject.ObjectID);

	if (SourceWeapon != none)
	{
		SourceWeapon_NewState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', SourceWeapon.ObjectID));

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));	//ADDED BY IRIDAR
		PrimaryWeapon = Unit.GetItemInSlot(eInvSlot_PrimaryWeapon);															//just getting templates specifically for the primary weapon 
		NewPrimaryWeapon = XComGameState_Item(NewGameState.ModifyStateObject(PrimaryWeapon.Class, PrimaryWeapon.ObjectID));	//and getting ready to make changes to them

	}

	if (AbilityTemplate.bRecordValidTiles && AbilityContext.InputContext.TargetLocations.Length > 0)
	{
		AbilityTemplate.AbilityMultiTargetStyle.GetValidTilesForLocation(ShootAbilityState, AbilityContext.InputContext.TargetLocations[0], AbilityContext.ResultContext.RelevantEffectTiles);
	}

	//If there is a target location, generate a list of projectile events to use if a projectile is requested
	if(AbilityContext.InputContext.ProjectileEvents.Length > 0)
	{
		GenerateDamageEvents(NewGameState, AbilityContext);
	}

	//  Apply effects to shooter
	if (AbilityTemplate.AbilityShooterEffects.Length > 0)
	{
		AffectedTargetObject_OriginalState = SourceObject_OriginalState;
		AffectedTargetObject_NewState = SourceObject_NewState;				
			
		ApplyEffectsToTarget(
			AbilityContext, 
			AffectedTargetObject_OriginalState, 
			SourceObject_OriginalState, 
			ShootAbilityState, 
			AffectedTargetObject_NewState, 
			NewGameState, 
			AbilityContext.ResultContext.HitResult,
			AbilityContext.ResultContext.ArmorMitigation,
			AbilityContext.ResultContext.StatContestResult,
			AbilityTemplate.AbilityShooterEffects, 
			AbilityContext.ResultContext.ShooterEffectResults, 
			AbilityTemplate.DataName, 
			TELT_AbilityShooterEffects);
	}

	//  Apply effects to primary target
	if (AbilityContext.InputContext.PrimaryTarget.ObjectID != 0)
	{
		AffectedTargetObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID, eReturnType_Reference);
		AffectedTargetObject_NewState = NewGameState.ModifyStateObject(AffectedTargetObject_OriginalState.Class, AbilityContext.InputContext.PrimaryTarget.ObjectID);
		
		if (AbilityTemplate.AbilityTargetEffects.Length > 0)
		{
			if (ApplyEffectsToTarget(
				AbilityContext, 
				AffectedTargetObject_OriginalState, 
				SourceObject_OriginalState, 
				ShootAbilityState, 
				AffectedTargetObject_NewState, 
				NewGameState, 
				AbilityContext.ResultContext.HitResult,
				AbilityContext.ResultContext.ArmorMitigation,
				AbilityContext.ResultContext.StatContestResult,
				AbilityTemplate.AbilityTargetEffects, 
				AbilityContext.ResultContext.TargetEffectResults, 
				AbilityTemplate.DataName, 
				TELT_AbilityTargetEffects))

			{
				if (AbilityTemplate.bAllowAmmoEffects && SourceWeapon_NewState != none && SourceWeapon_NewState.HasLoadedAmmo())
				{
					AmmoTemplate = X2AmmoTemplate(SourceWeapon_NewState.GetLoadedAmmoTemplate(ShootAbilityState));
					if (AmmoTemplate != none && AmmoTemplate.TargetEffects.Length > 0)
					{
						ApplyEffectsToTarget(
							AbilityContext, 
							AffectedTargetObject_OriginalState, 
							SourceObject_OriginalState, 
							ShootAbilityState, 
							AffectedTargetObject_NewState, 
							NewGameState, 
							AbilityContext.ResultContext.HitResult,
							AbilityContext.ResultContext.ArmorMitigation,
							AbilityContext.ResultContext.StatContestResult,
							AmmoTemplate.TargetEffects, 
							AbilityContext.ResultContext.TargetEffectResults, 
							AmmoTemplate.DataName,  //Use the ammo template for TELT_AmmoTargetEffects
							TELT_AmmoTargetEffects);
					}
				}
				if (AbilityTemplate.bAllowBonusWeaponEffects && SourceWeapon_NewState != none)
				{
					WeaponTemplate = X2WeaponTemplate(SourceWeapon_NewState.GetMyTemplate());
					if (WeaponTemplate != none && WeaponTemplate.BonusWeaponEffects.Length > 0)
					{
						ApplyEffectsToTarget(
							AbilityContext,
							AffectedTargetObject_OriginalState, 
							SourceObject_OriginalState, 
							ShootAbilityState, 
							AffectedTargetObject_NewState, 
							NewGameState, 
							AbilityContext.ResultContext.HitResult,
							AbilityContext.ResultContext.ArmorMitigation,
							AbilityContext.ResultContext.StatContestResult,
							WeaponTemplate.BonusWeaponEffects, 
							AbilityContext.ResultContext.TargetEffectResults, 
							WeaponTemplate.DataName,
							TELT_WeaponEffects);
					}
				}
			}
		}

		if (AbilityTemplate.Hostility == eHostility_Offensive && AffectedTargetObject_NewState.CanEarnXp() && XComGameState_Unit(AffectedTargetObject_NewState).IsEnemyUnit(XComGameState_Unit(SourceObject_NewState)))
		{
			`TRIGGERXP('XpGetShotAt', AffectedTargetObject_NewState.GetReference(), SourceObject_NewState.GetReference(), NewGameState);
		}
	}

	if (AbilityTemplate.bUseLaunchedGrenadeEffects)
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(ShootAbilityState));
		MultiTargetLookupType = TELT_LaunchedGrenadeEffects;
	}
	else if (AbilityTemplate.bUseThrownGrenadeEffects)
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());
		MultiTargetLookupType = TELT_ThrownGrenadeEffects;
	}
	else
	{
		MultiTargetLookupType = TELT_AbilityMultiTargetEffects;
	}

	//  Apply effects to multi targets
	if( (AbilityTemplate.AbilityMultiTargetEffects.Length > 0 || GrenadeTemplate != none) && AbilityContext.InputContext.MultiTargets.Length > 0)
	{		
		for( TargetIndex = 0; TargetIndex < AbilityContext.InputContext.MultiTargets.Length; ++TargetIndex )
		{
			AffectedTargetObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.MultiTargets[TargetIndex].ObjectID, eReturnType_Reference);
			AffectedTargetObject_NewState = NewGameState.ModifyStateObject(AffectedTargetObject_OriginalState.Class, AbilityContext.InputContext.MultiTargets[TargetIndex].ObjectID);

			OverrideEffects = AbilityContext.ResultContext.MultiTargetEffectsOverrides.Length > TargetIndex ? AbilityContext.ResultContext.MultiTargetEffectsOverrides[TargetIndex] : EmptyOverride;
			
			MultiTargetEffectResults = EmptyResults;        //  clear struct for use - cannot pass dynamic array element as out parameter
			if (ApplyEffectsToTarget(
				AbilityContext, 
				AffectedTargetObject_OriginalState, 
				SourceObject_OriginalState, 
				ShootAbilityState, 
				AffectedTargetObject_NewState, 
				NewGameState, 
				AbilityContext.ResultContext.MultiTargetHitResults[TargetIndex],
				AbilityContext.ResultContext.MultiTargetArmorMitigation[TargetIndex],
				AbilityContext.ResultContext.MultiTargetStatContestResult[TargetIndex],
				AbilityTemplate.bUseLaunchedGrenadeEffects ? GrenadeTemplate.LaunchedGrenadeEffects : (AbilityTemplate.bUseThrownGrenadeEffects ? GrenadeTemplate.ThrownGrenadeEffects : AbilityTemplate.AbilityMultiTargetEffects), 
				MultiTargetEffectResults, 
				GrenadeTemplate == none ? AbilityTemplate.DataName : GrenadeTemplate.DataName, 
				MultiTargetLookupType ,
				OverrideEffects))
			{
				AbilityContext.ResultContext.MultiTargetEffectResults[TargetIndex] = MultiTargetEffectResults;  //  copy results into dynamic array
			}
		}
	}
	
	//Give all effects a chance to make world modifications ( ie. add new state objects independent of targeting )
	ApplyEffectsToWorld(AbilityContext, SourceObject_OriginalState, ShootAbilityState, NewGameState, AbilityTemplate.AbilityShooterEffects, AbilityTemplate.DataName, TELT_AbilityShooterEffects);
	ApplyEffectsToWorld(AbilityContext, SourceObject_OriginalState, ShootAbilityState, NewGameState, AbilityTemplate.AbilityTargetEffects, AbilityTemplate.DataName, TELT_AbilityTargetEffects);	
	if (GrenadeTemplate != none)
	{
		if (AbilityTemplate.bUseLaunchedGrenadeEffects)
		{
			ApplyEffectsToWorld(AbilityContext, SourceObject_OriginalState, ShootAbilityState, NewGameState, GrenadeTemplate.LaunchedGrenadeEffects, GrenadeTemplate.DataName, TELT_LaunchedGrenadeEffects);
		}
		else if (AbilityTemplate.bUseThrownGrenadeEffects)
		{
			ApplyEffectsToWorld(AbilityContext, SourceObject_OriginalState, ShootAbilityState, NewGameState, GrenadeTemplate.ThrownGrenadeEffects, GrenadeTemplate.DataName, TELT_ThrownGrenadeEffects);
		}
	}
	else
	{
		ApplyEffectsToWorld(AbilityContext, SourceObject_OriginalState, ShootAbilityState, NewGameState, AbilityTemplate.AbilityMultiTargetEffects, AbilityTemplate.DataName, TELT_AbilityMultiTargetEffects);
	}

	//Apply the cost of the ability
	AbilityTemplate.ApplyCost(AbilityContext, ShootAbilityState, SourceObject_NewState, NewPrimaryWeapon, NewGameState);	//CHANGED BY IRIDAR applying an ammo cost specificaly to the primary weapon instead of source weapon
																															//this is necessary to handle ammo cost for abilities attached to left gun, which has infinite ammo
	return NewGameState;
}
