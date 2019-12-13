require "../../intcode"

map = {} of {Int64, Int64} => Int64

intcode = Intcode.from_file("#{__DIR__}/../../../inputs/13.txt")

outputs = [] of Int64
intcode.on_output do |value|
  outputs << value
  if outputs.size == 3
    x, y, tile_id = outputs
    outputs.clear
    map[{x, y}] = tile_id
  end
end

intcode.run

p map.values.count(2)
