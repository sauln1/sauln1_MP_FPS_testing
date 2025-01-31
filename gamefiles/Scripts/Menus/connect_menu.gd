extends PanelContainer

@onready var Main = $".."
@onready var mainMenu = %mainMenu
@onready var hostIP = $VBoxContainer/IPEntry
@onready var hostPort = $VBoxContainer/IPPortEntry
var connectionIP := '127.0.0.1'
var connectionPort := 8080


func _on_start_pressed() -> void:
	if hostIP.text != '':
		connectionIP = hostIP.text

	if hostPort.text != '':
		connectionPort = int(hostPort.text)

	Global.ClientMain.joinServer(connectionIP,connectionPort)


func _on_cancel_pressed() -> void:
	self.hide()
	mainMenu.show()
