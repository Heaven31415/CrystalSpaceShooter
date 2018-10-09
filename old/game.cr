require "../common/sound_system"
require "../gui/button"
require "../gui/cursor"
require "../gui/hud"
require "./world"

class Game
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@audio = SoundSystem.new
  @@world = World.new
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, Config.window_size.y), Config.window_name)

  @clock = SF::Clock.new
  @dt = SF::Time.new

  class_getter(audio, world, window)

  def initialize
    desktop_mode = SF::VideoMode.desktop_mode
    @@window.position = {desktop_mode.width / 2 - Config.window_size.x / 2, desktop_mode.height / 2 - Config.window_size.y / 2}
    @@window.vertical_sync_enabled = true
    @@window.key_repeat_enabled = false
    @@window.mouse_cursor_visible = false
  end

  def run
    while @@window.open?
      @dt += @clock.restart
      while @dt >= @@TimePerFrame
        @dt -= @@TimePerFrame
        handle_input
        update(@@TimePerFrame)
      end
      render
    end
  end

  def handle_input
    while event = @@window.poll_event
      case event
      when SF::Event::Closed
        @@window.close
      end
      @@world.handle_input(event)
    end
  end

  def update(dt : SF::Time)
    @@world.update(dt)
  end

  def render
    @@window.clear
    @@world.render(@@window)
    @@window.display
  end
end
