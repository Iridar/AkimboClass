class X2Effect_DP_GunKata extends X2Effect_Persistent;
//	Whenever unit activates an ability that grants an Overwatch Action Point, grant one additional point of the same type.

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'X2Effect_DP_GunKata_Event', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability	GunKataAbilityState;
	local X2EventManager		EventMgr;
	local XComGameState_Unit	OldUnitState;
	local name					ReserveType;
	local array<name>			AddedReserveAP;
	local int i;

	OldUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SourceUnit.ObjectID));
	`LOG("Gun Kata post ability cost paid for: " @ SourceUnit.GetFullName() @ "and ability: " @ kAbility.GetMyTemplateName() @ "current Reserve AP:" @ SourceUnit.ReserveActionPoints.Length @ "previous: " @ OldUnitState.ReserveActionPoints.Length, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');

	//	if this ability added Reserve Action Points
	if (OldUnitState != none && SourceUnit.ReserveActionPoints.Length > OldUnitState.ReserveActionPoints.Length && class'X2Effect_DP_Quicksilver'.static.AbilityReservesAP(kAbility))
	{
		`LOG("Unit gained a Reserve AP", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');

		//	Build the array of Reserve AP that was supposedly added by this ability.
		AddedReserveAP = SourceUnit.ReserveActionPoints;
		for (i = OldUnitState.ReserveActionPoints.Length - 1; i >= 0; i--)
		{
			if (AddedReserveAP.Find(OldUnitState.ReserveActionPoints[i]) != INDEX_NONE)
			{
				AddedReserveAP.Remove(i, 1);
			}
		}
		`LOG("Unit gained this many reserve AP: " @ AddedReserveAP.Length, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');
		
		//	Get the Reserve AP type that is used by this weapon for Overwatch
		ReserveType = GetReserveType(kAbility);
		`LOG("The source weappon requires this type of Reserve AP for Overwatch: " @ ReserveType, class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');

		//	Make sure the diff. array actually contains the Reserve AP Type.
		//	We do this complicated double check to be absolutely sure that this ability that was just activated was something like Overwatch.
		//	And there is now in fact a difference in Reserve AP *and* the activated ability actually contains an X2Effect_ReserveOverwatchPoints effect.
		if (ReserveType != '' && AddedReserveAP.Find(ReserveType) != INDEX_NONE)
		{
			`LOG("This ability DID ADD this type of Reserve AP, adding another Reserve AP of the same type", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');
			SourceUnit.ReserveActionPoints.AddItem(ReserveType);

			//	Trigger flyover
			GunKataAbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (GunKataAbilityState != none)
			{
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent('X2Effect_DP_GunKata_Event', GunKataAbilityState, SourceUnit, NewGameState);
			}
		}
	}
	else `LOG("Unit DID NOT gain a Reserve AP", class'X2Ability_AkimboAbilitySet'.default.ENABLE_LOGGING, 'IRIGUNKATA');

	return false;
}

static function name GetReserveType(const XComGameState_Ability AbilityState)
{
	local XComGameState_Item ItemState;
	local X2WeaponTemplate WeaponTemplate;

	ItemState = AbilityState.GetSourceWeapon();
	if (ItemState != none)
	{
		WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
		if (WeaponTemplate != None)
		{
			return WeaponTemplate.OverwatchActionPoint;
		}
	}
	return '';
}