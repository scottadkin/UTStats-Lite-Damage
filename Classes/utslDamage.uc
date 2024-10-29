//=============================================================================
// utslDamage.
//=============================================================================
class utslDamage expands Mutator;


struct PlayerDamage{
	var int PID;
	var int DamageTaken;
	var int DamageDelt;
};

var PlayerDamage DamageList[64];

function PostBeginPlay(){
	
	local int i;

	for(i = 0; i < 64; i++){
	
		DamageList[i].PID = -1;
	}

	Level.Game.RegisterDamageMutator(self);
}

//if player id doesnt exist return the inedx of the next empty DamageList
function int getPlayerIndexById(){

	local int i;
	local PlayerDamage P;
	
	for(i = 0; i < 64; i++){
	
		P = DamageList[i];
		
		if(P.PID == -1)	return 1;
	}

	return -1;
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
	
	local PlayerReplicationInfo Vpri;
	local PlayerReplicationInfo Ipri;
	
	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
		log(Vpri.PlayerName $ chr(9) $ " took " $chr(9)$ ActualDamage  $chr(9)$" damage");
	}
	
	if(InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		
		log(Ipri.PlayerName $ chr(9) $ " delt " $chr(9)$ ActualDamage  $chr(9)$" damage");
	}

   if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

defaultproperties
{
}
