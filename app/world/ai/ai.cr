require "weak_ref"

abstract class AI
  abstract def initialize(unit : Unit)
  abstract def update(dt : SF::Time)
end
