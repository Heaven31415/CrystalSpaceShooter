require "../../../common/utilities"
require "../unit"

class Background < Unit
  def initialize
    texture = Game.resources[Resource::Texture::BACKGROUND]
    texture.repeated = true

    template = UnitTemplate.new(
      type: Unit::Type::Background,
      max_health: 1,
      max_velocity: Game.config["BackgroundVelocity", SF::Vector2f],
      acceleration: SF.vector2f(0.0, 0.0),
      texture: texture,
      texture_rect: SF.int_rect(0, 0, Game::WORLD_WIDTH, Game::WORLD_HEIGHT),
      scale: SF.vector2f(1.0, 1.0)
    )

    super(template)
    default_transform
    @velocity = Game.config["BackgroundVelocity", SF::Vector2f]

    @extra = Unit.new(template)
    @extra.default_transform
    @extra.velocity = Game.config["BackgroundVelocity", SF::Vector2f]
    @extra.move(0.0, -Game::WORLD_HEIGHT)
  end

  def update(dt : SF::Time) : Nil
    @extra.update(dt)
    super

    move(0.0, -2 * Game::WORLD_HEIGHT) if position.y > Game::WORLD_HEIGHT
    @extra.move(0.0, -2 * Game::WORLD_HEIGHT) if @extra.position.y > Game::WORLD_HEIGHT
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    @extra.draw(target, states)
    super
  end
end
