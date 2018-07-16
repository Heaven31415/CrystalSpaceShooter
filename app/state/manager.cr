require "./cache.cr"

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
    @time_per_frame = SF.seconds(1.0 / App.config["Fps", Float32])
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def push(state : State::Type)
    @states.push(App.cache[state])
  end

  def pop
    @states.pop
  end

  def run
    @clock.restart

    while App.window.open? && @states.size != 0
      @dt += @clock.restart
      while @dt >= @time_per_frame
        while event = App.window.poll_event
          handle_input(event)
        end

        update(@time_per_frame)
        render(App.window)

        @dt -= @time_per_frame
      end
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