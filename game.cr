require "crsfml"
require "crsfml/audio"

require "./config.cr"
require "./resource_holder.cr"
require "./sound_system.cr"
require "./world.cr"

class Game
  @@TIME_PER_FRAME = SF.seconds(1.0 / Config.fps)
  @@fonts = ResourceHolder(SF::Font).new(Config.fonts_path, Config.fonts_ext)
  @@sounds = ResourceHolder(SF::SoundBuffer).new(Config.sounds_path, Config.sounds_ext)
  @@textures = ResourceHolder(SF::Texture).new(Config.textures_path, Config.textures_ext)
  @@audio = SoundSystem.new(@@sounds)
  @@world = World.new
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, Config.window_size.y), Config.window_name)

  define_class_methods(fonts, sounds, textures, audio, window, world)

  def initialize
    desktop_mode = SF::VideoMode.desktop_mode
    window = @@window

    # position window in the middle of the screen
    window.position =
      {desktop_mode.width / 2 - Config.window_size.x / 2, desktop_mode.height / 2 - Config.window_size.y / 2}

    # you won't be able to send multiple events holding pressed key
    window.mouse_cursor_visible = false
    window.vertical_sync_enabled = true
    window.key_repeat_enabled = false

    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def run
    while @@window.open?
      @dt += @clock.restart
      while @dt >= @@TIME_PER_FRAME
        @dt -= @@TIME_PER_FRAME
        handle_input
        update(@@TIME_PER_FRAME)
      end
      render
    end
  end

  def handle_input
    window = @@window
    while event = window.poll_event
      case event
      when SF::Event::Closed
        window.close
      end
      @@world.handle_input(event)
    end
  end

  def update(dt : SF::Time)
    @@world.update(dt)
  end

  def render
    window = @@window
    window.clear
    @@world.render(window)
    window.display
  end
end
