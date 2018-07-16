require "./state.cr"
require "./manager.cr"

class Menu < State
  def initialize
  end

  def draw(target : SF::RenderTarget)
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