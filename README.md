# Beatbreak
 A customizable rhythm game template that lets users create and program their own charts.
# Creating Scenes
Using the preset Track class, you're able to load in tracks from your chart into the game and give your notes custom properties. The code already in the Track should be enough for basic rhythm game mechanics, but it can be overwritten if need be. An example chart and scene can be found in the examples/ folder.
# Exporting and Sharing Charts
Upon running the game, the engine creates two folders- user://charts, and user://packages. Any charts in user://charts will be automatically loaded as the game starts, and any packages in user://packages will be loaded into the local filesystem, as well. To distribute your chart, all you need to do is copy your chart file and export your new scenes as a package, then send those to whoever you want to send them to.