extends RigidBody2D
class_name Bullet

var bullet_speed = 500
var direction: Vector2
var distance_travelled: float
var max_distance: float
var initial_position: Vector2

var impact_particle_scene := preload("res://scenes/bullet_impact_particle.tscn")
var bullet_impact_scene := preload("res://scenes/bullet_impact.tscn")

var faction: Character.Faction

func _ready() -> void:
    initial_position = position

    # 1 world
    # 2 player
    # 3 crosshair
    # 4 enemy
    if faction == Character.Faction.Player:
        # 1001
        collision_mask = 9
    if faction == Character.Faction.Enemy:
        # 1100
        collision_mask = 3

func _process(delta: float) -> void:
    var velocity = direction * bullet_speed * delta
    
    var collision := move_and_collide(velocity)
    
    if collision:
        var collider := collision.get_collider()
        print(collider)
        if collider is Character:
            print(collider.faction)
            if collider.faction != faction:
                collider.take_damage(1)
                hit_effect(velocity.angle(), true)
        else:
            hit_effect(velocity.angle())

    distance_travelled = position.distance_to(initial_position)

    if distance_travelled >= max_distance:
        hit_effect()


func hit_effect(p_angle = null, is_character: bool = false):
    var particle: GPUParticles2D = impact_particle_scene.instantiate()
    get_parent().add_child(particle)

    if is_character:
        particle.modulate = Color.ORANGE_RED
    else:
        var bullet_impact: Sprite2D = bullet_impact_scene.instantiate()
        get_parent().add_child(bullet_impact)
        bullet_impact.position = position

        if p_angle:
            bullet_impact.scale.x = .75
            bullet_impact.rotate(p_angle)
            bullet_impact.position += Vector2.from_angle(p_angle) * Vector2(2, randi_range(1, 4))

    if p_angle:
        particle.look_at(Vector2.UP)
        particle.rotate(p_angle)

    particle.position = position
    particle.emitting = false
    
    particle.one_shot = true
    particle.finished.connect(particle.queue_free)
    particle.emitting = true

    queue_free()
