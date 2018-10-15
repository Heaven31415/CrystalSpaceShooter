require "../unit"
require "../ai/ai_interceptor"

class EnemyInterceptor < Unit
  class Laser < Unit
    def initialize
      template = UnitTemplate.new(
        type: Unit::Type::EnemyWeapon,
        max_health: 1,
        max_velocity: SF.vector2f(0.0, 200.0),
        acceleration: SF.vector2f(0.0, 500.0),
        texture: Game.resources[Resource::Texture::LASER_GREEN],
        texture_rect: nil,
        scale: SF.vector2f(0.17, 0.17)
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
      max_velocity: SF.vector2f(200.0, 200.0),
      acceleration: SF.vector2f(100.0, 100.0),
      texture: Game.resources[Resource::Texture::ENEMY_INTERCEPTOR],
      texture_rect: nil,
      scale: SF.vector2f(0.17, 0.17)
    )

    super(template)
    @ai = AIInterceptor.new(self)
  end

  def update(dt : SF::Time) : Nil
    super
  end

  def on_collision(other : Unit) : Nil
    other.damage(1)
  end

  def fire_laser : Nil
    if @children.size < 3
      laser = Laser.new
      laser.position = self.position
      add_child(laser)
      world.add(laser)
    end
  end
end