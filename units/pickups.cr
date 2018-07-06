require "./unit.cr"

class Pickup < Unit
  def initialize(max_velocity : SF::Vector2f, texture_name : String)
    definition = UnitDefinition.new
    definition.type = Unit::Type::EnemyWeapon
    definition.acceleration = SF.vector2f(0.0, 50.0)
    definition.max_velocity = max_velocity
    definition.texture = Game.textures.get(texture_name)
    super(definition)
  end

  def update(dt)
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end
end

class PickupHealth < Pickup
  def initialize
    super(SF.vector2f(0.0, 100.0), "pickupHealth.png")
  end

  def on_collision(other)
    if other.type == Unit::Type::Player
      other.heal(5)
      kill
    end
  end
end

class PickupKnock < Pickup
  def initialize
    super(SF.vector2f(0.0, 200.0), "pickupKnock.png")
  end

  def on_collision(other)
    if other.type == Unit::Type::Player
      enemies = Game.world.get(->(unit : Unit) { unit.type == Unit::Type::Enemy })
      enemies.each do |enemy|
        enemy.velocity = -enemy.velocity
      end
      kill
    end
  end
end
