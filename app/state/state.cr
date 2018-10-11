require "crsfml/graphics"

abstract class State
  enum Type
    Designer
    Game
    Intro
    Loading
    Menu
    Title
  end

  abstract def initialize
  abstract def draw(target : SF::RenderTarget)
  abstract def handle_input(event : SF::Event)
  abstract def update(dt : SF::Time)

  # todo: implement methods described below,
  # use them to create a cool blur inside game
  # when menu is drawn on it

  # Triggered when state is added to the manager
  abstract def on_load
  # Triggered when state is removed from the manager
  abstract def on_unload

  # If true, only this state and higher states will be drawn
  abstract def isolate_drawing : Bool
  # If true, only this state and higher states will handle input
  abstract def isolate_input : Bool
  # If true, only this state and higher states will be updated
  abstract def isolate_update : Bool
end