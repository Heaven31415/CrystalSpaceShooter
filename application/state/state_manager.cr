require "../config.cr"
require "./game.cr"
require "./loading.cr"
require "./menu.cr"
require "./title.cr"

class StateCache
  def initialize
    @states = {} of State::Type => State
  end

  def [](state_type : State::Type) : State
    if @states.has_key? state_type
      @states[state_type]
    else
      factory(state_type)
    end
  end

  private def factory(state_type : State::Type) : State
    case state_type
    when State::Type::Game
      game = Game.new
      @states[state_type] = game
      game
    when State::Type::Loading
      loading = Loading.new
      @states[state_type] = loading
      loading
    when State::Type::Menu
      menu = Menu.new
      @states[state_type] = menu
      menu
    when State::Type::Title
      title = Title.new
      @states[state_type] = title
      title
    else
      raise "Invalid State::Type value: `#{state_type}`"
    end
  end
end

class StateManager
  def initialize
    @cache = StateCache.new
    @states = [] of State

    @time_per_frame = SF.seconds(1f32 / Config.get("Fps", Float32))
    @clock = SF::Clock.new
    @dt = SF::Time.new
  end

  def push(state_type : State::Type)
    @states.push(@cache[state_type])
  end

  def pop
    @states.pop
  end

  def run
    @clock.restart
    while Window.open? && @states.size != 0
      @dt += @clock.restart
      while @dt >= @time_per_frame
        @dt -= @time_per_frame
        while event = Window.poll_event
          handle_input(event)
        end
        update(@time_per_frame)
        draw(Window.instance)
      end
    end
  end

  private def draw(target : SF::RenderTarget)
    i = @states.size - 1
    while i >= 0
      state = @states[i]
      state.draw(target)
      break if state.isolate_drawing
      i -= 1
    end
  end

  private def handle_input(event : SF::Event)
    @states.each do |state|
      state.handle_input(event)
    end
  end

  private def update(dt : SF::Time)
    @states.each do |state|
      state.update(dt)
    end
  end
end