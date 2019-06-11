#  DungeonBuilder

A 2D dungeon maze builder written in Swift.

The code is based on the Perl and JavaScript versions written by [Donjon](https://donjon.bin.sh). The Perl and JavaScript versions can be found in the [Donjon directory](https://github.com/wolf81/DungeonBuilder/tree/master/Donjon) for reference.

**_PLEASE NOTE: The code is ugly. I didn't try to create a proper conversion to Swift of the JavaScript / Perl code. Instead I just went with a pretty much one-on-one copy of the JavaScript / Perl code as written bij Donjon. The reason being I just wanted to have a quick and dirty dungeon generator for a game I am working on._**

## Features

- Dungeons of various sizes, from fine to collosal
- Rooms of various sizes, from small to collosal
- Rooms can be densely packed or scattered
- Corridors can be straight, curved or in between
- Optionally remove some or all dead-ends
- Dungeons can be created using various layouts, e.g. keep or hexagon
- Different types of doors are placed, e.g.: normal, trapped, locked, etc...
- Optionally use your own (random) number generator

## Usage

1. Add this project as a library to some other project.
2. Create an instance of `DungeonBuilder` and provide it with a `Configuration` and optionally your own number generator that conforms to `NumberGeneratable`.
3. Call the `build` method on your instance of `DungeonBuilder` to create a dungeon. A `Dungeon` will be returned.

By default a build-in seeded random number generator is used. This build-in random number generator is seeded with the name of the dungeon. This means that everytime the same name is used to build a dungeon, the same dungeon is re-created as long as the same `Configuration` is re-used as well.   

The `Dungeon` contains a 2-dimensional array of nodes. Each `Node` is an `OptionSet`. Use the various flags to see what the node represents.  E.g.: 

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