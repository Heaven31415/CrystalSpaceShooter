require "./unit"

class Pickup < Unit
  def initialize(max_velocity : SF::Vector2f, texture : SF::Texture)
    definition = UnitDefinition.new
    definition.type = Unit::Type::EnemyWeapon
    definition.acceleration = SF.vector2f(0.0, 50.0)
    definition.max_velocity = max_velocity
    definition.texture = texture
    super(definition)
  end

  def update(dt)
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end
end

class PickupHealth < Pickup
  def initialize
    super(SF.vector2f(0.0, 100.0), App.resources[Textures::PICKUP_HEALTH])
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
    super(SF.vector2f(0.0, 200.0), App.resources[Textures::PICKUP_KNOCK])
  end

  def on_collision(other)
    if other.type == Unit::Type::Player
      enemies = world.get(->(unit : Unit) { unit.type == Unit::Type::Enemy })
      enemies.each do |enemy|
        enemy.velocity = -enemy.velocity # todo: fix it, because it doesn't knock
      end
      kill
    end
  end
end
