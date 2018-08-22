class UITacticalHUD_GunKataCharge extends UITacticalHUD_SoldierInfo config(Akimbo);

var UIImage HUD_GunKataChargeImage, HUD_GunKataChargeImage1, HUD_GunKataChargeImage2, HUD_GunKataChargeImage3, HUD_GunKataChargeImage4, HUD_GunKataChargeBlankImage, HUD_GunKataChargeIconImage;
var config int HUD_STACK_BASE_X, HUD_STACK_OFFSET_X, HUD_BLANK_BASE_X, HUD_BASE_Y, HUD_ICON_BASE_X;

simulated function UpdateStats()
{
	local XGUnit        kActiveUnit;

	// If not shown or ready, leave.
	if( !bIsInited )
		return;
	
	// Only update if new unit
	kActiveUnit = XComTacticalController(PC).GetActiveUnit();
	if( kActiveUnit == none )
	{
		HUD_GunKataChargeIconImage = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack_Icon");
		HUD_GunKataChargeIconImage.SetX(default.HUD_ICON_BASE_X);
		HUD_GunKataChargeIconImage.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeIconImage.Hide();
		HUD_GunKataChargeBlankImage = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack_Blank");
		HUD_GunKataChargeBlankImage.SetX(default.HUD_BLANK_BASE_X);
		HUD_GunKataChargeBlankImage.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeBlankImage.Hide();
		HUD_GunKataChargeImage = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack");
		HUD_GunKataChargeImage.SetX(default.HUD_STACK_BASE_X);
		HUD_GunKataChargeImage.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeImage.Hide();
		HUD_GunKataChargeImage1 = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack");
		HUD_GunKataChargeImage1.SetX(default.HUD_STACK_BASE_X + (default.HUD_STACK_OFFSET_X) * 1);
		HUD_GunKataChargeImage1.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeImage1.Hide();
		HUD_GunKataChargeImage2 = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack");
		HUD_GunKataChargeImage2.SetX(default.HUD_STACK_BASE_X + (default.HUD_STACK_OFFSET_X) * 2);
		HUD_GunKataChargeImage2.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeImage2.Hide();
		HUD_GunKataChargeImage3 = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack");
		HUD_GunKataChargeImage3.SetX(default.HUD_STACK_BASE_X + (default.HUD_STACK_OFFSET_X) * 3);
		HUD_GunKataChargeImage3.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeImage3.Hide();
		HUD_GunKataChargeImage4 = Spawn(class'UIImage', self).InitImage('',"img:///WP_Akimbo.UIImages.UIImage_ActionStack");
		HUD_GunKataChargeImage4.SetX(default.HUD_STACK_BASE_X + (default.HUD_STACK_OFFSET_X) * 4);
		HUD_GunKataChargeImage4.SetY(default.HUD_BASE_Y);
		HUD_GunKataChargeImage4.Hide();
		Hide();
	}
	else
	{
		//UITacticalHUD(Screen).m_kInventory.m_kBackpack.Update( kActiveUnit );
		if( LastVisibleActiveUnitID != kActiveUnit.ObjectID )
		{
			SetStats(kActiveUnit);
			SetHackingInfo(kActiveUnit);

			UpdateFocusLevelVisibility(kActiveUnit);
		}
		Show();
		SetGunKataCharge(kActiveUnit);
		LastVisibleActiveUnitID = kActiveUnit.ObjectID;
	}

	//This displays the L3 icon, which we need to handle dynamically from Unrealscript
	//AS_ToggleSoldierInfoTip(true);
}

simulated function SetGunKataCharge(XGUnit ActiveUnit)
{
	local XComGameState_Unit UnitState;
	local UnitValue NewGunKataCharge;
	//local int MaxGunKataCharge;

	//MaxGunKataCharge = class'X2Ability_NewSkirmisher'.default.GunKataCharge_MAXGunKataCharge;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ActiveUnit.ObjectID));
	if (UnitState.HasSoldierAbility('GunKataCharge_Passive'))
	{	
		UnitState.GetUnitValue(class'X2Effect_GunKataCharge'.default.GunKataChargeValue, NewGunKataCharge);
		HUD_GunKataChargeIconImage.Show();
		HUD_GunKataChargeBlankImage.Show();
		HUD_GunKataChargeImage.Hide();
		HUD_GunKataChargeImage1.Hide();
		HUD_GunKataChargeImage2.Hide();
		HUD_GunKataChargeImage3.Hide();
		HUD_GunKataChargeImage4.Hide();
		if (NewGunKataCharge.fvalue > 0)
		{
			HUD_GunKataChargeImage.Show();
			if (NewGunKataCharge.fvalue > 1)
			{
				HUD_GunKataChargeImage1.Show();
				if (NewGunKataCharge.fvalue > 2)
				{
					HUD_GunKataChargeImage2.Show();
					if (NewGunKataCharge.fvalue > 3)
					{
						HUD_GunKataChargeImage3.Show();
						if (NewGunKataCharge.fvalue > 4)
						{	
							HUD_GunKataChargeImage4.Show();
						}
					}
				}
			}
		}
	}
	else
	{
		HUD_GunKataChargeIconImage.Hide();
		HUD_GunKataChargeBlankImage.Hide();
		HUD_GunKataChargeImage.Hide();
		HUD_GunKataChargeImage1.Hide();
		HUD_GunKataChargeImage2.Hide();
		HUD_GunKataChargeImage3.Hide();
		HUD_GunKataChargeImage4.Hide();
	}
}