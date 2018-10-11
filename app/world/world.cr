require "./units/background"

class World
  include SF::Drawable

  def initialize
    @background = Background.new
    @enemy_weapons = [] of Unit
    @player_weapons = [] of Unit
    @enemies = [] of Unit

    App.player.position = {App.render_size.x * 0.5f32, App.render_size.y * 0.75f32}
  end

  def add(unit : Unit) : Nil
    case unit.type
    when .enemy_weapon?
      @enemy_weapons << unit
    when .player_weapon?
      @player_weapons << unit
    when .enemy?
      @enemies << unit
    else
      raise "Unsupported Unit::Type value: `#{unit.type}`"
    end
  end

  def get(type : Unit::Type) : Array(Unit)
    case type
    when .enemy_weapon?
      @enemy_weapons
    when .player_weapon?
      @player_weapons
    when .enemy?
      @enemies
    else
      raise "Unsupported Unit::Type value: `#{type}`"
    end
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    target.draw(@background)
    @enemy_weapons.each { |u| target.draw(u) }
    @player_weapons.each { |u| target.draw(u) }
    @enemies.each { |u| target.draw(u) }
    target.draw(App.player) if App.player.alive
  end

  def update(dt : SF::Time) : Nil
    @enemies.each do |u|
      if u.alive && u.position_top >= App.render_size.y
        u.kill
      end
    end

    @enemy_weapons.each do |u|
      if u.alive && u.position_top >= App.render_size.y
        u.kill
      end
    end

    @player_weapons.each do |u|
      if u.alive && u.position_bottom < 0
        u.kill
      end
    end

    @enemies.select! { |u| u.alive }
    @enemy_weapons.select! { |u| u.alive }
    @player_weapons.select! { |u| u.alive }

    @background.update(dt)
    @enemies.each { |u| u.update(dt) }
    @enemy_weapons.each { |u| u.update(dt) }
    @player_weapons.each { |u| u.update(dt) }
    App.player.update(dt)

    collision
  end

  def collision
    units = @enemies + @enemy_weapons + @player_weapons + [App.player]

    i, size = 0, units.size - 1
    while i <= size
      j = i + 1
      while j <= size
        a, b = units[i], units[j]
        if a.alive && b.alive
          if a.hostile?(b) && a.close?(b)
            a.on_collision(b)
            b.on_collision(a)
          end
        end
        j += 1
      end
      i += 1
    end
  end
end
