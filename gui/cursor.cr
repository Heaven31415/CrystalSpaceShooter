require "crsfml/graphics"

class Cursor
  include SF::Drawable

  def initialize
    @cursor = SF::Sprite.new(Resources.textures.get("cursor.png"))
    @cursor.color = SF.color(255, 155, 155, 155)
    @visible = false
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::MouseEntered
      @visible = true
    when SF::Event::MouseLeft
      @visible = false
    when SF::Event::MouseMoved
      if !@visible
        @visible = true
      else
        @cursor.position = {event.x, event.y}
      end
    end
  end

  def draw(target, states)
    target.draw(@cursor, states) if @visible
  end
end