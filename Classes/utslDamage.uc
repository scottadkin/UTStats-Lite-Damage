//=============================================================================
// utslDamage.
//=============================================================================
class utslDamage expands Mutator;

var bool bTeamGame;

struct PlayerDamage{
	var int PID;
	var int DamageTaken;
	var int DamageDelt;
	var int SelfDamage;
	var int TeamDamageDelt;
	var int TeamDamageTaken;
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
			DamageList[i].PID = TargetId;
			return 1;
		}
		if(P.PID == TargetId) return i;
	}

	return -1;
}


function updateDamage(PlayerReplicationInfo pInfo, string type, int Damage){

	local int dIndex;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageTaken)");
		return;
	}
	
	switch(type){
		case "delt": 
			DamageList[dIndex].DamageDelt += Damage;
		 break;
		case "taken": 
			DamageList[dIndex].DamageTaken += Damage;
		 break;
		case "self": 
			DamageList[dIndex].SelfDamage += Damage;
		break;
		case "teamDelt":
			DamageList[dIndex].TeamDamageDelt += Damage;
		break;
		case "teamTaken":
			DamageList[dIndex].TeamDamageTaken += Damage;
		break;
		default:
			log("Unkown damage type");
		break;
	}
	

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
	
	bTeamGame = Level.Game.bTeamGame;

	for(i = 0; i < 64; i++){
	
		DamageList[i].PID = -1;
	}
	
	Level.Game.RegisterDamageMutator(self);
	
}



function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType){
	
	local PlayerReplicationInfo Vpri;
	local PlayerReplicationInfo Ipri;
	
	
	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
	}
	
	if(InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		
	}
	

	if(Vpri != None && Ipri != None){
	
		if(Vpri.PlayerID != Ipri.PlayerID){
		
			if(!bTeamGame){
			
				updateDamage(Ipri, "delt", ActualDamage);
				updateDamage(Vpri, "taken", ActualDamage);
				
			}else{
				
				if(Vpri.Team == Ipri.Team){
				
					updateDamage(Ipri, "teamDelt", ActualDamage);
					updateDamage(Vpri, "teamTaken", ActualDamage);
				}else{
				
					updateDamage(Ipri, "delt", ActualDamage);
					updateDamage(Vpri, "taken", ActualDamage);
				}				
			}
			
		}else{
			updateDamage(Ipri, "self", ActualDamage);
		}
	}
	
	if(Vpri != None && Ipri == None){
		
		updateDamage(Vpri, "taken", ActualDamage);
	}
	
	if(Vpri == None && Ipri != None){
		updateDamage(Ipri, "delt", ActualDamage);
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
		printLog("d" $chr(9)$ d.PID $chr(9)$ d.DamageDelt $chr(9)$d.DamageTaken$chr(9)$d.SelfDamage$chr(9)$d.teamDamageDelt$chr(9)$d.teamDamageTaken);
	}
	
	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}

defaultproperties
{
}
