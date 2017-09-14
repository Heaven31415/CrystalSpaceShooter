class Pair(T1, T2)
  property first, second

  def initialize(@first : T1, @second : T2)
  end
end

module Math
  def self.cartesian_to_polar(x : Number, y : Number)
    {radius: Math.hypot(x, y), angle: Math.atan2(y, x)}
  end

  def self.polar_to_cartesian(radius : Number, angle : Number)
    {x: radius * Math.cos(angle), y: radius * Math.sin(angle)}
  end
end
