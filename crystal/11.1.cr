require "./intcode"

BLACK      = 0
WHITE      = 1
DIRECTIONS = [
  {0, -1},
  {1, 0},
  {0, 1},
  {-1, 0},
]
TURN_LEFT  = 0
TURN_RIGHT = 1

alias Position = {Int32, Int32}
alias Color = Int32

data = File
  .read("#{__DIR__}/../inputs/11.txt")
  .split(',')
  .map(&.to_i64)

pos = {0, 0}
map = Hash({Int32, Int32}, Color).new(BLACK)
direction_index = 0 # up

intcode = Intcode.new(data)
intcode.on_input do
  map[pos].to_i64
end

first_output = true
intcode.on_output do |value|
  if first_output
    map[pos] = value.to_i32
  else
    direction_index +=
      case value
      when TURN_LEFT  then -1
      when TURN_RIGHT then 1
      else                 raise "unexpected turn command: #{value}"
      end
    direction_index %= DIRECTIONS.size
    direction = DIRECTIONS[direction_index]
    pos = {pos[0] + direction[0], pos[1] + direction[1]}
  end
  first_output = !first_output
end
intcode.run

puts map.size