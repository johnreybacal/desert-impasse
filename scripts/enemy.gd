extends CharacterBody2D
class_name Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var move_speed = 66
@onready var ray_cast: RayCast2D = $VisionRayCast
@onready var alerted_sprite: Sprite2D = $AlertedSprite
@onready var character: Character = $Character

var target: Node2D
var target_positioning_interval: float = .5
var target_in_sight: bool
var move_delta: float

var knocked_back_interval: float = -1

func _ready() -> void:
    target = get_tree().get_first_node_in_group("player")
    navigation_agent.path_desired_distance = 4.0
    navigation_agent.target_desired_distance = 4.0

    actor_setup.call_deferred()

    alerted_sprite.visible = false

    character.knocked_back.connect(on_knocked_back)

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target
    

func _physics_process(delta: float) -> void:
    target_in_sight = false
    move_delta = move_speed * delta

    
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
            target_positioning_interval = .5

    if knocked_back_interval >= 0:
        knocked_back_interval -= delta

    handle_animation()

    # Navigation finished
    if navigation_agent.is_navigation_finished():
        return

    # https://docs.godotengine.org/en/4.5/tutorials/navigation/navigation_using_navigationagents.html#navigationagent-avoidance
    var next_path_position: Vector2 = navigation_agent.get_next_path_position()
    var new_velocity: Vector2 = global_position.direction_to(next_path_position) * move_speed
    if navigation_agent.avoidance_enabled:
        navigation_agent.set_velocity(new_velocity)
    else:
        _on_navigation_agent_2d_velocity_computed(new_velocity)


    # velocity = global_position.direction_to(next_path_position) * move_speed

    # move_and_slide()

func handle_animation():
    animated_sprite_2d.play("worm")
    if target_in_sight:
        animated_sprite_2d.flip_h = global_position.x > target.global_position.x

    alerted_sprite.visible = target_in_sight


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
    if knocked_back_interval >= 0:
        return
    global_position = global_position.move_toward(global_position + safe_velocity, move_delta)

    # velocity = safe_velocity
    # move_and_slide()

func on_knocked_back(k: Vector2):
    knocked_back_interval = .1
    move_and_collide(k)
