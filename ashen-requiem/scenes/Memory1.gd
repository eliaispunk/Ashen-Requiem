extends CanvasLayer

@export var dialogues: Array[String] = [
	"You feel the world fade around you. Silence presses in...",
	"A memory surfaces in the back of your mind.",
	"You stand before a grand throne, draped in banners of gold and crimson...",
	"You hear voices. They’re soft and distant. They chant a name.",
	"There is blood on the floor. You somehow know it's fresh but not yours.",
	"You take a step towards the throne. But something holds you back.",
	"Then you hear a whisper. A voice not your own.",
	'???: "You chose this path. Don’t turn away now."',
	"You try to remember who said it. A friend? A foe?",
	"But the memory fades and the darkness returns.",
	"...",
	"........",
	"Thank you for playing the demo for Ashen Requiem."
]

var current_index := 0
var char_index := 0
var typing_speed := 0.02
var is_typing := false
var typing_coroutine_running := false
var current_text := ""
var is_paused := false

@onready var dialogue_label = $DialogueBox/DialogueText
@onready var continue_prompt = $DialogueBox/ContinuePrompt
@onready var anim_player: AnimationPlayer = $DialogueBox/AnimationPlayer
@onready var fader: ColorRect = $Fader
@onready var typing_sfx: AudioStreamPlayer = $TypingSFX
@onready var ui = $UI

func _ready():
	await get_tree().process_frame
	if fader:
		fader.modulate.a = 1.0
		fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$DialogueBox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	continue_prompt.visible = false
	ui.pause_toggled.connect(_on_pause_toggled)
	call_deferred("start_cutscene")

func _on_pause_toggled(paused: bool):
	is_paused = paused
	if not is_paused and is_typing and not typing_coroutine_running:
		start_typing()

func _unhandled_input(event):
	if is_paused:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			# Stop coroutine *cleanly*
			is_typing = false
			typing_coroutine_running = false
			char_index = current_text.length()  # Skip to end
			dialogue_label.text = current_text
			if typing_sfx.playing:
				typing_sfx.stop()
			continue_prompt.visible = true
			anim_player.play("BlinkArrow")
		else:
			show_next_dialogue()

func show_next_dialogue():
	continue_prompt.visible = false
	anim_player.stop()
	if current_index < dialogues.size():
		current_text = dialogues[current_index]
		current_index += 1
		char_index = 0
		is_typing = true
		start_typing()
	else:
		end_cutscene()

func start_typing():
	if typing_coroutine_running or not is_typing:
		return
	typing_coroutine_running = true
	dialogue_label.text = ""

	if not typing_sfx.playing:
		typing_sfx.play()

	await _typing_coroutine()

func _typing_coroutine():
	while char_index < current_text.length():
		if is_paused:
			await get_tree().create_timer(0).timeout
			continue

		dialogue_label.text += current_text[char_index]
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout

	typing_coroutine_running = false
	is_typing = false
	if typing_sfx.playing:
		typing_sfx.stop()

	continue_prompt.visible = true
	anim_player.play("BlinkArrow")

func start_cutscene():
	if fader:
		await fader.fade_out()
	await get_tree().create_timer(0.2).timeout
	show_next_dialogue()

func end_cutscene():
	if fader:
		await fader.fade_in()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
