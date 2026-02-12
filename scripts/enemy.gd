extends CharacterBody2D
class_name Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var move_speed = 50
@onready var ray_cast: RayCast2D = $VisionRayCast
@onready var alerted_sprite: Sprite2D = $AlertedSprite

var target: Node2D
var target_positioning_interval: float = .5
var target_in_sight: bool

func _ready() -> void:
    target = get_tree().get_first_node_in_group("player")
    navigation_agent.path_desired_distance = 4.0
    navigation_agent.target_desired_distance = 4.0

    actor_setup.call_deferred()

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target
    

func _physics_process(delta: float) -> void:
    target_in_sight = false

    # Point raycast to player
    if target:
        var direction = global_position.direction_to(target.global_position)
        ray_cast.target_position = direction * 200

    # Check if raycast sees player
    if ray_cast.is_colliding():
        var collider = ray_cast.get_collider()
        if collider is Character:
            if collider.faction == Character.Faction.Player:
                if not target_in_sight:
                    target_positioning_interval = 0
                target_in_sight = true
                
    # Set movement towards player
    if target_in_sight:
        target_positioning_interval -= delta
        if target_positioning_interval <= 0:
            set_movement_target(target.global_position)
            target_positioning_interval = .25

    # Navigation finished
    if navigation_agent.is_navigation_finished():
        return

    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = global_position.direction_to(next_path_position) * move_speed

    handle_animation()

    move_and_slide()

func handle_animation():
    animated_sprite_2d.play("worm")
    if target:
        animated_sprite_2d.flip_h = position.x > target.position.x

    alerted_sprite.visible = target_in_sight
