extends Control

@onready var volume_slider: HSlider = $VBox/VolumeRow/Slider
@onready var fullscreen_check: CheckButton = $VBox/FullscreenRow/Check

func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)

func _on_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(max(v, 0.0001)))

func _on_fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED
	)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
