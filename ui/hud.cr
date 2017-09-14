require "../units/player.cr"

class HUD < SF::RectangleShape
  def initialize(size : SF::Vector2 = SF.vector2(200, 25))
    @back = SF::RectangleShape.new(size)
    @back.fill_color = SF.color(200, 200, 200, 255)
    @back.outline_color = SF.color(40, 20, 20, 255)
    @back.outline_thickness = -3
    @health_percent = 100_f32

    super(size)
    self.fill_color = SF.color(190, 60, 60, 255)
    self.outline_color = SF.color(40, 20, 20, 255)
    self.outline_thickness = -3
  end

  def position=(position : SF::Vector2 | Tuple)
    @back.position = position
    super
  end

  def draw(target, states)
    target.draw(@back, states)
    super
  end

  def update(player : Player)
    @health_percent = player.health_percent
    self.size = {@health_percent * @back.size.x / 100.0, @back.size.y}
  end
end
