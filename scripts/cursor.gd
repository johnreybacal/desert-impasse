extends CharacterBody2D

var player: Player

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    var target = get_global_mouse_position()

    var direction = position.direction_to(target)
    var diff = position.distance_to(target)

    var diff_to_player = position.distance_to(player.position)
    var speed = (diff * 10) + diff_to_player - 50

    var slow_diff = 50

    if diff_to_player < 75 and diff < 25:
        speed /= 2
    elif diff < slow_diff:
        speed /= 1.5
    velocity = velocity.move_toward(direction * speed, delta * 500)
    # velocity = direction * 1000

    move_and_slide()
