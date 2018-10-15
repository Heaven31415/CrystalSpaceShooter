require "weak_ref"

abstract class AI
  abstract def initialize(unit : Unit)
  abstract def on_update(dt : SF::Time)
end
