require "./audio"
require "./config"
require "./resources"
require "./window"
require "./state/cache"
require "./state/manager"

class App
  @@fullscreen : Bool = Config.instance["Fullscreen", Bool]

  def self.fullscreen=(value : Bool) : Nil
    @@fullscreen = value
  end

  def self.fullscreen : Bool
    @@fullscreen
  end

  def self.audio : Audio
    Audio.instance
  end

  def self.config : Properties(Config)
    Config.instance
  end

  def self.resources : Resources
    Resources.instance
  end

  def self.render_size : SF::Vector2u
    SF::Vector2u.new(Config.instance["RenderWidth", Int32], Config.instance["RenderHeight", Int32])
  end
  
  def self.window : SF::RenderWindow
    Window.instance
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
  end

  def run
    Manager.instance.push(State::Type::Game)
    Manager.instance.run
    Audio.instance.stop_music
  end
end

app = App.new
app.run