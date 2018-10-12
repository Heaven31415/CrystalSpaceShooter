require "./state"
require "./manager"

class Warning < State
  def initialize
    @rectangle = SF::RectangleShape.new(App.render_size)
    @rectangle.fill_color = SF::Color.new(255, 50, 50, 0)
    @max_opacity = 50u8
    @min_opacity = 0u8
    @opacity = 0u8
    @increasing = true
    @counter = 0
  end

  def draw(target : SF::RenderTarget)
    target.draw(@rectangle)
  end

  def handle_input(event : SF::Event)
  end

  def update(dt : SF::Time)
    @rectangle.fill_color = SF::Color.new(255, 50, 50, @opacity)

    if @increasing
      if @opacity < @max_opacity
        @opacity += 5u8
      else
        @counter += 1
        @increasing = false
      end
    else
      if @opacity > @min_opacity
        @opacity -= 5u8
      else
        @counter += 1
        @increasing = true
      end
    end

    if @counter == 2
      @counter = 0
      @opacity = 0u8
      @increasing = true
      App.manager.pop
    end
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

  def on_load
    puts "Loaded: #{self}"
  end

  def on_unload
    puts "Unloaded: #{self}"
  end
end