require "crsfml/graphics"

class Cursor
  include SF::Drawable

  def initialize
    @cursor = SF::Sprite.new(Game.resources[Resource::Texture::CURSOR])
    @cursor.color = SF.color(255, 155, 155, 155)

    bounds = @cursor.local_bounds
    @cursor.origin = {bounds.width / 2.0, bounds.height / 2.0}
    @visible = false

    window = Game.window
    position = {window.size.x / 2, window.size.y / 2}
    SF::Mouse.set_position(position, window)
    @cursor.position = position
  end

  def input(event : SF::Event) : Nil
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