require "./state.cr"
require "./manager.cr"
require "../world/units/*"

class Game < State
  getter world

  def initialize
    @world = World.new

    player = Player.instance
    player.position = {App.window.size.x * 0.5f32, App.window.size.y * 0.75f32}
    @world.add(player)

    # Enemies Test
    @world.add(EnemyCarrier.new)
    @world.add(EnemyFighter.new)
    @world.add(EnemyInterceptor.new)
  end

  def draw(target : SF::RenderTarget)
    @world.draw(target)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::Closed
      App.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::M
        App.manager.push(State::Type::Menu)
      end
    end
    App.player.handle_input(event)
  end

  def update(dt : SF::Time)
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
end