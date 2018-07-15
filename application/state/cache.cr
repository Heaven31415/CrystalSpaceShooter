require "./state.cr"
require "./game.cr"
require "./loading.cr"
require "./menu.cr"
require "./title.cr"

class Cache
  @@states : Hash(State::Type, State)? = nil

  def self.load
    @@states = Hash(State::Type, State).new
    if states = @@states
      states[State::Type::Game] = Game.new
      states[State::Type::Loading] = Loading.new
      states[State::Type::Menu] = Menu.new
      states[State::Type::Title] = Title.new
    end
  end

  def self.get(state : State::Type) : State
    if states = @@states
      states[state]
    else
      raise "Unable to call #{self}.get on uninitialized #{self}"
    end
  end 
end