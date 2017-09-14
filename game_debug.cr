require "crsfml"
require "crsfml/audio"

require "./common/resource_holder.cr"
require "./common/sound_system.cr"
require "./widgets/button.cr"
require "./widgets/slider.cr"
require "./ui/hud.cr"
require "./config.cr"
require "./world.cr"

class Cursor
  include SF::Drawable

  def initialize
    @cursor = SF::Sprite.new(Game.textures.get("cursor.png"))
    @cursor.color = SF.color(255, 155, 155, 155)
    @visible = false
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::MouseEntered
      @visible = true
    when SF::Event::MouseLeft
      @visible = false
    when SF::Event::MouseMoved
      if !@visible
        @visible = true
      else
        @cursor.position = {event.x, event.y}
      end
    end
  end

  def draw(target, states)
    target.draw(@cursor, states) if @visible
  end
end

alias GUI = Hash(String, Button)

class Game
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@fonts = ResourceHolder(SF::Font).new(Config.fonts_path, Config.fonts_ext)
  @@sounds = ResourceHolder(SF::SoundBuffer).new(Config.sounds_path, Config.sounds_ext)
  @@textures = ResourceHolder(SF::Texture).new(Config.textures_path, Config.textures_ext)
  @@audio = SoundSystem.new(@@sounds)
  @@world = World.new
  @@window = SF::RenderWindow.new(SF::VideoMode.new(2 * Config.window_size.x, Config.window_size.y), Config.window_name)
  @texture = SF::RenderTexture.new(Config.window_size.x, Config.window_size.y)
  @target : Nil | Unit | World
  @gui : GUI

  class_getter fonts, sounds, textures, audio, world, window

  enum RunningMode
    Continuous
    Step
  end

  def initialize
    desktop = SF::VideoMode.desktop_mode
    @@window.position = {(desktop.width - @@window.size.x) / 2, (desktop.height - @@window.size.y) / 2}
    @@window.vertical_sync_enabled = true
    @@window.key_repeat_enabled = false
    @@window.mouse_cursor_visible = false

    @step = false
    @running_mode = RunningMode::Continuous
    @debug_text = SF::Text.new("", @@fonts.get("calibri.ttf"), 20)
    @debug_text.position = {@@window.size.x / 2 + 10, 80}

    @clock = SF::Clock.new
    @dt = SF::Time.new

    @hud = HUD.new
    @hud.position = {5, 5}
    @cursor = Cursor.new
    @gui = build_gui
  end

  def run
    while @@window.open?
      case @running_mode
      when RunningMode::Continuous
        @dt += @clock.restart
        while @dt >= @@TimePerFrame
          handle_input
          update(@@TimePerFrame)
          @dt -= @@TimePerFrame
        end
        render
      when RunningMode::Step
        if @step
          update(@@TimePerFrame)
          @step = false
        end
        handle_input
        render
      end
    end
  end

  def handle_input
    while event = @@window.poll_event
      case event
      when SF::Event::Closed
        @@window.close
      when SF::Event::KeyPressed
        case event.code
        when SF::Keyboard::Num1
          @running_mode = RunningMode::Continuous
          @clock.restart
          @dt -= @dt
        when SF::Keyboard::Num2
          if @running_mode != RunningMode::Step
            @running_mode = RunningMode::Step
          else
            @step = true
          end
        when SF::Keyboard::W
          @target = @@world
          update_debug_information
        end
      when SF::Event::MouseButtonPressed
        if event.button.left?
          @@world.get.each do |u|
            if u.type != Unit::Type::Background
              if u.close?(event.x, event.y)
                @target = u
                update_debug_information
              end
            end
          end
        end
      end
      @@world.handle_input(event)
      @cursor.handle_input(event)
      @gui.each { |k, w| w.handle_input(event) }
    end
  end

  def update(dt : SF::Time)
    @@world.update(dt)
    @hud.update(@@world.player)
    if target = @target
      update_debug_information
    end
  end

  def render
    @texture.clear
    @@world.render(@texture)
    @texture.draw(@hud)
    @texture.display

    @@window.clear
    @@window.draw(SF::Sprite.new(@texture.texture))
    @@window.draw(@debug_text)
    @gui.each { |k, w| @@window.draw(w) }
    @@window.draw(@cursor)
    @@window.display
  end

  private def update_debug_information
    if target = @target
      @debug_text.string = target.to_s
    end
  end

  private def build_gui
    gui = {} of String => Button

    button = Button.new({90, 60})
    button.position = {@@window.size.x / 2 + 10, 10}
    button.add_label("Continuous")
    button.on_click do
      @running_mode = RunningMode::Continuous
      @clock.restart
      @dt -= @dt
    end
    gui["Continuous"] = button

    button = Button.new({90, 60})
    button.position = {@@window.size.x / 2 + 105, 10}
    button.add_label("Step")
    button.on_click do
      if @running_mode != RunningMode::Step
        @running_mode = RunningMode::Step
      else
        @step = true
      end
    end
    gui["Step"] = button

    button = Button.new({90, 60})
    button.position = {@@window.size.x / 2 + 200, 10}
    button.add_label("World")
    button.on_click do
      @target = @@world
      update_debug_information
    end
    gui["World"] = button

    button = Button.new({90, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 485, 10}
    button.add_label("Fighter")
    button.on_click do
      enemy = EnemyFighter.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyFighter"] = button

    button = Button.new({90, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 485, 70}
    button.add_label("Carrier")
    button.on_click do
      enemy = EnemyCarrier.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyCarrier"] = button

    button = Button.new({90, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 485, 130}
    button.add_label("Interceptor")
    button.on_click do
      enemy = EnemyInterceptor.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyInterceptor"] = button

    button = Button.new({90, 60}, GreenButtonStyle.new)
    button.position = {@@window.size.x / 2 + 580, 10}
    button.add_label("Health")
    button.on_click do
      pickup = PickupHealth.new
      pickup.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(pickup)
    end
    gui["PickupHealth"] = button

    button = Button.new({90, 60}, GreenButtonStyle.new)
    button.position = {@@window.size.x / 2 + 580, 70}
    button.add_label("Knock")
    button.on_click do
      pickup = PickupKnock.new
      pickup.position = {Config.window_size.x / 2, -Config.window_size.y * 0.25}
      @@world.add(pickup)
    end
    gui["PickupKnock"] = button

    gui
  end
end
