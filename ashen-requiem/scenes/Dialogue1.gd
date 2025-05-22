extends CanvasLayer

@export var dialogues: Array[String] = [
	"You wake with a sharp inhale.",
	"The air tastes cold and stale as it scrapes down your throat. Your heart thuds weakly, before settling into a slow, steady rhythm.",
	"For a moment, you wonder if you had been dreaming.",
	"There's only a lingering sensation, impossible to shake. The feeling of being held down.",
	"By something heavy. Old. Unseen.",
	"You push the thought away as you sit up, muscles stiff and reluctant.",
	"Nothing around you offers answers. You can't recall how you got here, or even where here is.",
	"You try to remember your name but to no avail.",
	"A voice calls from the dark. Wordless, yet you hear it.",
	'???: "Find what was lost. Or remain nothing."',
	"You don’t know what they mean. But you know you can’t stay here.",
	"You rise. There is nothing else to do..."
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
			await get_tree().process_frame  # Wait for unpause
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
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
