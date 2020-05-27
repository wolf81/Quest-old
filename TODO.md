# TODO


## Refactor visibility & movement graph creation

I feel this code code be cleaner and more efficient. Some things to consider: 
- It feels to me the game should be responsible for managing the visibility / movement graphs. 
- We might do a lot of extra avoidable work when creating the graphs, since we regenerate these for every movement. Perhaps it's better to generate a movement graph once the map is generated and then only make modifications when needed (i.e. after a character is moved, add a connected graph node for the old position and remove a graph node for the new position ... something similar could happen for doors, i.e.: add a graph node when door is opened, remove it when it's closed)


## Carrying and using a second set of weapons

The paperdoll should be expanded with a second set of lefthand / righthand equipment nodes. Equipment can be added there, but is ignored for the player avatar. There should be a button (R?) that can be used to switch between the equipped weapons, so a player or monster can switch between melee and ranged for example. 

Ranged weapons need a melee attack penalty.

We also need a target button (T?) that shows a targeting indicator on the screen. When multiple enemies are visible and depending on the active equipment, the user can use the target button to select a visible target for attacking.

The above means we also need an attack button (Space?)


## Encounter generation

On map creation, in several areas (perhaps rooms only for now) an encounter should be generated. Once the hero comes somewhat close to the encouter coordinate, then the encounter can be replaced for monsters by the game state. The monsters could be placed on player level. Normal encounters might create a total HD of monsters equal to player level, but more difficult encounters might create additional HD of monsters. 

Perhaps monsters should not grant experience directly, but the encounter should grant it instead after all monsters have been defeated. This seems to make sense, because doubling HD of monsters shouldn't mean doubling the experience, according to Microlite20 rules.


## Console

We should have a console that can be activated using a special key (\~). The console then pops up and gains focus and allows the user to enter a command. We could have a level up command that would instantly give the player enough experience for the next level. This can be useful for testing encounters.


## Add decorations to rooms

Tilesets should have a list of decorations that can randomly be added to rooms. On room creation and depending on the size of the room several decorations might be added. Decorations like statues might help create a tactical element.


## Secret doors

We need to add secret doors as indicated by the dungeon generator. Secret doors could be discovered automatically if the player has a high subterfuge score or perhaps by using spells.


## Buggy movement animations

It seems there's a bug happening when a monster is invisible because out of range but walks multiple steps towards the hero. Then, the second time the monster moves it stays invisible until arriving close to the player, making the monster appear to move very quickly when coming out of the fog of war. This is mainly visible with a skeleton



