require "../../../common/utilities.cr"
require "./unit.cr"

class Background < Unit
  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Background
    definition.max_velocity = App.config["BackgroundVelocity", SF::Vector2f]
    definition.texture = App.resources[Textures::BACKGROUND]
    definition.texture.repeated = true
    definition.texture_rect = SF.int_rect(0, 0, App.window.size.x, App.window.size.y)

    super(definition)

    @extra = Unit.new(definition)
    @extra.default_transform
    @extra.velocity = App.config["BackgroundVelocity", SF::Vector2f]
    @extra.move(0.0, -App.window.size.y)

    self.default_transform
    self.velocity = App.config["BackgroundVelocity", SF::Vector2f]
  end

  def update(dt : SF::Time)
    @extra.update(dt)
    super

    move(0.0, -2 * App.window.size.y) if position.y > App.window.size.y
    @extra.move(0.0, -2 * App.window.size.y) if @extra.position.y > App.window.size.y
  end

  def draw(target, states)
    @extra.draw(target, states)
    super
  end
end
