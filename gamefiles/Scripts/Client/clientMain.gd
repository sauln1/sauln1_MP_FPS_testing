extends Node

@onready var MapSpawner := %MapSpawner

func _ready():
	Global.ClientMain = self


func becomeHost(serverIP: String,serverPort: int,serverMap):
	# Get the node that relates to the array passed to becomeHost
	for key in Global.mapsDict:
		if key == serverMap[0]:
			if multiplayer.is_server():
				change_level.call_deferred(load(serverMap[1]))

	# Set element for the MapSpawner to spawn
	MapSpawner.add_spawnable_scene(str(serverMap[1]))

	# Multiplayer settings
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(serverPort)

	multiplayer.multiplayer_peer = server_peer

	start_game()

	print("MESSAGE | becomeHost at - "+serverIP+":"+str(serverPort))


func joinServer(hostIP: String,hostPort: int):
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(hostIP,hostPort)

	multiplayer.multiplayer_peer = client_peer

	start_game()

	print("MESSAGE | joinServer at - "+hostIP+":"+str(hostPort) + str(multiplayer.get_unique_id()))


func start_game():
	$MainMenu.hide()


func change_level(scene: PackedScene):
	var map = %Map
	if map.get_child_count() > 0:
		for child in %Map.get_children():
			%Map.remove_child(child)
			child.queue_free()
		%Map.add_child(scene.instantiate())
	else:
		%Map.add_child(scene.instantiate())
	print("MESSAGE | change_level to " + str(self.get_node("Map").get_children()))
