require "./unit/background"

class World
  include SF::Drawable

  def initialize
    @background = Background.new
    @enemy_weapons = [] of Unit
    @player_weapons = [] of Unit
    @enemies = [] of Unit
    @environment = [] of Unit

    @units = [] of Unit
    @units << Game.player

    Game.player.position = {Game::WORLD_WIDTH * 0.5f32, Game::WORLD_HEIGHT * 0.75f32}
  end

  def add(unit : Unit) : Nil
    @units << unit
    case unit.type
    when .enemy_weapon?
      @enemy_weapons << unit
    when .player_weapon?
      @player_weapons << unit
    when .enemy?
      @enemies << unit
    when .environment?
      @environment << unit
    else
      raise "Unsupported Unit::Type value: '#{unit.type}'"
    end
  end

  def get(guid : GUID) : Unit?
    @units.find { |unit| unit.guid == guid }
  end

  def get(type : Unit::Type) : Array(Unit)
    case type
    when .enemy_weapon?
      @enemy_weapons
    when .player_weapon?
      @player_weapons
    when .enemy?
      @enemies
    when .environment?
      @environment
    else
      raise "Unsupported Unit::Type value: '#{type}'"
    end
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates) : Nil
    target.draw(@background)
    @enemy_weapons.each { |u| target.draw(u) }
    @player_weapons.each { |u| target.draw(u) }
    @enemies.each { |u| target.draw(u) }
    @environment.each { |u| target.draw(u) }
    target.draw(Game.player) if Game.player.alive
  end

  def update(dt : SF::Time) : Nil
    @environment.each do |u|
      if u.alive && u.position_top >= Game::WORLD_HEIGHT
        u.kill
      end
    end

    @enemies.each do |u|
      if u.alive && u.position_top >= Game::WORLD_HEIGHT
        u.kill
      end
    end

    @enemy_weapons.each do |u|
      if u.alive && u.position_top >= Game::WORLD_HEIGHT
        u.kill
      end
    end

    @player_weapons.each do |u|
      if u.alive && u.position_bottom < 0
        u.kill
      end
    end

    @enemy_weapons.select! { |u| u.alive }
    @player_weapons.select! { |u| u.alive }
    @enemies.select! { |u| u.alive }
    @environment.select! { |u| u.alive }

    @units.select! { |u| u.alive }

    @background.update(dt)
    @units.each { |u| u.update(dt) }
    Game.player.update(dt)

    collision
  end

  def collision : Nil
    i, size = 0, @units.size - 1
    while i <= size
      j = i + 1
      while j <= size
        a, b = @units[i], @units[j]
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
