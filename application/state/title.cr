require "./state.cr"

class Title < State
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
end