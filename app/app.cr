require "./audio.cr"
require "./config.cr"
require "./resources.cr"
require "./window.cr"
require "./state/cache.cr"
require "./state/manager.cr"

class App
  def self.audio : Audio
    Audio.instance
  end

  def self.config : Properties(Config)
    Config.instance
  end

  def self.resources : Resources
    Resources.instance
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
    Audio.instance.play_music(Music::JUHANI_JUNKALA_RETRO_GAME_MUSIC_PACK_TITLE_SCREEN)

    @time_per_frame = SF.seconds(1.0 / App.config["Fps", Float32])
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def run
    @clock.restart
    Manager.instance.push(State::Type::Designer)
    Manager.instance.run
    Audio.instance.stop_music
  end
end

app = App.new
app.run