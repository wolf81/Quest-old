[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

#  DungeonBuilder

A 2D dungeon maze builder written in Swift.

The code is based on the Perl and JavaScript versions written by [Donjon](https://donjon.bin.sh). The Perl and JavaScript versions can be found in the [Donjon directory](https://github.com/wolf81/DungeonBuilder/tree/master/Donjon) for reference.

**_PLEASE NOTE: The code isn't the cleanest Swift possible. For now I've just created a mostly 1-on-1 conversion of the Perl & JavaScript versions written by DonJon. At least the interface is pretty clean, even if the internals are not._**

## Features

- Dungeons of various sizes, from fine to collosal
- Rooms of various sizes, from small to collosal
- Rooms can be densely packed or scattered
- Corridors can be straight, curved or in between
- Optionally remove some or all dead-ends
- Dungeons can be created using various layouts, e.g. keep or hexagon
- Different types of doors are placed, e.g.: normal, trapped, locked, etc...
- Optionally use your own (random) number generator

## Installation

DungeonBuilder can be installed using Carthage. Simply add the following line to your Cartfile:

    github "wolf81/DungeonBuilder"

Then follow [the remaining steps from the Carthage guide](https://github.com/Carthage/Carthage).

## Usage

1. Add this project as a library to some other project.
2. Create an instance of `DungeonBuilder` and provide it with a `Configuration` and optionally your own number generator that conforms to the `NumberGeneratable` protocol.
3. Call the `build` method on your instance of `DungeonBuilder` to create a dungeon. A `Dungeon` will be returned. 

By default a build-in random number generator is used. This build-in random number generator is seeded with the name of the dungeon. This means that everytime the same name and configuration is used to build a dungeon, the same dungeon layout is re-created as well.

The `Dungeon` contains a 2-dimensional array of nodes. A node can be retrieved from the dungeon as follows:

    let dungeonBuilder = DungeonBuilder(configuration: Configuration.Default)
    let dungeon = dungeonBuilder.build(name: "Cellar of Bloody Death")
    let node = dungeon[Coordinate(1, 5)] 

The top left node starts at `Coordinate(0,0)` and the bottom right node stops at `Coordinate(dungeon.width - 1, dungeon.height - 1)`. Each `Node` is an `OptionSet`. Use the various flags to see what the node represents. E.g.: 

    if node.contains(.room) {
        // this node is a room
    } 
    
    if node.contains(.corridor) {
        // this node is a corridor
    }

Print the dungeon to see a simplified map in the debug console. For example when printing out a small sized dungeon, the output might look as follows:

                                                                                          
         • • • • • • • • • • •                       ` ` ` ` ` ` ` ` ` ` ` ⁑ • • • • • • •  
         ∩                   ⁑                       ` ` ` ` ` ` ` ` ` ` `               •  
     ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `               •  
     ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `               •  
     ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •  
     ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` 1 4 ` ` ` `   ` ` ` ` `   •  
     ` ` ` ` `               ` ` ` ` ` 2 ` ` ` ` ` ‡ ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •  
     ` ` 1 2 `               ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •  
     ` ` ` ` `   ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` ` ‼ ` ` ` ` `   •  
     ` ` ` ` `   ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` 7 ` `   •  
     ` ` ` ` ` Φ ` ` 1 ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •  
     ` ` ` ` `   ` ` ` ` `                                                   ` ` ` ` `   •  
     ` ` ` ` `   ` ` ` ` `       • • • • • Φ ` ` ` ` ` ` ` ` ` ` ` ` ` ∩ •   ` ` ` ` `   •  
     Π               Π           •           ` ` ` ` ` ` ` ` ` ` ` ` `   •   ` ` ` ` `   •  
     •   ` ` ` ` ` ` ` ` ` ` `   •           ` ` ` ` ` ` ` ` ` ` ` ` `   •   ` ` ` ` `   •  
     •   ` ` ` ` ` ` ` ` ` ` `   •           ` ` ` ` ` ` ` ` ` ` ` ` `   •       ∩       •  
     • ‡ ` ` ` ` ` ` ` ` ` ` `   •           ` ` ` ` ` ` 6 ` ` ` ` ` ` Π •   ` ` ` ` ` Π •  
         ` ` ` ` ` ` ` ` ` ` `   •           ` ` ` ` ` ` ` ` ` ` ` ` `       ` ` ` ` `      
         ` ` ` ` ` ` ` ` ` ` ` Φ •           ` ` ` ` ` ` ` ` ` ` ` ` ` Φ • Π ` ` ` ` ` Φ •  
         ` ` ` ` ` 3 ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` ` ` `       ` ` ` ` `   •  
         ` ` ` ` ` ` ` ` ` ` `               ` ` ` ` ` ` ` ` ` ` ` ` `       ` ` ` ` `   •  
         ` ` ` ` ` ` ` ` ` ` `                                               ` ` 8 ` `   •  
     • Π ` ` ` ` ` ` ` ` ` ` `           • • • • • • •           • • • • • ‡ ` ` ` ` `   •  
     •   ` ` ` ` ` ` ` ` ` ` `           •           •           •           ` ` ` ` `   •  
     •   ` ` ` ` ` ` ` ` ` ` `           •   • • • • • • • • • • •   • • • ∩ ` ` ` ` `   •  
     •                   Π               •   •                       •       ` ` ` ` `   •  
     • • • • • • • • • • •               •   •   ` ` ` ` ` ` ` ` `   •       ` ` ` ` `   •  
     Π               •   •               •   •   ` ` ` ` ` ` ` ` `   •                   •  
     ` ` ` ` `       •   • • • • • • • • •   •   ` ` ` ` ` ` ` ` `   •   • • • • • • • • •  
     ` ` ` ` `       •                       •   ` ` ` ` ` ` ` ` `   •   •               •  
     ` ` ` ` `       • ⁑ ` ` ` ` ` ` ` ` `   • ‼ ` ` ` ` 4 ` ` ` `   •   •               •  
     ` ` ` ` `       •   ` ` ` ` ` ` ` ` `       ` ` ` ` ` ` ` ` `   •   Π               •  
     ` ` ` ` ` Π • • •   ` ` ` ` 1 0 ` ` `       ` ` ` ` ` ` ` ` `   •   ` ` ` ` `       •  
     ` ` 9 ` `           ` ` ` ` ` ` ` ` `       ` ` ` ` ` ` ` ` `   •   ` ` ` ` `       •  
     ` ` ` ` `           ` ` ` ` ` ` ` ` `       ` ` ` ` ` ` ` ` `   • Φ ` ` ` ` `       •  
     ` ` ` ` `                                               ‼           ` ` ` ` `       •  
     ` ` ` ` ` ∩ • • • • • • • • • • • • • • •   ` ` ` ` ` ` ` ` ` ` ` Π ` ` 1 1 ` Π •   •  
     ` ` ` ` `                               •   ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •   •  
     ` ` ` ` `           • Φ ` ` ` ` ` ` `   • ⁑ ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •   •  
     ∩                   •   ` ` ` ` ` ` `       ` ` ` ` ` 5 ` ` ` ` `   ` ` ` ` `   •   •  
     •                   •   ` ` ` 1 3 ` `       ` ` ` ` ` ` ` ` ` ` `   ` ` ` ` `   •   •  
     •                   •   ` ` ` ` ` ` `       ` ` ` ` ` ` ` ` ` ` `   ⁑           •   •  
     • • • • • • • • • • •   ` ` ` ` ` ` `       ` ` ` ` ` ` ` ` ` ` `   • • • • • • • • •  
                                                                                            
    ┌─── LEGEND ──────────────────────────────┐
    │ 1+ room nr.   ∩  arch     ⁑  secret     │
    │ `  room       Π  door     ‼  trapped    │
    │ •  corridor   Φ  locked   ‡  portcullis │
    └─────────────────────────────────────────┘

In this map we can see the rooms, the corridors, the room numbers and several types of doors.

Rooms are also retrievable from a dungeon instance by checking the `roomInfo` dictionary that contains room numbers and related room data (coordinate and size of the room). From the above example room 12 could start at `Coordinate(1, 4)` and have a width of 5 and height of 11.