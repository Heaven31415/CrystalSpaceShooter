abstract class Widget
  include SF::Drawable

  @active = true
  @visible = true

  property active, visible

  abstract def draw(target : SF::RenderTarget, states : SF::RenderStates)
  abstract def handle_input(event : SF::Event)
  abstract def position() : SF::Vector2f
  abstract def position=(position : SF::Vector2f | Tuple)
end