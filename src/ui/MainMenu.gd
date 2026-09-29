class_name MainMenu
extends Control

@onready var menu_container: Control = $MenuContainer

@onready var btn_vs: Button = $MenuContainer/BtnVS
@onready var btn_training: Button = $MenuContainer/BtnTraining
@onready var btn_settings: Button = $MenuContainer/BtnSettings
@onready var btn_exit: Button = $MenuContainer/BtnExit

@onready var settings_modal: Panel = $SettingsModal
@onready var btn_close_settings: Button = $SettingsModal/BtnCloseSettings
@onready var fullscreen_check: CheckBox = $SettingsModal/VBox/FullscreenCheck


const NORMAL_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.05, 1.05)
const ANIMATION_DURATION := 0.3


func _ready() -> void:
    btn_vs.pressed.connect(_on_vs_pressed)
    btn_training.pressed.connect(_on_training_pressed)
    btn_settings.pressed.connect(_on_settings_pressed)
    btn_exit.pressed.connect(_on_exit_pressed)

    setup_button_effect(btn_vs)
    setup_button_effect(btn_training)
    setup_button_effect(btn_settings)
    setup_button_effect(btn_exit)

    if btn_close_settings:
        btn_close_settings.pressed.connect(_on_close_settings)

    if fullscreen_check:
        fullscreen_check.toggled.connect(_on_fullscreen_toggled)
        fullscreen_check.button_pressed = (
            DisplayServer.window_get_mode()
            == DisplayServer.WINDOW_MODE_FULLSCREEN
        )

    settings_modal.visible = false
    btn_vs.grab_focus()


# ====================================
# SETUP EFEK TOMBOL
# ====================================

func setup_button_effect(button: Button) -> void:
    button.pivot_offset = button.size / 2.0

    var empty_style := StyleBoxEmpty.new()
    button.add_theme_stylebox_override("normal", empty_style)
    button.add_theme_stylebox_override("hover", empty_style)
    button.add_theme_stylebox_override("pressed", empty_style)
    button.add_theme_stylebox_override("focus", empty_style)

    button.focus_entered.connect(
        func():
            _on_button_focus_entered(button)
    )

    button.focus_exited.connect(
        func():
            _on_button_focus_exited(button)
    )

    button.mouse_entered.connect(
        func():
            if not button.has_focus():
                animate_button(button, true)
    )

    button.mouse_exited.connect(
        func():
            if not button.has_focus():
                animate_button(button, false)
    )


# ====================================
# ANIMASI FOKUS KEYBOARD
# ====================================

func _on_button_focus_entered(button: Button) -> void:
    stop_button_tween(button)

    button.z_index = 1

    var tween := create_tween()
    button.set_meta("current_tween", tween)

    tween.set_loops()

    tween.tween_property(
        button,
        "scale",
        HOVER_SCALE,
        ANIMATION_DURATION
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    tween.tween_property(
        button,
        "scale",
        NORMAL_SCALE,
        ANIMATION_DURATION
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_button_focus_exited(button: Button) -> void:
    stop_button_tween(button)

    button.scale = NORMAL_SCALE
    button.z_index = 0

    if button.get_global_rect().has_point(
        get_global_mouse_position()
    ):
        animate_button(button, true)


# ====================================
# ANIMASI HOVER MOUSE
# ====================================

func animate_button(button: Button, is_active: bool) -> void:
    stop_button_tween(button)

    var target_scale := HOVER_SCALE if is_active else NORMAL_SCALE

    var tween := create_tween()
    button.set_meta("current_tween", tween)

    tween.tween_property(
        button,
        "scale",
        target_scale,
        0.15
    ).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

    button.z_index = 1 if is_active else 0


# ====================================
# HENTIKAN ANIMASI
# ====================================

func stop_button_tween(button: Button) -> void:
    if button.has_meta("current_tween"):
        var old_tween = button.get_meta("current_tween")

        if old_tween and old_tween.is_running():
            old_tween.kill()


# ====================================
# TOMBOL MENU
# ====================================

func _on_vs_pressed() -> void:
    GameManager.game_mode = "pvp"
    GameManager.go_to_character_select()


func _on_training_pressed() -> void:
    GameManager.start_training()


func _on_settings_pressed() -> void:
    menu_container.hide()
    settings_modal.show()

    if btn_close_settings:
        btn_close_settings.grab_focus()


func _on_close_settings() -> void:
    settings_modal.hide()
    menu_container.show()
    btn_settings.grab_focus()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
    if button_pressed:
        DisplayServer.window_set_mode(
            DisplayServer.WINDOW_MODE_FULLSCREEN
        )
    else:
        DisplayServer.window_set_mode(
            DisplayServer.WINDOW_MODE_WINDOWED
        )


func _on_exit_pressed() -> void:
    get_tree().quit()