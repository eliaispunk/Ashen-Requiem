extends CanvasLayer

@export var dialogues: Array[String] = [
	"This is your first line of dialogue.",
	"The storm grows heavier in the distance.",
	"You must continue onward..."
]

var current_index: int = 0
var char_index: int = 0
var typing_speed: float = 0.02
var is_typing: bool = false
var typing_coroutine_running: bool = false
var current_text: String = ""

@onready var dialogue_label = $DialogueBox/DialogueText
@onready var fader: ColorRect = $Fader

func _ready():
	await get_tree().process_frame
	if fader:
		fader.modulate.a = 1.0
		call_deferred("start_cutscene")

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			# Fast complete
			dialogue_label.text = current_text
			is_typing = false
		else:
			show_next_dialogue()

func show_next_dialogue():
	if current_index < dialogues.size():
		current_text = dialogues[current_index]
		current_index += 1
		char_index = 0
		is_typing = true
		start_typing()
	else:
		end_cutscene()

func start_typing():
	if typing_coroutine_running:
		return
	typing_coroutine_running = true
	dialogue_label.text = ""
	call_deferred("_typing_coroutine")

func _typing_coroutine():
	while char_index < current_text.length():
		dialogue_label.text += current_text[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	is_typing = false
	typing_coroutine_running = false

func start_cutscene():
	if fader:
		await fader.fade_out()
	await get_tree().create_timer(0.2).timeout
	show_next_dialogue()

func end_cutscene():
	if fader:
		await fader.fade_in()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
