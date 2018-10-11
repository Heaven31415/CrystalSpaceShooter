require "./state"
require "./manager"

require "../gui/old/button"
require "../gui/old/label"
require "../gui/old/slider"
require "../gui/cursor"

class Menu < State
  def initialize
    @cursor = Cursor.new

    size = App.render_size

    w = size.x * 0.18
    h = size.y * 0.18
    @shadow = SF::RectangleShape.new({w, h})
    @shadow.position = {size.x * 0.5 - w / 2, size.y * 0.5 - h / 2}
    @shadow.fill_color = SF::Color.new(200, 140, 140, 105)

    w = size.x * 0.15
    @label_volume = Label.new("Volume", 30, w.to_f32)
    @label_volume.position = {size.x * 0.5, size.y * 0.43}

    w = size.x * 0.15
    h = size.y * 0.04
    @slider_volume = Slider.new({w, h})
    @slider_volume.position = {size.x * 0.5 - w / 2, size.y * 0.47 - h / 2}
    @slider_volume.resize_fill_2(App.config["Volume", Float32].to_i32)

    @slider_volume.on_value_changed do |value|
      App.audio.music_volume = value.to_f32
    end

    w = size.x * 0.15
    h = size.y * 0.04
    @button_quit = Button.new({w, h})
    @button_quit.position = {size.x * 0.5 - w / 2, size.y * 0.52 - h / 2}
    @button_quit.add_label("Quit")

    @button_quit.on_click do
      App.window.close
    end
  end

  def draw(target : SF::RenderTarget)
    target.draw(@shadow)
    target.draw(@label_volume)
    target.draw(@button_quit)
    target.draw(@slider_volume)
    target.draw(@cursor)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::Closed
      App.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        App.manager.pop
      end
    end

    @cursor.handle_input(event)
    @button_quit.handle_input(event)
    @slider_volume.handle_input(event)
  end

  def update(dt : SF::Time) : Nil
  end

  def isolate_drawing : Bool
    false
  end

  def isolate_input : Bool
    true
  end

  def isolate_update : Bool
    true
  end

  def on_load
    puts "Loaded: #{self}"
  end

  def on_unload
    puts "Unloaded: #{self}"
  end
end