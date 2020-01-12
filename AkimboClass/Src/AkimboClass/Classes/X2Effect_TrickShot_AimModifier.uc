class X2Effect_TrickShot_AimModifier extends X2Effect_Persistent config (Akimbo);	//currently unused
																					//this is an alternative way to apply an aim modifier to ability
var config array<config int> AimModifier;											

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local int Tiles;
    local XComGameState_Item SourceWeapon;
    local ShotModifierInfo ShotInfo;

    SourceWeapon = AbilityState.GetSourceWeapon();
    //`LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.ObjectID @ EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID,, 'Akimbo');
    if(SourceWeapon != none && SourceWeapon.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
    {

        Tiles = Attacker.TileDistanceBetween(Target);
        if(AimModifier.Length > 0)
        {
            if(Tiles < AimModifier.Length)
            {
                ShotInfo.Value = AimModifier[Tiles];
            }
            else //Use last value
            {
                ShotInfo.Value = AimModifier[AimModifier.Length - 1];
            }

           // `LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.GetMyTemplateName() @ "modifying range by" @ ShotInfo.Value,, 'Akimbo');
            ShotInfo.ModType = eHit_Success;
            ShotInfo.Reason = FriendlyName; //class'XLocalizedData'.default.WeaponRange;
            ShotModifiers.AddItem(ShotInfo);
        }
    }
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
}