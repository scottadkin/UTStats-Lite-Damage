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

event PreBeginPlay()
{
    local Actor A;
    
    Super.PreBeginPlay();
    
    foreach AllActors(Class, A)
        break;
    if (A != self)
        return;
        
    Level.Game.BaseMutator.AddMutator(self);
}

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

function updateDamageDelt(PlayerReplicationInfo pInfo, int DamageDelt, bool bSelfDamage){

	
	local int dIndex;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageDelt)");
		return;
	}
	
	if(!bSelfDamage){
		DamageList[dIndex].DamageDelt += DamageDelt;
	}else{
		DamageList[dIndex].SelfDamage += DamageDelt;
	}
}

function updateDamageTaken(PlayerReplicationInfo pInfo, int DamageTaken){

	
	local int dIndex;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageTaken)");
		return;
	}
	
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

	for(i = 0; i < 64; i++){
	
		DamageList[i].PID = -1;
	}
	
	
	Level.Game.RegisterDamageMutator(self);
	
	/*foreach AllActors(class'mutator', M){
		
		if(M != self) return;
	}
	Level.Game.BaseMutator.AddMutator(self);*/
	//Level.Game.RegisterMessageMutator(self);
}



function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType){
	
	local PlayerReplicationInfo Vpri;
	local PlayerReplicationInfo Ipri;
	
	
	//only want 2 damage counted if a player did 100 damage to a player with 2 health left
	local int FixedDamage;
	local int VictimHealth;
	local int InstigatorHealth;
	
	fixedDamage = ActualDamage;

	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
	}
	
	if(InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		
	}
	
	/*InstigatorHealth = InstigatedBy.Health;
	VictimHealth = Victim.Health;
	
	if(ActualDamage > VictimHealth){
		fixedDamage = VictimHealth;	
	}*/
	
	//some times health is negative
	if(fixedDamage < 0) fixedDamage = 0;
	
	if(Vpri != None && Ipri != None){
	
		if(Vpri.PlayerID != Ipri.PlayerID){
		
			updateDamageDelt(Ipri, fixedDamage, false);
			updateDamageTaken(Vpri, fixedDamage);
			
		}else{
			log(Ipri.PlayerName$chr(9)$InstigatedBy.Health$Ipri$chr(9)$fixedDamage);
			updateDamageDelt(Ipri, fixedDamage, true);
		}
	}
	
	if(Vpri != None && Ipri == None){
		
		updateDamageTaken(Vpri, fixedDamage);
	}
	
	if(Vpri == None && Ipri != None){
	
		updateDamageDelt(Ipri, fixedDamage, false);
	}

   if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

function bool HandleEndGame(){

	local int i;
	local PlayerDamage d;
	
	for(i = 0; i < 64; i++){
		
		d = DamageList[i];
		if(d.PID == -1) break;
		printLog("sld" $chr(9)$ d.PID $chr(9)$ d.DamageDelt $chr(9)$d.DamageTaken$chr(9)$d.SelfDamage);
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
