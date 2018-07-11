require "../common/time_callback.cr"
require "../units/*"

class World
  def initialize
    @player = Player.new
    @player.position = {Config.window_size.x * 0.5, Config.window_size.y * 0.75}

    @units = [] of Unit
    @units.push(@player)
    @units.push(Background.new)
  end

  def player
    @player
  end

  def add(unit : Unit)
    @units.push(unit)
  end

  def get
    @units
  end

  def get(predicate : Proc(Unit, Bool))
    @units.select { |u| predicate.call(u) }
  end

  def handle_input(event : SF::Event)
    @player.handle_input(event)
  end

  def render(target : SF::RenderTarget)
    @units.sort!
    @units.each { |u| target.draw(u) }
  end

  def update(dt : SF::Time)
    @units.each do |u|
      if u.alive
        case u.type
        when Unit::Type::Enemy, Unit::Type::EnemyWeapon
          if u.position_top >= Config.window_size.y
            u.kill
          end
        when Unit::Type::PlayerWeapon
          if u.position_bottom < 0
            u.kill
          end
        end
      end
    end
    @units.select! { |u| u.alive }
    @units.each { |u| u.update(dt) }
    collision
  end

  def collision
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

  def to_s(io)
    world_information = "World Information (##{@units.size}):\n"
    @units.each do |u|
      world_information += "#{u.class}|\n"
    end
    io << world_information
  end
end
