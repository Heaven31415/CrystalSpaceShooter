require "./config.cr"
require "./resources.cr"
require "./window.cr"
require "./state/cache.cr"
require "./state/manager.cr"

class App
  def self.config : Properties(Config)
    Config.instance
  end

  def self.window : SF::RenderWindow
    Window.instance
  end

  def self.resources : Resources
    Resources.instance
  end

  def self.player : Player
    Player.instance
  end

  def initialize
    Resources.instance.load_all
    # Audio.load
    Cache.load
    Manager.load

    @time_per_frame = SF.seconds(1.0 / App.config["Fps", Float32])
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def run
    @clock.restart

    while App.window.open? && !Manager.empty?
      @dt += @clock.restart
      while @dt >= @time_per_frame
        while event = App.window.poll_event
          Manager.handle_input(event)
        end
        Manager.update(@time_per_frame)
        Manager.draw(App.window)
        @dt -= @time_per_frame
      end 
    end
  end
end