require "./state"
require "./state_manager"

require "../gui/old/button"
require "../gui/old/label"
require "../gui/old/slider"
require "../gui/cursor"

class Menu < State
  def initialize
    @cursor = Cursor.new

    w = Game::WORLD_WIDTH * 0.18
    h = Game::WORLD_HEIGHT * 0.18
    @shadow = SF::RectangleShape.new({w, h})
    @shadow.position = {Game::WORLD_WIDTH * 0.5 - w / 2, Game::WORLD_HEIGHT * 0.5 - h / 2}
    @shadow.fill_color = SF.color(200, 140, 140, 105)

    w = Game::WORLD_WIDTH * 0.15
    @label_volume = Label.new("Volume", 30, w.to_f32)
    @label_volume.position = {Game::WORLD_WIDTH * 0.5, Game::WORLD_HEIGHT * 0.43}

    w = Game::WORLD_WIDTH * 0.15
    h = Game::WORLD_HEIGHT * 0.04
    @slider_volume = Slider.new({w, h})
    @slider_volume.position = {Game::WORLD_WIDTH * 0.5 - w / 2, Game::WORLD_HEIGHT * 0.47 - h / 2}
    @slider_volume.resize_fill_2(Game.config["Volume", Float32].to_i32)
    @slider_volume.on_value_changed do |value|
      Game.audio.music_volume = value.to_f32
    end

    w = Game::WORLD_WIDTH * 0.15
    h = Game::WORLD_HEIGHT * 0.04
    @button_quit = Button.new({w, h})
    @button_quit.position = {Game::WORLD_WIDTH * 0.5 - w / 2, Game::WORLD_HEIGHT * 0.52 - h / 2}
    @button_quit.add_label("Quit")
    @button_quit.on_click do
      Game.window.close
    end
  end

  def draw(target : SF::RenderTarget) : Nil
    target.draw(@shadow)
    target.draw(@label_volume)
    target.draw(@button_quit)
    target.draw(@slider_volume)
    target.draw(@cursor)
  end

  def input(event : SF::Event) : Nil
    case event
    when SF::Event::Closed
      Game.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        Game.manager.pop
      end
    end

    @cursor.input(event)
    @button_quit.input(event)
    @slider_volume.input(event)
  end

  def update(dt : SF::Time) : Nil
  end

  def isolate_drawing : Bool
    false
  end

  def isolate_input : Bool
    true
  end

  def isolate_update : Bool
    true
  end

  def on_load : Nil
  end

  def on_unload : Nil
  end
end