extends Node2D
class_name Character

enum Faction {Player, Enemy}

@export var hp: float
@export var faction: Faction

func take_damage(amount: float):
    hp -= amount

    if hp <= 0:
        get_parent().queue_free()