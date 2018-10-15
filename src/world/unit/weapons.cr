require "../unit"

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
        max_health: 1,
        max_velocity: SF.vector2f(0.0, 200.0),
        acceleration: SF.vector2f(0.0, 800.0),
        texture: Game.resources[Resource::Texture::LASER_GREEN],
        texture_rect: nil,
        scale: SF.vector2f(0.5, 0.5)
      )

      super(template)
      self.rotation = 180f32
    when WeaponType::Player
      template = UnitTemplate.new(
        type: Unit::Type::PlayerWeapon,
        max_health: 1,
        max_velocity: SF.vector2f(0.0, 400.0),
        acceleration: SF.vector2f(0.0, -800.0),
        texture: Game.resources[Resource::Texture::LASER_RED],
        texture_rect: nil,
        scale: SF.vector2f(0.5, 0.5)
      )
      
      super(template)
      self.rotation = 0f32
    else
      raise "Invalid WeaponType value: '#{weapon_type}'"
    end
  end

  def update(dt : SF::Time) : Nil
    accelerate(Direction::Down, dt)
    super
  end

  def on_collision(other : Unit) : Nil
    other.damage(@damage)
  end
end
