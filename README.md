# GN's Figura Avatar
this is the main avatar I (GNamimates) use for the mod [Figura](https://modrinth.com/mod/figura).
this avatar is full of scripts n things, yet it runs really fast compared to other avatars (the grid core is taking so much instructions, removing it will drastically improve instructions count)

# Table of Contents
🥶 Documented
😡 Undocumented

✅ Usable
❌ Unusable

🏆 Feature Complete
⚠️ W.I.P
☣️ Heavily W.I.P
## Libraries

| Library        | State | Owner               |
| -------------- | ----- | ------------------- |
| GNanim         | 😡✅⚠️   | GNamimates          |
| GNUILib        | 😡✅⚠️   | GNamimates          |
| GNUIUtil       | 😡✅⚠️   | GNamimates          |
| Panel          | 😡❌☣️   | GNamimates          |
| WorldAffectLib | 😡✅🏆   | GNamimates          |
| ClothesLib     | 😡✅🏆   | GNamimates          |
| TimerAPI       | 🥶✅🏆   | KitCat & GNamiamtes |
| KattEventsAPI  | 🥶✅🏆   | KitCat              |



## Services
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

## 📁 Modes
Converts strings into instructions on how to draw the text

## 📜 Text 2 Texture
Converts strings into instructions on how to draw the text.
