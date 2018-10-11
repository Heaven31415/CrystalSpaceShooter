require "./designer"
require "./game"
require "./intro"
require "./loading"
require "./menu"
require "./state"
require "./title"

class Cache
  @@instance : Cache?

  def self.create : Cache
    cache = Cache.new
  end

  def self.instance : Cache
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
    # when State::Type::Designer
    #   @states[state] = Designer.new
    when .game?
      @states[state] = Game.new
    when .intro?
      @states[state] = Intro.new
    when .loading?
      @states[state] = Loading.new
    when .menu?
      @states[state] = Menu.new
    when .title?
      @states[state] = Title.new
    else
      raise "Invalid State::Type value: #{state}"
    end
  end
end