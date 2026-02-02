extends CharacterBody2D

var player: Player

func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
    var target = get_global_mouse_position()

    var direction = position.direction_to(target)
    var diff = position.distance_to(target)

    var diff_to_player = position.distance_to(player.position)
    var speed = (diff * 5) + diff_to_player + 100
    velocity = lerp(velocity, direction * speed, .1)
    # velocity = direction * 1000

    move_and_slide()
