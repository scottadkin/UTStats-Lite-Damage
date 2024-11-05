//=============================================================================
// utslDamage.
//=============================================================================
class utslDamage expands Mutator config(UTStatsLiteDamage);

//if set to false when dealing 100 damage to a player with 2 health, the damage is counted as 2 rather than 100
var config bool bIncludeAllDamageDone;
var bool bTeamGame;

struct PlayerDamage{
	var int PID;
	var int DamageTaken;
	var int DamageDelt;
	var int SelfDamage;
	var int TeamDamageDelt;
	var int TeamDamageTaken;
	var int FallDamage;
	var int DrownDamage;
	var int CannonDamage;
};

var PlayerDamage DamageList[255];

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

//if player id doesnt exist set the playerID and return the index of the next empty DamageList
function int getPlayerIndexById(int TargetId){

	local int i;
	
	for(i = 0; i < 255; i++){
	
		if(DamageList[i].PID == -1){
			DamageList[i].PID = TargetId;
			return i;
		}
		if(DamageList[i].PID == TargetId) return i;
	}

	return -1;
}


function updateDamage(PlayerReplicationInfo pInfo, name type, int Damage){

	local int dIndex;
	
	dIndex = getPlayerIndexById(pInfo.PlayerID);
	
	if(dIndex == -1){
		log("Failed to get playerDamage(updateDamageTaken)");
		return;
	}
	
	switch(type){
		case 'delt': 
			DamageList[dIndex].DamageDelt += Damage;
		 break;
		case 'taken': 
			DamageList[dIndex].DamageTaken += Damage;
		 break;
		case 'self': 
			DamageList[dIndex].SelfDamage += Damage;
		break;
		case 'teamDelt':
			DamageList[dIndex].TeamDamageDelt += Damage;
		break;
		case 'teamTaken':
			DamageList[dIndex].TeamDamageTaken += Damage;
		break;
		case 'fell':
			DamageList[dIndex].FallDamage += Damage;
		break;
		case 'drown':
			DamageList[dIndex].DrownDamage += Damage;
		break;
		case 'cannon':
			DamageList[dIndex].CannonDamage += Damage;
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

	for(i = 0; i < 255; i++){
	
		DamageList[i].PID = -1;
	}
	
	Level.Game.RegisterDamageMutator(self);
	
}



function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType){
	
	local PlayerReplicationInfo Vpri;
	local PlayerReplicationInfo Ipri;
	local bool bDamageApplied;
	local int FixedDamage;
	local DamageTracker DT;
	
	
	FixedDamage = ActualDamage;
	
	DT = FindTracker(Victim);
	
	if (DT != none){
		FixedDamage = DT.LastDamage;
		
	}else{
		log("TRACKER IS NONE, fallingback to ActualDamage");
	}
	
	
	if(!bIncludeAllDamageDone && Victim != None && Victim.Health < FixedDamage){
	
		log("More damage was done then the player had health"$chr(9)$Victim.Health$chr(9)$" -> " $FixedDamage);
		
		FixedDamage = Victim.Health;
	
	}else if(bIncludeAllDamageDone){
		log("BIncludeAllDamageDone is True");
	}
	
	

	
	bDamageApplied = false;
	
	
	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
	}
	
	if(InstigatedBy != None && InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		
	}
	
	
	if(InstigatedBy != None && InstigatedBy.IsA('StationaryPawn') && Vpri != None){
		
		updateDamage(Vpri, 'cannon', FixedDamage);	
		bDamageApplied = true;
	
	}

	
	if(InstigatedBy == None && !bDamageApplied){
		
		if(DamageType == 'Fell'){
			updateDamage(Vpri, 'fell', FixedDamage);
			bDamageApplied = true;
		}
		
		if(DamageType == 'Drowned'){
			updateDamage(Vpri, 'drown', FixedDamage);
			bDamageApplied = true;
		}
	}
	

	
	if(Vpri != None && Ipri != None && !bDamageApplied){
	
	
		if(VPri.PlayerId == Ipri.PlayerID){
		
			bDamageApplied = true;	
			updateDamage(Ipri, 'self', FixedDamage);
		}
	
		if(!bDamageApplied){
		
			if(!bTeamGame){
			
				updateDamage(Ipri, 'delt', FixedDamage);
				updateDamage(Vpri, 'taken', FixedDamage);
				bDamageApplied = true;
				
			}else{
				
				if(Vpri.Team == Ipri.Team){
				
					updateDamage(Ipri, 'teamDelt', FixedDamage);
					updateDamage(Vpri, 'teamTaken', FixedDamage);
					bDamageApplied = true;
					
				}else{
				
					updateDamage(Ipri, 'delt', FixedDamage);
					updateDamage(Vpri, 'taken', FixedDamage);
					bDamageApplied = true;
					
				}				
			}	
		}
	}
	
	if(!bDamageApplied && Vpri != None && Ipri == None){
		
		updateDamage(Vpri, 'taken', FixedDamage);
		bDamageApplied = true;
	}
	
	if(!bDamageApplied && Vpri == None && Ipri != None){
		updateDamage(Ipri, 'delt', FixedDamage);
		bDamageApplied = true;
	}
	

   	if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

function bool HandleEndGame(){

	local int i;
	local PlayerDamage d;

	
	for(i = 0; i < 255; i++){
		
		d = DamageList[i];
		if(d.PID == -1) break;
		printLog("d" $chr(9)$ d.PID $chr(9)$ d.DamageDelt $chr(9)$d.DamageTaken$chr(9)$d.SelfDamage$chr(9)$d.teamDamageDelt$chr(9)$d.teamDamageTaken$chr(9)$d.FallDamage$chr(9)$d.DrownDamage$chr(9)$d.CannonDamage);
	}
	
	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}


//below taken from Deaod's method https://github.com/Deaod/InstaGibPlus/blob/master/Classes/IGPlus_HitFeedback.uc

function DamageTracker FindTracker(Pawn P) {
	local Inventory I;

	for (I = P.Inventory; I != none; I = I.Inventory)
		if (I.IsA('DamageTracker'))
			return DamageTracker(I);

	return none;
}

function CreateTracker(Pawn P) {
	local DamageTracker T;
	T = Spawn(class'DamageTracker');
	T.GiveTo(P);
}

function ModifyPlayer(Pawn P) {
	super.ModifyPlayer(P);

	if (FindTracker(P) == none)
		CreateTracker(P);
}

defaultproperties
{
	bIncludeAllDamageDone=True
}
