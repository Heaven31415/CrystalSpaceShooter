require "./state.cr"

class Menu < State
  def initialize
  end

  def draw(target : SF::RenderTarget)
  end

  def handle_input(event : SF::Event)
  end

  def update(dt : SF::Time)
  end

  def isolate_drawing : Bool
    false
  end

  def isolate_input : Bool
    true
  end
end