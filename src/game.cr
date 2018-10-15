require "./audio"
require "./config"
require "./resources"
require "./window"
require "./state/state_cache"
require "./state/state_manager"

class Game
  TIME_PER_FRAME = SF.seconds(1.0 / Config.instance["Fps", Float32])
  # TODO: Rename 'RenderWidth' to 'WorldWidth' and 'RenderHeight' to 'WorldHeight'
  WORLD_WIDTH = Config.instance["RenderWidth", Int32]
  WORLD_HEIGHT = Config.instance["RenderHeight", Int32]
  # TODO: Most probably I won't need this, because I can check window
  # to tell if it's windowed or not.
  class_property fullscreen : Bool = Config.instance["Fullscreen", Bool]

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

  def self.cache : StateCache
    StateCache.instance
  end

  def self.manager : StateManager
    StateManager.instance
  end

  def initialize
    Resources.instance.load_all
  end

  def run : Nil
    StateManager.instance.push(State::Type::Main)
    StateManager.instance.run
  end
end