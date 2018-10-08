require "./state.cr"
require "./manager.cr"
require "../world/units/*"

class Game < State
  getter world

  def initialize
    @world = World.new

    player = App.player
    player.position = {App.window.size.x * 0.5f32, App.window.size.y * 0.75f32}
    @world.add(player)

    @carrier_cb = TimeCallback.new
    @fighter_cb = TimeCallback.new

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
  end

  def draw(target : SF::RenderTarget)
    target.draw(@world)
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

  def update(dt : SF::Time)
    @carrier_cb.update(dt)
    @fighter_cb.update(dt)
    @world.update(dt)
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