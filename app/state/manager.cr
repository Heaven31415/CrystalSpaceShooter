require "./cache"

class Manager
  @@instance : Manager?

  def self.create : Manager
    manager = Manager.new
    manager
  end

  def self.instance : Manager
    @@instance ||= create
  end

  def initialize
    @states = [] of State
    @requests = [] of State::Type?
    @time_per_frame = SF.seconds(1.0 / App.config["Fps", Float32])
    @clock = SF::Clock.new
    @dt = SF::Time.new

    w = App.config["RenderWidth", Int32]
    h = App.config["RenderHeight", Int32]
    @texture = SF::RenderTexture.new(w, h)
  end

  def state : State::Type?
    return nil if @states.size == 0

    case @states[@states.size - 1]
      # when Designer
      #   State::Type::Designer
      when Game
        State::Type::Game
      when Intro
        State::Type::Intro
      when Loading
        State::Type::Loading
      when Menu
        State::Type::Menu
      when Title
        State::Type::Title
      when Warning
        State::Type::Warning
      else
        nil
      end
  end

  def push(state : State::Type)
    @requests.push(state)
  end

  def pop
    @requests.push(nil)
  end

  private def process_requests
    @requests.reverse!
    while @requests.size != 0
      request = @requests.pop
      case request
      when State::Type
        state = App.cache[request]
        state.on_load
        @states.push(state)
      when Nil
        state = @states.pop
        state.on_unload
      end
    end
  end

  def run
    process_requests
    @clock.restart

    window = App.window

    while window.open? && @states.size != 0
      @dt += @clock.restart
      while @dt >= @time_per_frame
        while event = window.poll_event
          handle_input(event)
        end

        update(@time_per_frame)
        process_requests

        @dt -= @time_per_frame
      end

      render(@texture)

      w = window.size.x / App.config["RenderWidth", Int32].to_f32
      h = window.size.y / App.config["RenderHeight", Int32].to_f32
      scale = {w, h}

      window.clear
      sprite = SF::Sprite.new(@texture.texture)
      sprite.scale = scale
      window.draw(sprite)
      window.display
    end
  end

  private def render(target : SF::RenderTarget)
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

  private def handle_input(event : SF::Event)
    # special-case
    if event.is_a? SF::Event::KeyPressed
      if event.code == SF::Keyboard::Return && event.alt
        App.fullscreen = !App.fullscreen
        Window.recreate
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
        @states[i].handle_input(event)
        i += 1
      end
    else
      @states.each do |state|
        state.handle_input(event)  
      end
    end
  end

  private def update(dt : SF::Time)
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