require "./state"
require "./state_intro"
require "./state_main"
require "./state_menu"
require "./state_warning"

class StateCache
  @@instance : StateCache?

  def self.create : StateCache
    state_cache = StateCache.new
  end

  def self.instance : StateCache
    @@instance ||= create
  end

  def initialize
    @states = {} of State::Type => State
  end

  def [](state : State::Type) : State
    if @states.has_key? state
      @states[state]
    else
      factory(state)
    end
  end

  private def factory(state : State::Type) : State
    case state
    when .intro?
      @states[state] = Intro.new
    when .main?
      @states[state] = Main.new
    when .menu?
      @states[state] = Menu.new
    when .warning?
      @states[state] = Warning.new
    else
      raise "Invalid State::Type value: '#{state}'"
    end
  end
end