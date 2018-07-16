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

  def self.cache : Cache
    Cache.instance
  end

  def self.manager : Manager
    Manager.instance
  end

  def initialize
    Resources.instance.load_all
    # Audio.load

    @time_per_frame = SF.seconds(1.0 / App.config["Fps", Float32])
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def run
    @clock.restart
    Manager.instance.push(State::Type::Game)
    Manager.instance.run
  end
end

app = App.new
app.run