require "./state"
require "./state_manager"

class Warning < State
  def initialize
    @rectangle = SF::RectangleShape.new({Game::WORLD_WIDTH, Game::WORLD_HEIGHT})
    @rectangle.fill_color = SF.color(255, 50, 50, 0)

    @opacity_callback = TimeCallback.new
    @opacity = 0
    @direction = 1

    @opacity_callback.add_ending do
      Game.manager.pop
    end
  end

  def draw(target : SF::RenderTarget) : Nil
    target.draw(@rectangle)
  end

  def input(event : SF::Event) : Nil
  end

  def update(dt : SF::Time) : Nil
    @opacity_callback.update(dt)
  end

  def isolate_drawing : Bool
    false
  end

  def isolate_input : Bool
    false
  end

  def isolate_update : Bool
    false
  end

  def on_load : Nil
    @opacity_callback.add(Game::TIME_PER_FRAME, 50) do
      if @opacity < 0 || @opacity > 25
        @direction *= -1
      end

      @opacity += @direction
      @rectangle.fill_color = SF.color(255, 50, 50, @opacity.to_u8)
    end
  end

  def on_unload : Nil
    @rectangle.fill_color = SF.color(255, 50, 50, 0)
    @opacity = 0u8
    @direction = 1
  end
end