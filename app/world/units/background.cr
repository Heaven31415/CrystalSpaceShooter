require "../../../common/utilities"
require "./unit"

class Background < Unit
  def initialize
    texture = App.resources[Textures::BACKGROUND]
    texture.repeated = true

    template = UnitTemplate.new(
      type: Unit::Type::Background,
      acceleration: SF.vector2f(0.0, 0.0),
      max_velocity: App.config["BackgroundVelocity", SF::Vector2f],
      max_health: 1,
      texture: texture,
      texture_rect: SF.int_rect(0, 0, App.render_size.x, App.render_size.y)
    )

    super(template)
    default_transform
    @velocity = App.config["BackgroundVelocity", SF::Vector2f]

    @extra = Unit.new(template)
    @extra.default_transform
    @extra.velocity = App.config["BackgroundVelocity", SF::Vector2f]
    @extra.move(0.0, -App.render_size.y)
  end

  def update(dt : SF::Time) : Nil
    @extra.update(dt)
    super

    move(0.0, -2 * App.render_size.y) if position.y > App.render_size.y
    @extra.move(0.0, -2 * App.render_size.y) if @extra.position.y > App.render_size.y
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    @extra.draw(target, states)
    super
  end
end
