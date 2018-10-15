require "../world/unit/player"

class HUD < SF::RectangleShape
  def initialize(size : SF::Vector2)
    @back = SF::RectangleShape.new(size)
    @back.fill_color = SF.color(200, 200, 200, 255)
    @back.outline_color = SF.color(40, 20, 20, 255)
    @back.outline_thickness = -3

    @health_percent = 100f32

    @health_below_50_warning_ready = true
    @health_below_50_warning_ready_callback = TimeCallback.new
    @health_below_50_warning_ready_callback.add(SF.seconds(5)) do
      @health_below_50_warning_ready = true
    end

    @damage_taken_warning_ready = true
    @damage_taken_warning_ready_callback = TimeCallback.new
    @damage_taken_warning_ready_callback.add(SF.seconds(1)) do
      @damage_taken_warning_ready = true
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

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    target.draw(@back, states)
    super
  end

  def update(dt : SF::Time) : Nil
    old_health = @health_percent
    @health_percent = Game.player.health_percent
    self.size = {@health_percent * @back.size.x / 100.0, @back.size.y}

    if @damage_taken_warning_ready && @health_percent < old_health 
      Game.manager.push(State::Type::Warning)
      @damage_taken_warning_ready = false
    end

    if @health_below_50_warning_ready && @health_percent < 50f32 && old_health > 50f32
      Game.audio.play_sound(Resource::Sound::WARNING50HP)
      @health_below_50_warning_ready = false
    end
    
    @damage_taken_warning_ready_callback.update(dt)
    @health_below_50_warning_ready_callback.update(dt)
  end
end
