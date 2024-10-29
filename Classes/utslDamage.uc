//=============================================================================
// utslDamage.
//=============================================================================
class utslDamage expands Mutator;


struct PlayerDamage{
	var int PID;
	var int DamageTaken;
	var int DamageDelt;
	var int SelfDamage;
};

var PlayerDamage DamageList[64];

//if player id doesnt exist return the index of the next empty DamageList
function int getPlayerIndexById(int TargetId){

	local int i;
	local PlayerDamage P;
	
	for(i = 0; i < 64; i++){
	
		P = DamageList[i];
		
		if(P.PID == -1){
			log("set new player INDEX");
			DamageList[i].PID = TargetId;
			return 1;
		}
		if(P.PID == TargetId) return i;
	}

	return -1;
}

function updateDamageDelt(PlayerReplicationInfo pInfo, int DamageDelt){

	
	local int dIndex;
	local PlayerDamage D;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageDelt)");
		return;
	}
	
	//D = DamageList[dIndex];
	DamageList[dIndex].DamageDelt += DamageDelt;
}

function updateDamageTaken(PlayerReplicationInfo pInfo, int DamageTaken){

	
	local int dIndex;
	local PlayerDamage D;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageTaken)");
		return;
	}
	
	//D = DamageList[dIndex];
	DamageList[dIndex].DamageTaken += DamageTaken;
}


function printLog(string s){

	if(Level.Game.LocalLog == None){
		log("LocalLog is None");
		return;
	}
	Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp() $ Chr(9) $ s);
}

function PostBeginPlay(){
	
	local int i;
	local Mutator M;

	for(i = 0; i < 64; i++){
	
		DamageList[i].PID = -1;
	}
	
	
	printLog("Does this work?");

	Level.Game.RegisterDamageMutator(self);
	
	foreach AllActors(class'mutator', M){
		
		if(M == class'utslDamage') return;
	}
	Level.Game.BaseMutator.AddMutator(self);
	//Level.Game.RegisterMessageMutator(self);
}



function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType){
	
	local PlayerReplicationInfo Vpri;
	local PlayerReplicationInfo Ipri;
	
	//ADD CHECK FOR SELF DAMAGE AND KEEP TRACK DIFFERENTLY

	
	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
		log(Vpri.PlayerName $ chr(9) $ " took " $chr(9)$ ActualDamage  $chr(9)$" damage");
	}
	
	if(InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		updateDamageDelt(Ipri, ActualDamage);
		printLog("d"$chr(9)$Ipri.PlayerId$chr(9)$ActualDamage);
		
		log(Ipri.PlayerName $ chr(9) $ " delt " $chr(9)$ ActualDamage  $chr(9)$" damage");
	}

   if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}
//doesnt work if mutator is a damage mutator
function bool HandleEndGame(){

	
	local int i;
	local PlayerDamage d;
	
	log("HANDNADNSDJSNADJASNDJNASJDNASJIDNASJINDASIONDIOASNDIOASNDIOANSIODNASION");
	
	for(i = 0; i < 64; i++){
		
		d = DamageList[i];
		log(i);
		//if(d.PID == -1) break;
		printLog("sld" $chr(9)$ d.PID $chr(9)$ d.DamageDelt $chr(9)$d.DamageTaken);
	}
	
	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}


function bool HandleRestartGame()
{

	log("#################################################################################asssssssssssssssssssssssssssssss########");
	if ( NextMutator != None )
		return NextMutator.HandleRestartGame();
	return false;
}

defaultproperties
{
}
