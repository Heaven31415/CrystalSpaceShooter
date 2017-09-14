class TimeCallback
  enum Mode
    Disabled
    Finite
    Infinite
  end
  @time : SF::Time
  @initial_time : SF::Time

  def initialize
    @time = @initial_time = SF::Time::Zero
    @mode = Mode::Disabled
    @count = 0
  end
  
  def add(@time : SF::Time, &block)
    @initial_time = @time
    @callback = block
    @mode = Mode::Infinite
  end

  def add(@time : SF::Time, @count : Int32, &block)
    @initial_time = @time
    @callback = block
    @mode = Mode::Finite
  end

  def add_ending(&block)
    @ending_callback = block
  end

  def update(dt : SF::Time)
    if callback = @callback
      case @mode
        when .finite?
          if @count > 0
            if dt >= @time
              callback.call
              @count -= 1
              @time = @initial_time
            else
              @time -= dt
            end
          else
            if callback = @ending_callback
              callback.call
            end
            @mode = Mode::Disabled
          end
        when .infinite?
          if callback = @callback
            if dt >= @time
              callback.call
              @time = @initial_time
            else
              @time -= dt
            end
        end
      end
    end
  end
end