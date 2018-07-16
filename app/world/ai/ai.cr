require "weak_ref"

abstract class AI
  abstract def initialize(unit : Unit)
  abstract def think(dt : SF::Time)
  private abstract def _think(me : Unit, dt : SF::Time)
end
