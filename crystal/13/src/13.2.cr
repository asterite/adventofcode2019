require "../../intcode"

enum Tile
  Empty  = 0
  Wall   = 1
  Block  = 2
  Paddle = 3
  Ball   = 4
end

map = Hash({Int64, Int64}, Tile).new(:empty)

data = Intcode.parse(File.read("#{__DIR__}/../../../inputs/13.txt"))
data[0] = 2

intcode = Intcode.new(data)
intcode.on_input do
  ball_x = map.find { |xy, tile| tile.ball? }.not_nil![0][0]
  paddle_x = map.find { |xy, tile| tile.paddle? }.not_nil![0][0]
  if paddle_x == ball_x
    0_i64
  elsif paddle_x < ball_x
    1_i64
  else
    -1_i64
  end
end

score = 0_i64

outputs = [] of Int64
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
