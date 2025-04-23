extends Control

@export var dialogue_lines : Array[String] = [
	"There was fire.",
	"Then silence.",
	"They say the world ended long ago...",
	"...but you're still here.",
	"And something still remembers you.",
	"Wake up."
]

var current_index := 0
@onready var label = $Label

func _ready():
	show_next_line()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or event is InputEventMouseButton:
		show_next_line()

func show_next_line():
	if current_index < dialogue_lines.size():
		label.text = dialogue_lines[current_index]
		current_index += 1
	else:
		queue_free() # or emit a signal to start the game
