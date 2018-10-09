require "./unit"

enum WeaponType
  Enemy
  Player
end

class Laser < Unit
  def initialize(weapon_type : WeaponType, @damage : Int32)
    case weapon_type
    when WeaponType::Enemy
      template = UnitTemplate.new(
        type: Unit::Type::EnemyWeapon,
        acceleration: SF.vector2f(0.0, 800.0),
        max_velocity: SF.vector2f(0.0, 200.0),
        max_health: 1,
        texture: App.resources[Textures::LASER_GREEN]
      )

      super(template)
      self.rotation = 180.0
    when WeaponType::Player
      template = UnitTemplate.new(
        type: Unit::Type::PlayerWeapon,
        acceleration: SF.vector2f(0.0, -800.0),
        max_velocity: SF.vector2f(0.0, 400.0),
        max_health: 1,
        texture: App.resources[Textures::LASER_RED]
      )
      
      super(template)
      self.rotation = 0.0
    else
      raise "Invalid WeaponType value: #{weapon_type}"
    end
  end

  def update(dt : SF::Time) : Nil
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end

  def on_collision(other : Unit) : Nil
    other.damage(@damage)
  end
end
