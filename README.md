# UTStats-Lite-Damage
 Damage Addon for UTStats Lite Mutator

 Basic damage logging for players:
 - Damage Delt
 - Damage Received
 - Self Damage Taken
 - Team Damage Delt
 - Team Damage Taken
 - Drown Damage Taken
 - Fall Damage Taken

## Test Weapon Damage System
- Most reliable for hitscan weapons.
- Projectile weapons have additional options in **UTStatsLiteDamage.ini**, you can set the primary damage type as well as the alt damage type, this will allow mods that change the damage types to be supported with a simple config change. Default UT weapons have duplicated damage types for projectiles for flak cannon primary, ripper primary and this method won't be as reliable for those weapons. 


## Installing
 Add the following lines to your UnrealTournament.ini file in the section labeled **Engine.GameEngine**:
``` 
ServerPackages=UTStatsLiteDamage
ServerActors=UTStatsLiteDamage.utslDamage
```

## Thanks to Deaod For Armor Fix Method & Feedback/Pointers.