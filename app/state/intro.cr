require "./state"
require "./manager"

class Intro < State
  def initialize
    @voice_cb = TimeCallback.new

    number = 3
    @voice_cb.add(SF.seconds(1), 4) do
      case number
      when 3
        App.audio.play_sound(Sounds::THREE)
      when 2
        App.audio.play_sound(Sounds::TWO)
      when 1
        App.audio.play_sound(Sounds::ONE)
      when 0
        App.audio.play_sound(Sounds::SURVIVE)
        App.manager.pop
      end
      number -= 1
    end
  end

  def draw(target : SF::RenderTarget)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::Closed
      App.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        App.manager.push(State::Type::Menu)
      end
    end
  end

  def update(dt : SF::Time)
    @voice_cb.update(dt)
  end

  def isolate_drawing : Bool
    false
  end

  def isolate_input : Bool
    true
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