extends Node2D

var cross_hair_scene = preload("res://scenes/cross_hair.tscn")
var cross_hair: CrossHair
@export var camera: Camera2D
@export var player: Player

@onready var cursor_sprite: Sprite2D = $CursorSprite

var camera_min_zoom = 3
var camera_max_zoom = 4

func _ready() -> void:
    cross_hair = cross_hair_scene.instantiate()
    cross_hair.camera = camera
    add_child(cross_hair)
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _process(_delta: float) -> void:
    cursor_sprite.global_position = get_global_mouse_position()
    handle_camera()

    if Input.is_action_just_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if Input.is_action_just_pressed("trigger"):
        Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
    if Input.is_action_just_pressed("move"):
        player.set_movement_target(get_global_mouse_position())

    
func handle_camera():
    var player_position = player.position
    var cursor_position = get_global_mouse_position()
    var target = (player_position + cursor_position) / 2
    
    var offset = Vector2(150, 75)
    # target = clamp(target, player.position - offset, player.position + offset)
    target.x = clamp(target.x, player.position.x - offset.x, player.position.x + offset.x)
    target.y = clamp(target.y, player.position.y - offset.y, player.position.y + offset.y)
    
    camera.position = lerp(camera.position, target, .05)

    var distance = clamp(player_position.distance_to(cursor_position), 100, 175)
    var zoom_offset = 1 - ((distance - 100) / 75)
    var target_zoom = clamp(camera_min_zoom + zoom_offset, camera_min_zoom, camera_max_zoom)
    camera.zoom = lerp(camera.zoom, Vector2(target_zoom, target_zoom), .01)