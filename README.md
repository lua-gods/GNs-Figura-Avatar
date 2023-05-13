# GN's Figura Avatar
this is the main avatar I (GNamimates) use for the mod [Figura](https://modrinth.com/mod/figura).
this avatar is full of scripts n things, yet it runs really fast compared to other avatars (the grid core is taking so much instructions, removing it will drastically improve instructions count)


##### Avatar is under the Apache License 2.0 Lisence
# Table of Contents
🥶 Documented
😡 Undocumented

✅ Usable
❌ Unusable

🏆 Feature Complete
⚠️ W.I.P
☣️ Heavily W.I.P

## Libraries
A collection of reusable, compiled, and tested code that can facilitate the automation or augmentation of application functionalities.
| Library        | State | Author              | Description                                                                                                  |
| -------------- | ----- | ------------------- | ------------------------------------------------------------------------------------------------------------ |
| GNanim         | 😡✅⚠️   | GNamimates          | A state machine library made specifically for animations                                                     |
| GNUILib        | 😡❌⚠️   | GNamimates          | Handles all the UI element arrangement and instancing                                                        |                                         |
| Panel          | 😡❌☣️   | GNamimates          | A quick popup panel that appears at the bottom right corner of the screen, can be accessed by pressing [ ` ] |
| WorldAffectLib | 🥶✅🏆   | GNamimates          | A Library that handles watching specific blocks in the world                                                 |
| ClothesLib     | 😡✅🏆   | GNamimates          | A state machine library that handles cosmetic and scripts                                                    |
| TimerAPI       | 🥶✅🏆   | KitCat & GNamiamtes | A library about making timers, count down clocks                                                             |
| KattEventsAPI  | 🥶✅🏆   | KitCat              | A library that allows the creation of custom events                                                          |



## Services
A bunch of scripts that get called on initialization
| Service            | Description                                   |
| ------------------ | --------------------------------------------- |
| Grid API           | the interface from controlling the grid floor |
| Grid Core          | the core of the grid                          |
| Main               | the main place for little code snippets       |
| Panel Handler      | the page Library layout manager               |
| Trust              | Caches booleans into constants                |
| Wardrobe Initiator | the one that handles all the clothing         |

## 📜 Init queue
This keeps the avatar from using too much instruction upon initialization.
this was demaked because of technical issues.

## 📁 Wardrobes
Contains the individual types of clothing the avatar uses.

## 📁 Weapons
Contains cosmetic weapons which can be toggled with the wardrobe.

## 📁 libraries.panel_elements
Contains modules for the panel.

## 📁 Modes
Converts strings into instructions on how to draw the text

## 📜 Text 2 Texture
Converts strings into instructions on how to draw the text.