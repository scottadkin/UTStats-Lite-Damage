//=============================================================================
// DamageTracker.
// Deaod's Method https://github.com/Deaod/InstaGibPlus/blob/master/Classes/IGPlus_HitFeedbackTracker.uc
//=============================================================================
class DamageTracker expands TournamentPickup;

var int LastDamage;

function bool HandlePickupQuery(Inventory Item) {
	if (Inventory != none)
		return Inventory.HandlePickupQuery(Item);
	return false;
}

function Inventory PrioritizeArmor(int Damage, name DamageType, vector HitLocation) {
	LastDamage = Damage;
	return super.PrioritizeArmor(Damage, DamageType, HitLocation);
}

defaultproperties
{
}
