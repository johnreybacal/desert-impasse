extends RigidBody2D
class_name Bullet

var bullet_speed = 500
var direction: Vector2
var distance_travelled: float
var max_distance: float
var initial_position: Vector2

var impact_particle_scene := preload("res://scenes/bullet_impact_particle.tscn")
var bullet_impact_scene := preload("res://scenes/bullet_impact.tscn")

func _ready() -> void:
    initial_position = position

func _process(delta: float) -> void:
    var velocity = direction * bullet_speed * delta
    
    var collision := move_and_collide(velocity)
    
    if collision:
        hit_world(velocity.angle())

    distance_travelled = position.distance_to(initial_position)

    if distance_travelled >= max_distance:
        hit_world()

    
func hit_world(angle = null):
    var bullet_impact: Sprite2D = bullet_impact_scene.instantiate()
    get_parent().add_child(bullet_impact)
    bullet_impact.position = position

    var particle: GPUParticles2D = impact_particle_scene.instantiate()
    get_parent().add_child(particle)

    if angle:
        bullet_impact.scale.x = .75
        bullet_impact.rotate(angle)
        bullet_impact.position += Vector2.from_angle(angle) * Vector2(2, randi_range(1, 4))
        particle.look_at(Vector2.UP)
        particle.rotate(angle)

    particle.position = position
    particle.emitting = false
    
    particle.one_shot = true
    particle.finished.connect(particle.queue_free)
    particle.emitting = true

    queue_free()
