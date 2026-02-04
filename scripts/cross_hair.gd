extends CharacterBody2D
class_name CrossHair

var player: Player
var camera: Camera2D

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    var target := get_global_mouse_position()

    var direction := position.direction_to(target)
    var diff := position.distance_to(target)

    var diff_to_player := position.distance_to(player.position)
    var speed := clampf((diff * 15) + diff_to_player - 50, 0, 1000)

    var slow_diff := 50

    if diff_to_player < 75 and diff < 25:
        speed /= 2
    elif diff < slow_diff:
        speed = (diff * 10) + (diff / slow_diff)

    velocity = velocity.move_toward(direction * speed, delta * 500)

    move_and_slide()
    limit_movement()

func limit_movement():
    # https://forum.godotengine.org/t/how-to-prevent-player-from-going-out-of-camera/11279/2?u=johnreybacal
    var view = get_viewport_rect().size / 2
    view /= camera.zoom

    var cam_pos := camera.global_position
    
    var min_x = cam_pos.x - view.x + 8
    var max_x = cam_pos.x + view.x - 8
    var min_y = cam_pos.y - view.y + 8
    var max_y = cam_pos.y + view.y - 8

    global_position.x = clampf(global_position.x, min_x, max_x)
    global_position.y = clampf(global_position.y, min_y, max_y)