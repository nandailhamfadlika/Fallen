extends Node2D

@onready var aron: Aron = $Aron
@onready var cooldown_label: Label = $CanvasLayer/Panel/Margin/VBox/DashCooldownLabel

func _ready() -> void:
	if aron:
		aron.player_id = 1
		aron.set_device("keyboard_wasd", -1)

func _process(_delta: float) -> void:
	if aron and cooldown_label:
		if aron.dash_cooldown_timer > 0.0:
			cooldown_label.text = "Dash Cooldown: %.1fs (WAIT)" % aron.dash_cooldown_timer
			cooldown_label.modulate = Color(1.0, 0.4, 0.4)
		else:
			cooldown_label.text = "Dash Status: READY (Shift + A/D)"
			cooldown_label.modulate = Color(0.4, 1.0, 0.4)
