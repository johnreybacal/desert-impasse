extends Node2D

var cursor_scene = preload("res://scenes/cursor.tscn")

@export var camera: Camera2D
@export var player: Player

var camera_min_zoom = 3
var camera_max_zoom = 4

func _ready() -> void:
    var cursor = cursor_scene.instantiate()
    add_child(cursor)
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _process(_delta: float) -> void:
    handle_camera()
    

func handle_camera():
    var player_position = player.position
    var mouse_position = get_global_mouse_position()
    var target = (player_position + mouse_position) / 2
    var distance = clamp(player_position.distance_to(mouse_position), 100, 175)
    var zoom_offset = 1 - ((distance - 100) / 75)
    var target_zoom = clamp(camera_min_zoom + zoom_offset, camera_min_zoom, camera_max_zoom)
    
    var offset = Vector2(150, 75)
    # target = clamp(target, player.position - offset, player.position + offset)
    target.x = clamp(target.x, player.position.x - offset.x, player.position.x + offset.x)
    target.y = clamp(target.y, player.position.y - offset.y, player.position.y + offset.y)
    
    camera.zoom = lerp(camera.zoom, Vector2(target_zoom, target_zoom), .05)
    camera.position = lerp(camera.position, target, .05)

    if Input.is_action_just_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)