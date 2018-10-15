require "./state"
require "./state_manager"
require "../world/unit/*"
require "../gui/hud"

class Main < State
  getter world

  def initialize
    @world = World.new

    @carrier_callback = TimeCallback.new
    @fighter_callback = TimeCallback.new
    @meteor_callback = TimeCallback.new
    @meteor_storm_callback = TimeCallback.new
    @music_callback = TimeCallback.new

    r = Random.new

    @carrier_callback.add(SF.seconds(5)) do
      c = EnemyCarrier.new
      x = Game::WORLD_WIDTH * r.rand(0f32..1f32)
      y = Game::WORLD_HEIGHT * r.rand(0.3f32..0.6f32)
      c.position = {x, -y}
      @world.add(c)
    end

    @fighter_callback.add(SF.seconds(1)) do
      f = EnemyFighter.new
      x = Game::WORLD_WIDTH * r.rand(0f32..1f32)
      y = Game::WORLD_HEIGHT * r.rand(0.3f32..0.6f32)
      f.position = {x, -y}
      @world.add(f)
    end

    @meteor_callback.add(SF.seconds(2)) do
      # TODO: Implement Meteor.rand()
      m = Meteor.new(Meteor::Type.new(r.rand(0..3)))
      x = Game::WORLD_WIDTH * r.rand(0f32..1f32)
      y = Game::WORLD_HEIGHT * r.rand(0.3f32..0.6f32)
      m.position = {x, -y}
      @world.add(m)
    end

    @meteor_storm_callback.add(SF.seconds(12)) do
      x = Game::WORLD_WIDTH * r.rand(0f32..1f32)
      y = -(Game::WORLD_HEIGHT * r.rand(1.3f32..1.9f32))

      r.rand(20..40).times do
        m = Meteor.new(Meteor::Type.new(rand(0..3)))
        m.position = {x, y}
        m.max_velocity *= 3.0
        @world.add(m)

        case rand(0..3)
        when 0
          x += rand(50.0..75.0)
        when 1
          x -= rand(50.0..75.0)
        when 2
          y += rand(75.0..100.0)
        when 3
          y -= rand(75.0..100.0)
        end
      end

      Game.audio.play_sound(Resource::Sound::WARNING_METEOR_STORM)
    end

    @music_callback.add(SF.seconds(1), 1) do
      Game.audio.play_music(Resource::Music::LEVEL_1, Game.config["Volume", Float32])
    end

    @hud = HUD.new(SF.vector2f(Game::WORLD_WIDTH * 0.10, Game::WORLD_HEIGHT * 0.02))
    @hud.position = {Game::WORLD_WIDTH * 0.01, Game::WORLD_HEIGHT * 0.01}
    @intro_finished = false
  end

  def draw(target : SF::RenderTarget) : Nil
    target.draw(@world)
    target.draw(@hud)
  end

  def input(event : SF::Event) : Nil
    case event
    when SF::Event::Closed
      Game.window.close
    when SF::Event::KeyPressed
      if event.code == SF::Keyboard::Escape
        Game.manager.push(State::Type::Menu)
      end
    end
     Game.player.input(event)
  end

  def update(dt : SF::Time) : Nil
    if @intro_finished
      @carrier_callback.update(dt)
      # @fighter_callback.update(dt)
      # @meteor_callback.update(dt)
      # @meteor_storm_callback.update(dt)
      @music_callback.update(dt)
    elsif Game.manager.state == State::Type::Main
      @intro_finished = true
    end

    @world.update(dt)
    @hud.update(dt)
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

  def on_load : Nil
    Game.manager.push(State::Type::Intro)
  end

  def on_unload : Nil
  end
end