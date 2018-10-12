require "../world/units/player"

class HUD < SF::RectangleShape
  def initialize(size : SF::Vector2 = SF.vector2(200, 25))
    @back = SF::RectangleShape.new(size)
    @back.fill_color = SF.color(200, 200, 200, 255)
    @back.outline_color = SF.color(40, 20, 20, 255)
    @back.outline_thickness = -3
    @health_percent = 100_f32

    @warning_ready = true
    @warning_cb = TimeCallback.new
    @warning_cb.add(SF.seconds(5)) do
      @warning_ready = true
    end

    @warning2_ready = true
    @warning2_cb = TimeCallback.new
    @warning2_cb.add(SF.seconds(1)) do
      @warning2_ready = true
    end

    super(size)
    self.fill_color = SF.color(190, 60, 60, 255)
    self.outline_color = SF.color(40, 20, 20, 255)
    self.outline_thickness = -3
  end

  def position=(position : SF::Vector2 | Tuple)
    @back.position = position
    super
  end

  def draw(target, states)
    target.draw(@back, states)
    super
  end

  def update(dt : SF::Time) : Nil
    old_health = @health_percent
    @health_percent = App.player.health_percent
    self.size = {@health_percent * @back.size.x / 100.0, @back.size.y}

    if @warning2_ready && @health_percent < old_health 
      App.manager.push(State::Type::Warning)
      @warning2_ready = false
    end

    if @warning_ready && @health_percent < 50f32 && old_health > 50f32
      App.audio.play_sound(Sounds::WARNING50HP)
      @warning_ready = false
    end
    @warning_cb.update(dt)
    @warning2_cb.update(dt)
  end
end
