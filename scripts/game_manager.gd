extends Node2D

var cursor_scene = preload("res://scenes/cursor.tscn")

@export var camera: Camera2D
@export var player: Player

func _ready() -> void:
    var cursor = cursor_scene.instantiate()
    add_child(cursor)
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _process(delta: float) -> void:
    var target = (player.position + get_global_mouse_position()) / 2

    # var offset = Vector2(250, 150)
    # target = clamp(target, player.position - offset, player.position + offset)
    target.x = clamp(target.x, player.position.x - 150, player.position.x + 150)
    target.y = clamp(target.y, player.position.y - 75, player.position.y + 75)

    camera.position = lerp(camera.position, target, .05)

    if Input.is_action_just_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
