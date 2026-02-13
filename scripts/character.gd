extends Node2D
class_name Character

enum Faction {Player, Enemy}

@export var hp: float
@export var faction: Faction
    
signal knocked_back(k: Vector2)

func take_damage(amount: float):
    hp -= amount

    if hp <= 0:
        get_parent().queue_free()

func knock_back(force: float, direction: Vector2):
    knocked_back.emit(force * direction)
