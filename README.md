![Beatbreak logo](https://raw.githubusercontent.com/cyber-dile/Beatbreak/main/assets/game/beatbreakLogoBig.png)
<p align="center"> ![](https://img.shields.io/github/v/release/cyber-dile/Beatbreak?style=flat-square) ![](https://img.shields.io/github/downloads/cyber-dile/Beatbreak/total?style=flat-square) ![](https://img.shields.io/github/license/cyber-dile/Beatbreak?style=flat-square) </p>
---
## Beatbreak
**Beatbreak is a rhythm game with a focus on user-generated content.** Charts can be made in Beatbreak's in-game editor, or exported from .sm files, where they can then be linked to Godot packages that are loaded in from a folder on the player's computer. It provides the framework for any kind of rhythm game, that can then be utilized by developers to create unique maps that otherwise wouldn't be possible in other frameworks, due to its control style or game limitations.

## Charting
By default, when you create and save a song's chart, it's saved in `user://charts/[CHARTID].json`. The amount of layers and notes in a song's different charts can differ, but things that are always constant throughout all of the difficulties are the scene used, the song's user-defined settings, and the song/BPM. When a new .json is loaded into the folder, the charts will automatically be loaded into the game, regardless if there's an existing package the chart is linked to or not- however, if there isn't a valid scene or song for the song to be played in, the song will not be able to be played.

## Scene Development
There are several various examples for charts and chart scenes in the `example/` folder within this repository. They all reference predefined utilities in `res://source/charts` to automate the process of loading charts into the game, and detecting player input. While these are there for you to use, they are by no means definite- alternate means of loading notes or handling inputs can always be defined by extending existing scripts, or creating new scripts entirely.

From within a scene, you have complete freedom over what happens in the game- you can do anything that's possible in normal Godot. There are some factors that must be fulfilled outside of the scene, however- the scene must be able to pause when it's paused, it should update the scorebanks within `Stage.tscn`, and it must either be able to play its own preview, or you must disable the preview's visibility in its entirety.

## Exporting
When a chart's scene is ready to be exported, all you have to do is export a .pkg file of the scene with the files affected, which can then be put in the `user://packages/` folder for anyone recieving it. The package file doesn't have to be just limited to the scene of the chart- it can also be alterations towards the rest of the game, such as a menu or editor re-programming. Any package in the folder will be loaded, regardless of whatever scripts it may replace.