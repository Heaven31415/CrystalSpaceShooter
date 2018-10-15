require "crsfml/graphics"

abstract class State
  # TODO: Figure out whether it is possible to get rid of this.
  enum Type
    Intro
    Main
    Menu
    Warning
  end

  abstract def draw(target : SF::RenderTarget) : Nil
  abstract def input(event : SF::Event) : Nil
  abstract def update(dt : SF::Time) : Nil

  # Triggered when this state is added to the StateManager.
  abstract def on_load : Nil
  # Triggered when this state is removed from the StateManager.
  abstract def on_unload : Nil

  # If true, only this state and higher states will be drawn.
  abstract def isolate_drawing : Bool
  # If true, only this state and higher states will handle input.
  abstract def isolate_input : Bool
  # If true, only this state and higher states will be updated.
  abstract def isolate_update : Bool
end