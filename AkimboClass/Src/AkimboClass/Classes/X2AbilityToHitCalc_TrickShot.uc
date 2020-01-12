class X2AbilityToHitCalc_TrickShot extends X2AbilityToHitCalc_StandardAim config(Akimbo);	//this custom ToHitCalc adds an aim modifier to Trick Shot

var config array<config int> AimModifier;

function int GetWeaponRangeModifier(XComGameState_Unit Shooter, XComGameState_Unit Target, XComGameState_Item Weapon)
{
    local int Tiles, Modifier;

    if (Shooter != none && Target != none)
    {
            Tiles = Shooter.TileDistanceBetween(Target);
            if (default.AimModifier.Length > 0)
            {
                if (Tiles < default.AimModifier.Length)
                    Modifier = default.AimModifier[Tiles];
                else  //  if this tile is not configured, use the last configured tile                    
                    Modifier = default.AimModifier.Length-1;
            }
    }

    return Modifier;
}