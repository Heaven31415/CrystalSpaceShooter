require "../unit"

class Pickup < Unit
  def initialize(max_velocity : SF::Vector2f, texture : SF::Texture)
    template = UnitTemplate.new(
      type: Unit::Type::EnemyWeapon,
      acceleration: SF.vector2f(0.0, 50.0),
      max_velocity: max_velocity,
      max_health: 1,
      texture: texture
    )
    super(template)
  end

  def update(dt : SF::Time) : Nil
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end
end

class PickupHealth < Pickup
  def initialize
    super(SF.vector2f(0.0, 100.0), App.resources[Textures::PICKUP_HEALTH])
  end

  def on_collision(other : Unit) : Nil
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

  def on_collision(other : Unit) : Nil
    if other.type == Unit::Type::Player
      enemies = world.get(Unit::Type::Enemy)
      enemies.each do |enemy|
        # todo: check whether it works!
        if enemy.velocity.y > 0f32
          enemy.velocity.y = -enemy.max_velocity.y
        end
      end
      kill
    end
  end
end
