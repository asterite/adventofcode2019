require "./intcode"

map = String.build do |str|
  intcode = Intcode(Int32).from_file("#{__DIR__}/../inputs/17.txt")
  intcode.on_output do |value|
    str << value.chr
  end
  intcode.run
end

map = map.strip.lines.map &.chars

count = (1..map.size - 2).sum do |y|
  (1..map[y].size - 2).sum do |x|
    if map[y][x] == '#' &&
       map[y - 1][x] == '#' && map[y + 1][x] == '#' &&
       map[y][x - 1] == '#' && map[y][x + 1] == '#'
      (x * y)
    else
      0
    end
  end
end

puts count
