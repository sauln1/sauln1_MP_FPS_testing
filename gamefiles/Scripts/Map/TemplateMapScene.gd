extends Node

var playerSpawnNode
var PlayerCharacter = preload("res://Scenes/Player/PlayerCharacterScene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	# Multiplayer
	playerSpawnNode = $PlayerSpawner

	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(addPlayer)
	multiplayer.peer_disconnected.connect(removePlayer)

	# Spawns any players already in scene (i.e. level change)
	for id in multiplayer.get_peers():
		print(id)
		Global.ClientMain.addPlayer(id)

	# Spawns player if not a dedicated server
	if not OS.has_feature("dedicated_server"):
		addPlayer(1)

	print("MESSAGE | Level3 Temp Map Ready.")


func addPlayer(netID: int):
	# Represents every new player that joins the game
	var playerToAdd = PlayerCharacter.instantiate()
	playerToAdd.player_id = netID
	playerToAdd.name = str(netID)
	playerSpawnNode.add_child(playerToAdd,true)

	print("MESSAGE | Player joined server: PlayerID " + str(netID))

func removePlayer(netID: int):
	if not playerSpawnNode.has_node(str(netID)):
		return

	playerSpawnNode.get_node(str(netID)).queue_free()

	print("MESSAGE | Player left server: PlayerID " + str(netID))

func _exit_tree():
	# Kill multiplayer callbacks on map exit
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(addPlayer)
	multiplayer.peer_disconnected.disconnect(removePlayer)
	print("MESSAGE | Map tree ended for Level3 Temp Map")
