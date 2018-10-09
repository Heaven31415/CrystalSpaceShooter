require "crsfml/graphics"

class Cursor
  include SF::Drawable

  def initialize
    @cursor = SF::Sprite.new(App.resources[Textures::CURSOR])
    @cursor.color = SF.color(255, 155, 155, 155)

    bounds = @cursor.local_bounds
    @cursor.origin = {bounds.width / 2.0, bounds.height / 2.0}
    @visible = false

    w = App.window
    pos = {w.size.x / 2, w.size.y / 2}
    SF::Mouse.set_position(pos, w)
    @cursor.position = pos
  end

  def handle_input(event : SF::Event) : Nil
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

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    target.draw(@cursor, states) if @visible
  end
end