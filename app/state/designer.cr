require "./state.cr"
require "./manager.cr"

class Designer < State
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
end