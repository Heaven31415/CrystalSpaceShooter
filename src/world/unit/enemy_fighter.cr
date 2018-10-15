require "../unit"
require "../ai/ai_fighter"

class EnemyFighter < Unit
  class Laser < Unit
    def initialize
      template = UnitTemplate.new(
        type: Unit::Type::EnemyWeapon,
        max_health: 1,
        max_velocity: SF.vector2f(0.0, 200.0),
        acceleration: SF.vector2f(0.0, 600.0),
        texture: Game.resources[Resource::Texture::LASER_GREEN],
        texture_rect: nil,
        scale: SF.vector2f(0.4, 0.4)
      )
      super(template)
      self.rotation = 180.0
    end

    def update(dt : SF::Time) : Nil
      accelerate(Direction::Down, dt)
      super
    end
  
    def on_collision(other : Unit) : Nil
      other.damage(1)
    end 
  end

  def initialize
    template = UnitTemplate.new(
      type: Unit::Type::Enemy,
      max_health: 1,
      max_velocity: SF.vector2f(150.0, 350.0),
      acceleration: SF.vector2f(150.0, 200.0),
      texture: Game.resources[Resource::Texture::ENEMY_FIGHTER],
      texture_rect: nil,
      scale: SF.vector2f(0.5, 0.5)
    )

    super(template)
    @ai = AIFighter.new(self)
  end

  def update(dt : SF::Time) : Nil
    super
  end

  def on_collision(other : Unit) : Nil
    other.damage(1)
  end

  def fire_laser : Nil
    if @children.size < 5
      laser = Laser.new
      laser.position = self.position
      add_child(laser)
      world.add(laser)
      Game.audio.play_sound(Resource::Sound::PHASER_UP1, 40f32, 0.4f32)
    end
  end
end