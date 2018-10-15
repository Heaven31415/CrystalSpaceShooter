require "../unit"
require "../ai/ai_fighter"

class EnemyFighter < Unit
  def initialize
    template = UnitTemplate.new(
      type: Unit::Type::Enemy,
      max_health: 1,
      max_velocity: SF.vector2f(200.0, 400.0),
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
      laser = Laser.new(WeaponType::Enemy, 1)
      laser.position = self.position
      laser.scale = {self.scale.x * 0.8f32, self.scale.y * 0.8f32}
      add_child(laser)
      world.add(laser)
    end
  end
end