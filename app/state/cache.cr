require "./state"
require "./designer"
require "./game"
require "./loading"
require "./menu"
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
    when State::Type::Designer
      @states[state] = Designer.new
    when State::Type::Game
      @states[state] = Game.new
    when State::Type::Loading
      @states[state] = Loading.new
    when State::Type::Menu
      @states[state] = Menu.new
    when State::Type::Title
      @states[state] = Title.new
    else
      raise "Invalid State::Type enum value: #{state}"
    end
  end
end