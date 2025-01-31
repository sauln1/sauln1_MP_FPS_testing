extends Node

var debug
var player

enum player_states
{
	IDLE, WALK, RUN, CROUCH, SLIDE, JUMP, INAIR, ONWALL, CLAMBER, FALLING, DASH, DEAD
}
# List of all available maps
var mapsDict = {
	"Level3":"res://Scenes/TestArena/TemplateMapScene.tscn"
}

# Link to ClientMain
var ClientMain
