class UIUnitFlag_GunKataCharge extends UIUnitFlag config(Akimbo);

var UIIcon GunKataChargeIcon,GunKataChargeIcon1, GunKataChargeIcon2,  GunKataChargeIcon3,  GunKataChargeIcon4, GunKataChargePlusIcon;
var array <UIIcon> GunKataChargeBlankIcon;
var config int BASE_X, BASE_Y, OFFSET_X, ICON_SIZE, PLUSICON_SIZE;
var privatewrite name InitialSetValue;

simulated function RealizeHitPoints(optional XComGameState_Unit NewUnitState = none)
{
	local XComGameState_Effect_TemplarFocus FocusState;
	local XComGameState_Unit PreviousUnitState;
	local int PreviousWill;
	
	if( NewUnitState == none )
	{
		NewUnitState = XComGameState_Unit(History.GetGameStateForObjectID(StoredObjectID));
	}

	PreviousUnitState = XComGameState_Unit(NewUnitState.GetPreviousVersion());
	if (PreviousUnitState != none)
	{
		PreviousWill = PreviousUnitState.GetCurrentStat(eStat_Will);
	}

	SetHitPoints(NewUnitState.GetCurrentStat(eStat_HP), NewUnitState.GetMaxStat(eStat_HP));
	SetShieldPoints(NewUnitState.GetCurrentStat(eStat_ShieldHP), NewUnitState.GetMaxStat(eStat_ShieldHP));
	SetArmorPoints(NewUnitState.GetArmorMitigationForUnitFlag());
	SetWillPoints(NewUnitState.GetCurrentStat(eStat_Will), NewUnitState.GetMaxStat(eStat_Will), PreviousWill);
	SetGunKataCharge();

	FocusState = NewUnitState.GetTemplarFocusEffectState();
	if( FocusState != none )
	{
		SetFocusPoints(FocusState.FocusLevel, FocusState.GetMaxFocus(NewUnitState));
	}

	//Needs to be called after changes are made to will or focus level. This should be after all changes are made to minimize calls.
	RealizeMeterPosition();
}

simulated function SetGunKataCharge()
{
	local XComGameState_Unit UnitState;
	local UnitValue NewGunKataCharge, PreGunKataCharge, InitialSet;
	local int i, MaxGunKataCharge;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(StoredObjectID));
	if (UnitState.HasSoldierAbility('GunKataCharge_Passive'))
	{	
		UnitState.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, NewGunKataCharge);
		UnitState.GetUnitValue(class'X2Effect_GunKataCharge'.default.PreGunKataChargeValue, PreGunKataCharge);
		UnitState.GetUnitValue(default.InitialSetValue, InitialSet);
		if (InitialSet.fValue == 0)
		{	
			MaxGunKataCharge = class'X2Ability_AkimboAbilitySet'.default.GUNKATACHARGE_MAX;
			for (i = 0; i < MaxGunKataCharge; i++)
			{
				if (MaxGunKataCharge > 5 && i == 5)
					break;
				GunKataChargeBlankIcon[i] = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack_Blank",false,false,default.ICON_SIZE);
				GunKataChargeBlankIcon[i].SetX(default.BASE_X + (default.OFFSET_X) * i);
				GunKataChargeBlankIcon[i].SetY(default.BASE_Y);
			}
			GunKataChargeIcon = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack",false,false,default.ICON_SIZE);
			GunKataChargeIcon.SetX(default.BASE_X);
			GunKataChargeIcon.SetY(default.BASE_Y);
			GunKataChargeIcon.Hide();
			GunKataChargeIcon1 = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack",false,false,default.ICON_SIZE);
			GunKataChargeIcon1.SetX(default.BASE_X + (default.OFFSET_X) * 1);
			GunKataChargeIcon1.SetY(default.BASE_Y);
			GunKataChargeIcon1.Hide();
			GunKataChargeIcon2 = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack",false,false,default.ICON_SIZE);
			GunKataChargeIcon2.SetX(default.BASE_X + (default.OFFSET_X) * 2);
			GunKataChargeIcon2.SetY(default.BASE_Y);
			GunKataChargeIcon2.Hide();
			GunKataChargeIcon3 = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack",false,false,default.ICON_SIZE);
			GunKataChargeIcon3.SetX(default.BASE_X + (default.OFFSET_X) * 3);
			GunKataChargeIcon3.SetY(default.BASE_Y);
			GunKataChargeIcon3.Hide();
			GunKataChargeIcon4 = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack",false,false,default.ICON_SIZE);
			GunKataChargeIcon4.SetX(default.BASE_X + (default.OFFSET_X) * 4);
			GunKataChargeIcon4.SetY(default.BASE_Y);
			GunKataChargeIcon4.Hide();
			GunKataChargePlusIcon = Spawn(class'UIIcon', self).InitIcon('',"img:///WP_Akimbo.UIIcons.UIIcon_ActionStack_Plus",false,false,default.PLUSICON_SIZE);
			GunKataChargePlusIcon.SetX(default.BASE_X + (default.OFFSET_X) * 5 + 10);
			GunKataChargePlusIcon.SetY(default.BASE_Y);
			GunKataChargePlusIcon.Hide();
			UnitState.SetUnitFloatValue(default.InitialSetValue, 1, eCleanUp_BeginTactical);
		}
		if (NewGunKataCharge.fvalue != PreGunKataCharge.fValue)
		{	
			GunKataChargeIcon.Hide();
			GunKataChargeIcon1.Hide();
			GunKataChargeIcon2.Hide();
			GunKataChargeIcon3.Hide();
			GunKataChargeIcon4.Hide();
			GunKataChargePlusIcon.Hide();
			if (NewGunKataCharge.fvalue > 0)
			{
				GunKataChargeIcon.Show();
				if (NewGunKataCharge.fvalue > 1)
				{
					GunKataChargeIcon1.Show();
					if (NewGunKataCharge.fvalue > 2)
					{
						GunKataChargeIcon2.Show();
						if (NewGunKataCharge.fvalue > 3)
						{
							GunKataChargeIcon3.Show();
							if (NewGunKataCharge.fvalue > 4)
							{	
								GunKataChargeIcon4.Show();
								if (NewGunKataCharge.fvalue > 5)
									GunKataChargePlusIcon.Show();
							}
						}

					}
				}
			}
			UnitState.SetUnitFloatValue(class'X2Effect_GunKataCharge'.default.PreGunKataChargeValue, NewGunKataCharge.fvalue, eCleanUp_BeginTactical);
		}
	}
}

defaultproperties
{
	InitialSetValue = "InitialSet"
}