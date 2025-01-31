extends PanelContainer

@onready var property_container = $MarginContainer/VBoxContainer


func _ready():
	Global.debug = self

func _process(delta):
	pass

func addDebugProperty(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	else:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
