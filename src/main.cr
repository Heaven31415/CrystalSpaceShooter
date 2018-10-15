require "./game"

begin
  game = Game.new
  game.run
rescue exception : Exception
  puts exception
end