require "./cache.cr"

class Manager
  @@states : Array(State)? = nil

  def self.load
    @@states = Array(State).new
    if states = @@states
      states.push(Cache.get(State::Type::Game))
    end
  end

  def self.empty? : Bool
    if states = @@states
      states.size == 0
    else
      raise "Unable to call #{self}.empty? on uninitialized #{self}"
    end
  end

  def self.push(state : State::Type)
    if states = @@states
      states.push(Cache.get(state))
    else
      raise "Unable to call #{self}.push on uninitialized #{self}"
    end
  end

  def self.draw(target : SF::RenderTarget)
    if states = @@states
      target.clear
      
      states.each do |state|
        state.draw(target)
      end

      target.display
    else
      raise "Unable to call #{self}.draw on uninitialized #{self}"
    end
  end

  def self.handle_input(event : SF::Event)
    if states = @@states
      states.each do |state|
        state.handle_input(event)
      end
    else
      raise "Unable to call #{self}.handle_input on uninitialized #{self}"
    end
  end

  def self.update(dt : SF::Time)
    if states = @@states
      states.each do |state|
        state.update(dt)
      end
    else
      raise "Unable to call #{self}.update on uninitialized #{self}"
    end
  end
end