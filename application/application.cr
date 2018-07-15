require "./config.cr"
require "./resources.cr"
require "./window.cr"
require "./state/state_manager.cr"

class Application
  def initialize
    Config.load("application.config")
    Window.load
    Resources.load_fonts
    Resources.load_sounds
    Resources.load_textures

    @manager = StateManager.new
    @manager.push(State::Type::Game)
  end

  def run
    @manager.run
  end
end

application = Application.new
application.run