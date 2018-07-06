{% if flag?(:release) %}
  require "./game.cr"
{% else %}
  require "./game_debug.cr"
{% end %}

game = Game.new
game.run
