extends Control

@onready var credits = %Credits
@onready var mainMenu = $mainMenu
@onready var HostMenu = %HostMenu
@onready var JoinMenu = %ConnectMenu
@onready var Credits = %Credits


func _on_host_game_pressed() -> void:
	mainMenu.hide()
	HostMenu.show()
	print("MESSAGE | Open Host Menu")
	

func _on_join_game_pressed() -> void:
	mainMenu.hide()
	JoinMenu.show()
	print("MESSAGE | Open Join Menu")


func _on_credits_pressed() -> void:
	mainMenu.hide()
	credits.show()
	print("MESSAGE | Open Credits")


func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
