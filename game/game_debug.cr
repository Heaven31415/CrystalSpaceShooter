require "../common/sound_system.cr"
require "../gui/button.cr"
require "../gui/cursor.cr"
require "../gui/hud.cr"
require "./world.cr"

class Game
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@audio = SoundSystem.new(Resources.sounds)
  @@world = World.new
  @@window = SF::RenderWindow.new(SF::VideoMode.new(2 * Config.window_size.x, Config.window_size.y), Config.window_name)

  @clock = SF::Clock.new
  @dt = SF::Time.new
  @running_mode = RunningMode::Continuous
  @step = false

  @cursor = Cursor.new
  @debug_text = SF::Text.new("", Resources.fonts.get("calibri.ttf"), 20)
  @target : Nil | Unit | World
  @texture = SF::RenderTexture.new(Config.window_size.x, Config.window_size.y)
  
  @hud = HUD.new
  @gui : Hash(String, Button)

  class_getter audio, world, window

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

    @debug_text.position = {@@window.size.x / 2 + 10, 280}
    @hud.position = {5, 5}
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
        when SF::Keyboard::F1
          @running_mode = RunningMode::Continuous
          @clock.restart
          @dt -= @dt
        when SF::Keyboard::F2
          if @running_mode != RunningMode::Step
            @running_mode = RunningMode::Step
          else
            @step = true
          end
        when SF::Keyboard::F3
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
      @gui.each { |name, widget| widget.handle_input(event) }
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
    @gui.each { |name, widget| @@window.draw(widget) }
    @@window.draw(@cursor)
    @@window.display
  end

  private def update_debug_information
    if target = @target
      @debug_text.string = target.to_s
    end
  end

  private def build_gui : Hash(String, Button)
    gui = Hash(String, Button).new

    button = Button.new({150, 60})
    button.position = {@@window.size.x / 2 + 10, 10}
    button.add_label("Continuous (F1)")
    button.on_click do
      @running_mode = RunningMode::Continuous
      @clock.restart
      @dt -= @dt
    end
    gui["Continuous"] = button

    button = Button.new({150, 60})
    button.position = {@@window.size.x / 2 + 10, 75}
    button.add_label("Step (F2)")
    button.on_click do
      if @running_mode != RunningMode::Step
        @running_mode = RunningMode::Step
      else
        @step = true
      end
    end
    gui["Step"] = button

    button = Button.new({150, 60})
    button.position = {@@window.size.x / 2 + 10, 140}
    button.add_label("World (F3)")
    button.on_click do
      @target = @@world
      update_debug_information
    end
    gui["World"] = button

    button = Button.new({120, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 170, 10}
    button.add_label("Fighter")
    button.on_click do
      enemy = EnemyFighter.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyFighter"] = button

    button = Button.new({120, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 170, 75}
    button.add_label("Carrier")
    button.on_click do
      enemy = EnemyCarrier.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyCarrier"] = button

    button = Button.new({120, 60}, RedButtonStyle.new)
    button.position = {@@window.size.x / 2 + 170, 140}
    button.add_label("Interceptor")
    button.on_click do
      enemy = EnemyInterceptor.new
      enemy.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(enemy)
    end
    gui["EnemyInterceptor"] = button

    button = Button.new({120, 60}, GreenButtonStyle.new)
    button.position = {@@window.size.x / 2 + 300, 10}
    button.add_label("Health")
    button.on_click do
      pickup = PickupHealth.new
      pickup.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(pickup)
    end
    gui["PickupHealth"] = button

    button = Button.new({120, 60}, GreenButtonStyle.new)
    button.position = {@@window.size.x / 2 + 300, 75}
    button.add_label("Knock")
    button.on_click do
      pickup = PickupKnock.new
      pickup.position = {Config.window_size.x / 2, -Config.window_size.y * 0.25}
      @@world.add(pickup)
    end
    gui["PickupKnock"] = button

    button = Button.new({120, 60}, BlueButtonStyle.new)
    button.position = {@@window.size.x / 2 + 430, 10}
    button.add_label("Big Meteor")
    button.on_click do
      meteor = Meteor.new(Meteor::Type::Big)
      meteor.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(meteor)
    end
    gui["BigMeteor"] = button

    button = Button.new({120, 60}, BlueButtonStyle.new)
    button.position = {@@window.size.x / 2 + 430, 75}
    button.add_label("Med Meteor")
    button.on_click do
      meteor = Meteor.new(Meteor::Type::Medium)
      meteor.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(meteor)
    end
    gui["MedMeteor"] = button

    button = Button.new({120, 60}, BlueButtonStyle.new)
    button.position = {@@window.size.x / 2 + 430, 140}
    button.add_label("Small Meteor")
    button.on_click do
      meteor = Meteor.new(Meteor::Type::Small)
      meteor.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(meteor)
    end
    gui["SmallMeteor"] = button

    button = Button.new({120, 60}, BlueButtonStyle.new)
    button.position = {@@window.size.x / 2 + 430, 205}
    button.add_label("Tiny Meteor")
    button.on_click do
      meteor = Meteor.new(Meteor::Type::Tiny)
      meteor.position = {Random.rand(0..Config.window_size.x - 1), -Config.window_size.y * 0.25}
      @@world.add(meteor)
    end
    gui["TinyMeteor"] = button

    gui
  end
end