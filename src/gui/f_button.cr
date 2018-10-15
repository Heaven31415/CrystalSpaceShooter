require "crsfml/graphics"
require "./properties"
require "../../data/sounds"

# todo: rename class from XButton to Button

#
# Button Mandatory Properties:
#
# NormalColor       => SF::Color
# HoverColor        => SF::Color
# Size              => SF::Vector2f
# Layer             => Int32
#
# Origin            => SF::Vector2f | String
# Scale             => SF::Vector2f
# Position          => SF::Vector2f
# Rotation          => Float32
#
# Button Optional Properties:
#
# Texture           => String
# TextureRect       => SF::FloatRect
#
# ClickSound        => String
# ClickSoundVolume  => Float32
# ClickSoundPitch   => Float32
#
# HoverSound        => String
# HoverSoundVolume  => Float32
# HoverSoundPitch   => Float32
#

class XButton < SF::Transformable
  include SF::Drawable

  enum State
    Normal
    Hover
  end

  getter normal_color : SF::Color
  getter hover_color : SF::Color
  getter size : SF::Vector2f
  getter layer : Int32

  @origin : Property

  getter texture : SF::Texture? = nil
  getter texture_rect = SF::FloatRect.new
 
  @click_sound_id = 0
  property click_sound : Sounds? = nil
  property click_sound_volume = 100f32
  property click_sound_pitch = 1f32

  @hover_sound_id = 0
  property hover_sound : Sounds? = nil
  property hover_sound_volume = 100f32
  property hover_sound_pitch = 1f32 

  @vertices = SF::VertexArray.new(SF::Quads, 4)
  @state = State::Normal
  @need_update = false

  def normal_color=(@normal_color : SF::Color)
    @need_update = true
  end

  def hover_color=(@hover_color : SF::Color)
    @need_update = true
  end

  def size=(@size)
    change_size(@size)
    self.origin = update_origin(@origin)
  end

  def layer=(@layer)
  end

  def texture=(@texture)
    if texture = @texture
      size = texture.size
      @texture_rect = SF.float_rect(0f32, 0f32, size.x, size.y)
      change_texture_rect(@texture_rect)
    end
  end

  def texture_rect=(@texture_rect)
    change_texture_rect(@texture_rect)
  end

  def initialize(properties : Properties(Button))
    super()
    @normal_color = properties["NormalColor", SF::Color]
    @hover_color = properties["HoverColor", SF::Color]
    @size = properties["Size", SF::Vector2f]
    @layer = properties["Layer", Int32]

    # Transformation
    @origin = properties["Origin"]
    self.origin = update_origin(@origin)
    self.scale = properties["Scale", SF::Vector2f]
    self.position = properties["Position", SF::Vector2f]
    self.rotation = properties["Rotation", Float32]

    # Texture
    if properties.has_key?("Texture", String)
      @texture = App.resources[properties["Texture", String], SF::Texture]
      if properties.has_key?("TextureRect", SF::FloatRect)
        @texture_rect = properties["TextureRect", SF::FloatRect]
      else
        size = @texture.as(SF::Texture).size
        @texture_rect = SF.float_rect(0f32, 0f32, size.x, size.y)
      end
    end

    # ClickSound
    if properties.has_key?("ClickSound", String)
      if sound = Sounds.parse?(properties["ClickSound", String])
        @click_sound = sound
        if properties.has_key?("ClickSoundVolume", Float32)
          @click_sound_volume = properties["ClickSoundVolume", Float32]
        end

        if properties.has_key?("ClickSoundPitch", Float32)
          @click_sound_pitch = properties["ClickSoundPitch", Float32]
        end
      end
    end

    # HoverSound
    if properties.has_key?("HoverSound", String)
      if sound = Sounds.parse?(properties["HoverSound", String])
        @hover_sound = sound
        if properties.has_key?("HoverSoundVolume", Float32)
          @hover_sound_volume = properties["HoverSoundVolume", Float32]
        end

        if properties.has_key?("HoverSoundPitch", Float32)
          @hover_sound_pitch = properties["HoverSoundPitch", Float32]
        end
      end
    end

    change_geometry(@size, @normal_color, @texture_rect)
  end

  def reinitialize(properties : Properties(Button))
    self.initialize(properties)
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates)
    if @need_update
      case @state
        when .normal?
          change_color(@normal_color)
        when .hover?
          change_color(@hover_color)
      end
      @need_update = false
    end

    states.transform *= transform()
    states.texture = @texture
    target.draw(@vertices, states)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::MouseButtonPressed
      if event.button.left? && inside?(SF.vector2i(event.x, event.y))
        play_click_sound
        click
      end
    when SF::Event::MouseMoved
      if inside?(SF.vector2i(event.x, event.y)) && @state != State::Hover
        play_hover_sound
        @state = State::Hover
        @need_update = true
      elsif !inside?(SF.vector2i(event.x, event.y)) && @state == State::Hover
        @state = State::Normal
        @need_update = true
      end
    end
  end

  def local_bounds : SF::FloatRect
    SF::FloatRect.new(SF::Vector2f.new(0f32, 0f32), @size)
  end

  def global_bounds : SF::FloatRect
    transform().transform_rect(local_bounds())
  end

  def on_click(&block)
    @on_click_callback = block
  end

  private def click
    if callback = @on_click_callback
      callback.call
    end
  end

  private def inside?(position : SF::Vector2i)
    bounds = global_bounds
    position.x >= bounds.left && position.x < bounds.left + bounds.width &&
    position.y >= bounds.top && position.y < bounds.top + bounds.height
  end

  private def play_click_sound
    if (sound = @click_sound) && (App.audio.playing? @click_sound_id) == false
      @click_sound_id = App.audio.play_sound(sound, @click_sound_volume, @click_sound_pitch)
    end
  end

  private def play_hover_sound
    if (sound = @hover_sound) && (App.audio.playing? @hover_sound_id) == false
      @hover_sound_id = App.audio.play_sound(sound, @hover_sound_volume, @hover_sound_pitch)
    end
  end

  private def change_geometry(size : SF::Vector2f, color : SF::Color, tex_rect : SF::FloatRect)
    # Clockwise order
    ul = SF::Vertex.new # upper-left
    ur = SF::Vertex.new # upper-right
    br = SF::Vertex.new # bottom-right
    bl = SF::Vertex.new # bottom-left

    # Size
    width = size.x
    height = size.y

    ul.position = {0f32, 0f32}
    ur.position = {width, 0f32}
    br.position = {width, height}
    bl.position = {0f32, height}

    # Color
    ul.color = color
    ur.color = color
    br.color = color
    bl.color = color

    # Texture coordinates
    left = tex_rect.left
    right = left + tex_rect.width
    top = tex_rect.top
    bottom = top + tex_rect.height

    ul.tex_coords = {left, top}
    ur.tex_coords = {right, top}
    br.tex_coords = {right, bottom}
    bl.tex_coords = {left, bottom}

    @vertices[0] = ul
    @vertices[1] = ur
    @vertices[2] = br
    @vertices[3] = bl
  end

  private def change_size(size : SF::Vector2f)
    # Clockwise order
    ul = @vertices[0] # upper-left
    ur = @vertices[1] # upper-right
    br = @vertices[2] # bottom-right
    bl = @vertices[3] # bottom-left

    width = size.x
    height = size.y

    ul.position = {0f32, 0f32}
    ur.position = {width, 0f32}
    br.position = {width, height}
    bl.position = {0f32, height}

    @vertices[0] = ul
    @vertices[1] = ur
    @vertices[2] = br
    @vertices[3] = bl
  end

  private def change_color(color : SF::Color)
    # Clockwise order
    ul = @vertices[0] # upper-left
    ur = @vertices[1] # upper-right
    br = @vertices[2] # bottom-right
    bl = @vertices[3] # bottom-left

    ul.color = color
    ur.color = color
    br.color = color
    bl.color = color

    @vertices[0] = ul
    @vertices[1] = ur
    @vertices[2] = br
    @vertices[3] = bl
  end

  private def change_texture_rect(tex_rect : SF::FloatRect)
    # Clockwise order
    ul = @vertices[0] # upper-left
    ur = @vertices[1] # upper-right
    br = @vertices[2] # bottom-right
    bl = @vertices[3] # bottom-left

    # Texture coordinates
    left = tex_rect.left
    right = left + tex_rect.width
    top = tex_rect.top
    bottom = top + tex_rect.height

    ul.tex_coords = {left, top}
    ur.tex_coords = {right, top}
    br.tex_coords = {right, bottom}
    bl.tex_coords = {left, bottom}

    @vertices[0] = ul
    @vertices[1] = ur
    @vertices[2] = br
    @vertices[3] = bl
  end

  private def update_origin(origin) : SF::Vector2f
    case origin
    when String
      case origin
      when "Center"
        bounds = local_bounds()
        SF.vector2f(bounds.left + bounds.width / 2f32, bounds.top + bounds.height / 2f32)
      else
        raise "Invalid origin value: `#{origin}`"
      end
    when SF::Vector2f
      origin
    else
      raise "Invalid origin type: `#{origin.class}`"
    end
  end
end