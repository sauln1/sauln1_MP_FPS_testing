extends PanelContainer

@onready var portEntry = $VBoxContainer/PortEntry
@onready var startButton = $VBoxContainer/Start
@onready var cancelButton = $VBoxContainer/Cancel
@onready var Menu = $".."
@onready var mainMenu = $"../mainMenu"
@onready var mapSelect = $VBoxContainer/MapSelect

var playerIP
var selectedMap

func _ready() -> void:
	# Can check for headless or dedicated server here
	# Later, make this a dictionary with a key(readable name) and value (map path)
	#	that populates an item per map available for play.


	for key in Global.mapsDict:
		# Populate dropdown list
		mapSelect.add_item(str(key))
	
	playerIP = str(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))


func _on_start_pressed() -> void:
	# FOR DEBUG - REMOVE
	playerIP = "127.0.0.1"
	var playerPort = int(portEntry.text)
	selectedMap = str(mapSelect.get_item_text(mapSelect.get_item_id(mapSelect.selected)))

	for key in Global.mapsDict:
		if str(key) == selectedMap:
			var mkey = key
			var mvalue = Global.mapsDict[key]
			print(str([mkey,mvalue]))
			Global.ClientMain.becomeHost(playerIP,playerPort,[mkey,mvalue])


func _on_cancel_pressed() -> void:
	self.hide()
	mainMenu.show()
