extends Control

var maxScrollLength = 0

@onready var scrollContainer: ScrollContainer = %ScrollContainer
@onready var scrollbar: ScrollBar = scrollContainer.get_v_scroll_bar()
@onready var vbox: VBoxContainer = %VBoxContainer
@onready var creditsFile = "res://Assets/Credits.txt"
@onready var creditsMain = %Credits
@onready var mainMenu = $"../mainMenu"

func _ready():
	for line in load_from_file():
		var creditLabel = Label.new()
		creditLabel.text = str(line)
		creditLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		creditLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(creditLabel)
	scrollbar.changed.connect(handleScrollbarChanged)
	maxScrollLength = scrollbar.max_value


func _input(event):
	if event is InputEventKey:
		if event.pressed and creditsMain.visible == true:
			creditsMain.visible = false
			mainMenu.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	scrollContainer.scroll_vertical


func handleScrollbarChanged():
	if maxScrollLength != scrollbar.max_value:
		maxScrollLength = scrollbar.max_value
		scrollContainer.scroll_vertical = maxScrollLength


func load_from_file():
	var file = FileAccess.open("res://Assets/Credits.txt", FileAccess.READ)
	var content: Array = []
	while not file.eof_reached():
		content.append(file.get_line())
	return content
