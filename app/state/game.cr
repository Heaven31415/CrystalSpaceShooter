require "./state"
require "./manager"
require "../world/units/*"
require "../gui/hud"

class Game < State
  getter world

  def initialize
    @world = World.new

    @carrier_cb = TimeCallback.new
    @fighter_cb = TimeCallback.new
    @meteor_cb = TimeCallback.new

    @carrier_cb.add(SF.seconds(14)) do
      carrier = EnemyCarrier.new
      x = App.window.size.x * rand.to_f32
      y = -(100f32 + 100f32 * rand.to_f32)
      carrier.position = {x, y}
      @world.add(carrier)
    end

    @fighter_cb.add(SF.seconds(2)) do
      fighter = EnemyFighter.new
      x = App.window.size.x * rand.to_f32
      y = -(100f32 + 100f32 * rand.to_f32)
      fighter.position = {x, y}
      @world.add(fighter)
    end

    @meteor_cb.add(SF.seconds(5)) do
      meteor = Meteor.new(Meteor::Type.new(rand(0..3)))
      x = App.window.size.x * rand.to_f32
      y = -(100f32 + 100f32 * rand.to_f32)
      meteor.position = {x, y}
      @world.add(meteor)
    end

    @hud = HUD.new
    @hud.position = {App.window.size.x * 0.01, App.window.size.y * 0.01}
  end

  def draw(target : SF::RenderTarget)
    target.draw(@world)
    target.draw(@hud)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::Closed
      App.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        App.manager.push(State::Type::Menu)
      end
    end
    App.player.handle_input(event)
  end

  def update(dt : SF::Time) : Nil
    @carrier_cb.update(dt)
    @fighter_cb.update(dt)
    @meteor_cb.update(dt)
    @world.update(dt)
    @hud.update
  end

  def isolate_drawing : Bool
    true
  end

  def isolate_input : Bool
    true
  end

  def isolate_update : Bool
    true
  end

  def on_load
    puts "Loaded: #{self}"
  end

  def on_unload
    puts "Unloaded: #{self}"
  end
end