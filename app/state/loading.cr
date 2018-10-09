require "./state"
require "./manager"

class Loading < State
  def initialize
  end

  def draw(target : SF::RenderTarget)
  end

  def handle_input(event : SF::Event)
  end

  def update(dt : SF::Time)
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

  def on_load
    puts "Loaded: #{self}"
  end

  def on_unload
    puts "Unloaded: #{self}"
  end
end