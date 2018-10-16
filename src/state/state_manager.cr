require "./state_cache"

class StateManager
  @@instance : StateManager?

  def self.create : StateManager
    state_manager = StateManager.new
    state_manager
  end

  def self.instance : StateManager
    @@instance ||= create
  end

  @fullscreen : Bool

  def initialize
    @states = [] of State
    @requests = Deque(State::Type?).new
    @clock = SF::Clock.new
    @dt = SF::Time.new
    @texture = SF::RenderTexture.new(Game::WORLD_WIDTH, Game::WORLD_HEIGHT)
    @fullscreen = Game.config["Fullscreen", Bool]
  end

  # TODO: Probably rename from 'state' to 'current' or 'actual'
  def state : State::Type?
    return nil if @states.size == 0

    case @states[@states.size - 1]
    when Intro
      State::Type::Intro
    when Main
      State::Type::Main
    when Menu
      State::Type::Menu
    when Warning
      State::Type::Warning
    else
      nil
    end
  end

  def push(state : State::Type) : Nil
    @requests.push(state)
  end

  def pop : Nil
    @requests.push(nil)
  end

  private def process_requests : Nil
    until @requests.empty?
      case request = @requests.pop
      when State::Type
        state = Game.cache[request]
        state.on_load
        @states.push(state)
      when Nil
        if @states.empty?
          raise "Unable to remove state from empty StateManager"
        else
          state = @states.pop
          state.on_unload
        end
      end
    end
  end

  def run : Nil
    process_requests
    @clock.restart

    window = Game.window
    sprite = SF::Sprite.new

    while window.open? && @states.size != 0
      @dt += @clock.restart
      while @dt >= Game::TIME_PER_FRAME
        while event = window.poll_event
          input(event)
        end

        update(Game::TIME_PER_FRAME)
        process_requests

        @dt -= Game::TIME_PER_FRAME
      end

      render(@texture)

      # This will change when switching between fullscreen and windowed mode.
      w = window.size.x / Game::WORLD_WIDTH.to_f32
      h = window.size.y / Game::WORLD_HEIGHT.to_f32

      window.clear
      sprite.texture = @texture.texture
      sprite.scale = {w, h}
      window.draw(sprite)
      window.display
    end
  end

  private def render(target : SF::RenderTarget) : Nil
    target.clear

    isolation_index = nil
    i = @states.size - 1
    while i >= 0
      if @states[i].isolate_drawing == true
        isolation_index = i
        break
      end
      i -= 1
    end

    if isolation_index
      i = isolation_index
      while i < @states.size
        @states[i].draw(target)
        i += 1
      end
    else
      @states.each do |state|
        state.draw(target)  
      end
    end

    target.display
  end

  private def input(event : SF::Event) : Nil
    if event.is_a? SF::Event::KeyPressed
      if event.code == SF::Keyboard::Return && event.alt
        @fullscreen = !@fullscreen
        Window.recreate(@fullscreen)
      end
    end

    isolation_index = nil
    i = @states.size - 1
    while i >= 0
      if @states[i].isolate_input == true
        isolation_index = i
        break
      end
      i -= 1
    end

    if isolation_index
      i = isolation_index
      while i < @states.size
        @states[i].input(event)
        i += 1
      end
    else
      @states.each do |state|
        state.input(event)  
      end
    end
  end

  private def update(dt : SF::Time) : Nil
    isolation_index = nil
    i = @states.size - 1
    while i >= 0
      if @states[i].isolate_update == true
        isolation_index = i
        break
      end
      i -= 1
    end

    if isolation_index
      i = isolation_index
      while i < @states.size
        @states[i].update(dt)
        i += 1
      end
    else
      @states.each do |state|
        state.update(dt)
      end
    end
  end
end