require "../../intcode"

enum Tile
  Empty  = 0
  Wall   = 1
  Block  = 2
  Paddle = 3
  Ball   = 4
end

map = Hash({Int32, Int32}, Tile).new(:empty)

data = Intcode(Int32).parse(File.read("#{__DIR__}/../../../inputs/13.txt"))
data[0] = 2

intcode = Intcode.new(data)
intcode.on_input do
  ball_x = map.find { |xy, tile| tile.ball? }.not_nil![0][0]
  paddle_x = map.find { |xy, tile| tile.paddle? }.not_nil![0][0]
  if paddle_x == ball_x
    0
  elsif paddle_x < ball_x
    1
  else
    -1
  end
end

score = 0

outputs = [] of Int32
intcode.on_output do |value|
  outputs << value
  if outputs.size == 3
    x, y, tile_id = outputs
    outputs.clear

    if x == -1 && y == 0
      score = tile_id
    else
      map[{x, y}] = Tile.new(tile_id.to_i)
    end
  end
end

intcode.run

if map.values.count(&.block?)
  puts score
else
  puts "Oops! I couldn't destroy all blocks :-("
end
