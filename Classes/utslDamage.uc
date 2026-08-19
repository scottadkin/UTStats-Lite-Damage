//=============================================================================
// utslDamage.
//=============================================================================
class utslDamage expands Mutator config(UTStatsLiteDamage);

//if set to false when dealing 100 damage to a player with 2 health, the damage is counted as 2 rather than 100
var config bool bIncludeAllDamageDone;
var bool bTeamGame;



var config string ImpactHammerName;
//impact for both
var config name ImpactHammerDamageType;
var config name ImpactHammerAltDamageType;

var config string EnforcerName;
//shot for both
var config name EnforcerDamageType;
var config name EnforcerAltDamageType;

var config string BioRifleName;
//Corroded for both
var config name BioRifleDamageType;
var config name BioRifleAltDamageType;

var config string ShockRifleName;
//jolted for both
var config name ShockRifleDamageType;
var config name ShockRifleAltDamageType;

var config string PulseRifleName;
//Pulsed
var config name PulseRifleDamageType;
//zapped
var config name PulseRifleAltDamageType;

var config string RipperName;
//shredded
var config name RazorDamageType;
//RipperAltDeath
var config name RazorAltDamageType;


var config string MinigunName;
//shot
var config name MinigunDamageType;
var config name MinigunAltDamageType;

var config string FlakCannonName;
//shredded
var config name FlakCannonDamageType;
//FlakDeath
var config name FlakCannonAltDamageType;


var config string RocketLauncherName;
//RocketDeath
var config name RocketLauncherDamageType;
//GrenadeDeath
var config name RocketLauncherAltDamageType;

var config string SniperRifleName;
//shot
var config name SniperRifleDamageType;
var config name SniperRifleAltDamageType;

var config string RedeemerName;
//RedeemerDeath
var config name RedeemerDamageType;
var config name RedeemerAltDamageType;


var config name DecapitatedDamageType;


//also need to add Decapitated to each weapon...

struct PlayerWeaponDamage{
	var string WeaponName;
	var int DamageDelt;
};

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
	var PlayerWeaponDamage WeaponDamage[32];
};

var PlayerDamage DamageList[255];
//var PlayerWeaponDamage PlayerWeaponDamageList[2048];


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



function int getPlayerWeaponIndex(int PlayerIndex, string WeaponName){

	local int i;
	
	
	for(i = 0; i < 32; i++){
		
		if(DamageList[PlayerIndex].WeaponDamage[i].WeaponName == WeaponName){
		
			return i;
		
		}
		
		if(DamageList[PlayerIndex].WeaponDamage[i].WeaponName == ""){
			DamageList[PlayerIndex].WeaponDamage[i].WeaponName = WeaponName;
			return i;
		}
	}
		
	return -1;
}

function UpdatePlayerWeaponStats(PlayerReplicationInfo PRI, string WeaponName, int Damage, name DamageType){

	local int WeaponIndex;
	local int PlayerIndex;
	
	PlayerIndex = getPlayerIndexById(PRI.PlayerId);
	
	if(PlayerIndex == -1){
	
		log("failed to find player index");
		return;
	}		


    log(DamageType $chr(9)$WeaponName$chr(9)$RocketLauncherDamageType);

    if((DamageType == RocketLauncherDamageType || DamageType == RocketLauncherAltDamageType) && WeaponName != RocketLauncherName){

        log("rocket launcher damage type, but player not holding rocket launcher"$chr(9)$weaponName);

        WeaponName = RocketLauncherName;

    }else if((DamageType == PulseRifleDamageType || DamageType == PulseRifleAltDamageType) && WeaponName != PulseRifleName){

        log("pulse damage but player not holding pulse rifle");
        WeaponName = PulseRifleName;

    }else if((DamageType == BioRifleDamageType || DamageType == BioRifleAltDamageType) && WeaponName != BioRifleName){

        log("bio damage but player not holding bio");
        WeaponName = BioRifleName;
    }

		
	WeaponIndex = getPlayerWeaponIndex(PlayerIndex, WeaponName);
	
	if(WeaponIndex == -1){
		log("Failed to get player's weapon index");
		return;
	}
	
	DamageList[PlayerIndex].WeaponDamage[WeaponIndex].DamageDelt += Damage;
			
}

