require "../common/utilities.cr"
require "./unit.cr"

class Background < Unit
  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Background
    definition.max_velocity = Config.background_velocity
    definition.texture = Game.textures.get("background.png")
    definition.texture.repeated = true
    definition.texture_rect = Config.window_rect

    super(definition)

    @extra = Unit.new(definition)
    @extra.default_transform
    @extra.velocity = Config.background_velocity
    @extra.move(0.0, -Config.window_size.y)

    self.default_transform
    self.velocity = Config.background_velocity
  end

  def update(dt : SF::Time)
    move(0.0, -2 * Config.window_size.y) if position.y > Config.window_size.y
    @extra.move(0.0, -2 * Config.window_size.y) if @extra.position.y > Config.window_size.y
    @extra.update(dt)
    super
  end

  def draw(target, states)
    @extra.draw(target, states)
    super
  end
end
