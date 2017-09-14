{% if flag?(:debug) %}
  require "./game_debug.cr"
{% else %}
  require "./game.cr"
{% end %}

game = Game.new
game.run
