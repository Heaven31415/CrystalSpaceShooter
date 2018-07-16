require "./state.cr"
require "./manager.cr"

require "../gui/button.cr"
require "../gui/cursor.cr"

class Menu < State
  def initialize
    @cursor = Cursor.new

    @settings = Button.new({200f32, 40f32})
    @settings.position = {App.window.size.x * 0.5f32 - 100f32, App.window.size.y * 0.3f32}
    @settings.add_label("Settings")

    @exit = Button.new({200f32, 40f32})
    @exit.position = {App.window.size.x * 0.5f32 - 100f32, App.window.size.y * 0.4f32}
    @exit.add_label("Exit")
  end

  def draw(target : SF::RenderTarget)
    target.draw(@settings)
    target.draw(@exit)
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

    @settings.handle_input(event)
    @exit.handle_input(event)
    @cursor.handle_input(event)
  end

  def update(dt : SF::Time)
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
end