require "../../../common/utilities.cr"
require "./unit.cr"

class Background < Unit
  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Background
    definition.max_velocity = Config.get("BackgroundVelocity", SF::Vector2f)
    definition.texture = Resources.get(Textures::Background)
    definition.texture.repeated = true
    definition.texture_rect = SF.int_rect(0, 0, Window.size.x, Window.size.y)

    super(definition)

    @extra = Unit.new(definition)
    @extra.default_transform
    @extra.velocity = Config.get("BackgroundVelocity", SF::Vector2f)
    @extra.move(0.0, -Config.get("WindowHeight", Int32))

    self.default_transform
    self.velocity = Config.get("BackgroundVelocity", SF::Vector2f)
  end

  def update(dt : SF::Time)
    move(0.0, -2 * Window.size.y) if position.y > Window.size.y
    @extra.move(0.0, -2 * Window.size.y) if @extra.position.y > Window.size.y
    @extra.update(dt)
    super
  end

  def draw(target, states)
    @extra.draw(target, states)
    super
  end
end
