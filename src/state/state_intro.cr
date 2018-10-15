require "./state"
require "./state_manager"

# TODO: Rename 'Sounds::THREE' to 'Resource::Sound::THREE' etc.

class Intro < State
  def initialize
    @voice_callback = TimeCallback.new

    counter = 3
    @voice_callback.add(SF.seconds(1), 4) do
      case counter
      when 3
        Game.audio.play_sound(Resource::Sound::THREE)
      when 2
        Game.audio.play_sound(Resource::Sound::TWO)
      when 1
        Game.audio.play_sound(Resource::Sound::ONE)
      when 0
        Game.audio.play_sound(Resource::Sound::SURVIVE)
        Game.manager.pop
      end
      counter -= 1
    end
  end

  def draw(target : SF::RenderTarget) : Nil
  end

  def input(event : SF::Event) : Nil
    case event
    when SF::Event::Closed
      Game.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        Game.manager.push(State::Type::Menu)
      end
    end
  end

  def update(dt : SF::Time) : Nil
    @voice_callback.update(dt)
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

  def on_load : Nil
  end

  def on_unload : Nil
  end
end