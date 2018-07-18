require "./unit.cr"

enum WeaponType
  Enemy
  Player
end

class Laser < Unit
  def initialize(weapon_type : WeaponType, @damage : Int32)
    case weapon_type
    when WeaponType::Enemy
      definition = UnitDefinition.new
      definition.type = Unit::Type::EnemyWeapon
      definition.acceleration = SF.vector2f(0.0, 800.0)
      definition.max_velocity = SF.vector2f(0.0, 200.0)
      definition.texture = App.resources[Textures::LASER_GREEN]
      super(definition)
      self.rotation = 180.0
    when WeaponType::Player
      definition = UnitDefinition.new
      definition.type = Unit::Type::PlayerWeapon
      definition.acceleration = SF.vector2f(0.0, -800.0)
      definition.max_velocity = SF.vector2f(0.0, 400.0)
      definition.texture = App.resources[Textures::LASER_RED]
      super(definition)
    else
      raise "Invalid WeaponType value: #{weapon_type}"
    end
  end

  def update(dt)
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end

  def on_collision(other)
    other.damage(@damage)
  end
end
