require "../unit"
require "../ai/ai_carrier"

class EnemyCarrier < Unit
  def initialize
    template = UnitTemplate.new(
      type: Unit::Type::Enemy,
      max_health: 25,
      max_velocity: SF.vector2f(50.0, 50.0),
      acceleration: SF.vector2f(25.0, 25.0),
      texture: Game.resources[Resource::Texture::ENEMY_CARRIER],
      texture_rect: nil,
      scale: SF.vector2f(0.8, 0.8)
    )

    super(template)
    @ai = AICarrier.new(self)
  end

  def update(dt : SF::Time) : Nil
    super
  end

  def on_collision(other) : Nil
    other.damage(1)
  end
end