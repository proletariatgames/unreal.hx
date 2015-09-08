# UE4 externs

The current Haxe build pipeline will generate the wrapper Haxe classes and glue code
from the raw extern definitions contained within `/Haxe/Externs` (plugin and game) directories.
Do NOT add these directories to your direct classpath - as these externs need to be processed first.
