require "./config.cr"
require "./resources.cr"
require "./window.cr"
require "./state/cache.cr"
require "./state/manager.cr"

class Application
  def initialize
    Config.load("application.config")
    Window.load
    Resources.load_fonts
    Resources.load_sounds
    Resources.load_textures
    # Audio.load
    Cache.load
    Manager.load

    @time_per_frame = SF.seconds(1.0 / Config.get("Fps", Float32))
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def run
    @clock.restart

    while Window.open? && !Manager.empty?
      @dt += @clock.restart
      while @dt >= @time_per_frame
        while event = Window.poll_event
          Manager.handle_input(event)
        end
        Manager.update(@time_per_frame)
        Manager.draw(Window.instance)
        @dt -= @time_per_frame
      end 
    end
  end
end

application = Application.new
application.run