function updateStats(Pawn Victim, Pawn InstigatedBy, name DamageType, int DamageDone){

	local PlayerReplicationInfo VPRI;
	local PlayerReplicationInfo IPRI;

	local string InstigatedByWeaponName;


	
	if(Victim.PlayerReplicationInfo != None){
	
		Vpri = Victim.PlayerReplicationInfo;
	}
	
	if(InstigatedBy != None && InstigatedBy.PlayerReplicationInfo != None){
	
		Ipri = InstigatedBy.PlayerReplicationInfo;
		
		if(Victim != None && Vpri != None && Vpri.PlayerID != Ipri.PlayerID){		
		
			if(InstigatedBy.Weapon != None){
				InstigatedByWeaponName = InstigatedBy.Weapon.ItemName;
			}
		
			UpdatePlayerWeaponStats(Ipri ,InstigatedByWeaponName, DamageDone, DamageType);
		}
	}
	
	
	if(InstigatedBy != None && InstigatedBy.IsA('StationaryPawn') && Vpri != None){
		
		updateDamage(Vpri, 'cannon', DamageDone);	
		return;
	
	}

	
	if(InstigatedBy == None){
		
		if(DamageType == 'Fell'){
			updateDamage(Vpri, 'fell', DamageDone);
			return;
		}
		
		if(DamageType == 'Drowned'){
			updateDamage(Vpri, 'drown', DamageDone);
			return;
		}
	}
	

	
	if(Vpri != None && Ipri != None){
	
	
		if(VPri.PlayerId == Ipri.PlayerID){
		
			updateDamage(Ipri, 'self', DamageDone);
			return;
		}
	

		
		if(!bTeamGame){
		
			updateDamage(Ipri, 'delt', DamageDone);
			updateDamage(Vpri, 'taken', DamageDone);
			return;
			
		}else{
			
			if(Vpri.Team == Ipri.Team){
			
				updateDamage(Ipri, 'teamDelt', DamageDone);
				updateDamage(Vpri, 'teamTaken', DamageDone);
				return;
				
			}else{
			
				updateDamage(Ipri, 'delt', DamageDone);
				updateDamage(Vpri, 'taken', DamageDone);
				return;
				
			}				
		}		
	}
	
	if(Vpri != None && Ipri == None){
		
		updateDamage(Vpri, 'taken', DamageDone);
		return;
	}
	
	if(Vpri == None && Ipri != None){
		updateDamage(Ipri, 'delt', DamageDone);
		return;
	}

}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType){
	
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
		FixedDamage = Victim.Health;
	}
	
	updateStats(Victim, InstigatedBy, DamageType, fixedDamage);

	

   	if (NextDamageMutator != None)
        NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

function bool HandleEndGame(){

	local int i;
	local PlayerDamage D;
	local int x;
	
	for(i = 0; i < 255; i++){
		
		D = DamageList[i];
		if(d.PID == -1) break;
		printLog("d" $chr(9)$ D.PID $chr(9)$ D.DamageDelt $chr(9)$D.DamageTaken$chr(9)$D.SelfDamage$chr(9)$D.teamDamageDelt$chr(9)$D.teamDamageTaken$chr(9)$D.FallDamage$chr(9)$D.DrownDamage$chr(9)$D.CannonDamage);
		
		for(x = 0; x < 32; x++){
		
			if(D.WeaponDamage[x].WeaponName == ""){
				break;
			}
			
			printLog("wd"$chr(9)$D.PID$chr(9)$D.WeaponDamage[x].WeaponName$chr(9)$D.WeaponDamage[x].DamageDelt);
		}
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
