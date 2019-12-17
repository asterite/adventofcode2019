require "./intcode"

enum Direction
  North
  East
  South
  West
end

def find_robot(map)
  x = nil
  y = nil
  direction = nil

  map.each_with_index do |row, map_y|
    row.each_with_index do |char, map_x|
      case char
      when '^'
        x, y, direction = map_x, map_y, Direction::North
      when '>'
        x, y, direction = map_x, map_y, Direction::East
      when 'v'
        x, y, direction = map_x, map_y, Direction::South
      when '<'
        x, y, direction = map_x, map_y, Direction::West
      end
    end
  end

  unless x && y && direction
    raise "Couldn't find robot :-("
  end

  {x, y, direction}
end

def chunk_length(chunk)
  chunk.sum { |text| text.bytesize + 1 } + chunk.size - 1
end

def find_chunk_sequence(pieces)
  (1..pieces.size - 2).each do |sizeA|
    (1..(pieces.size - sizeA - 1)).each do |sizeB|
      (1..(pieces.size - sizeA - sizeB)).each do |sizeC|
        main = ['A']
        chunkA = pieces[0, sizeA]
        chunkB = nil
        chunkC = nil
        start = sizeA
        match = true
        while start < pieces.size
          if pieces[start, sizeA] == chunkA
            main << 'A'
            start += sizeA
          elsif chunkB && pieces[start, sizeB] == chunkB
            main << 'B'
            start += sizeB
          elsif !chunkB && start + sizeB <= pieces.size &&
                (tempChunkB = pieces[start, sizeB]) &&
                chunk_length(tempChunkB) <= 20
            chunkB = tempChunkB
            main << 'B'
            start += sizeB
          elsif chunkC && pieces[start, sizeC] == chunkC
            main << 'C'
            start += sizeC
          elsif !chunkC && start + sizeC <= pieces.size &&
                (tempChunkC = pieces[start, sizeC]) &&
                chunk_length(tempChunkC) <= 20
            chunkC = tempChunkC
            main << 'C'
            start += sizeC
          else
            match = false
            break
          end
        end

        if match && chunkA && chunkB && chunkC
          return main, chunkA, chunkB, chunkC
        end
      end
    end
  end

  nil
end

map = String.build do |str|
  intcode = Intcode(Int32).from_file("#{__DIR__}/../inputs/17.txt")
  intcode.on_output do |value|
    str << value.chr
  end
  intcode.run
end

map = map.strip.lines.map &.chars

height = map.size
width = map[0].size
x, y, direction = find_robot(map)
output = IO::Memory.new

while true
  case direction
  when .north?
    if x > 0 && map[y][x - 1] == '#' # Check west
      direction = Direction::West
      output << ',' unless output.empty?
      output << 'L'
    elsif x < width - 1 && map[y][x + 1] == '#' # Check east
      direction = Direction::East
      output << ',' unless output.empty?
      output << 'R'
    else
      break
    end
  when .south?
    if x > 0 && map[y][x - 1] == '#' # Check west
      direction = Direction::West
      output << ',' unless output.empty?
      output << 'R'
    elsif x < width - 1 && map[y][x + 1] == '#' # Check east
      direction = Direction::East
      output << ',' unless output.empty?
      output << 'L'
    else
      break
    end
  when .east?
    if y > 0 && map[y - 1][x] == '#' # Check north
      direction = Direction::North
      output << ',' unless output.empty?
      output << 'L'
    elsif y < height - 1 && map[y + 1][x] == '#' # Check south
      direction = Direction::South
      output << ',' unless output.empty?
      output << 'R'
    else
      break
    end
  when .west?
    if y > 0 && map[y - 1][x] == '#' # Check north
      direction = Direction::North
      output << ',' unless output.empty?
      output << 'R'
    elsif y < height - 1 && map[y + 1][x] == '#' # Check south
      direction = Direction::South
      output << ',' unless output.empty?
      output << 'L'
    else
      break
    end
  end

  count = 0
  case direction
  when .north?
    while y > 0 && map[y - 1][x] == '#'
      y -= 1
      count += 1
    end
  when .south?
    while y < height - 1 && map[y + 1][x] == '#'
      y += 1
      count += 1
    end
  when .west?
    while x > 0 && map[y][x - 1] == '#'
      x -= 1
      count += 1
    end
  when .east?
    while x < width - 1 && map[y][x + 1] == '#'
      x += 1
      count += 1
    end
  end

  output << count
  break if count == 0
end

puts output.to_s

pieces = output.to_s.split(',')

sequence = find_chunk_sequence(pieces)
unless sequence
  raise "Couldn't find a way to chunk it! :-("
end

main, a, b, c = sequence

lines = [main.join(',')]

[a, b, c].each do |seq|
  lines << seq.map { |text| "#{text[0]},#{text[1..]}" }.join(',')
end

lines << "n"

inputs = [] of Int32
lines.each do |line|
  line.each_char do |char|
    inputs << char.ord
  end
  inputs << '\n'.ord
end

last = nil

intcode = Intcode(Int32).from_file("#{__DIR__}/../inputs/17.txt") do |data|
  data[0] = 2
end
intcode.on_output do |value|
  last = value
  chr = value.chr rescue nil
  print chr if chr
end
intcode.on_input do
  v = inputs.shift
  puts "Sending: #{v}"
  v
end
intcode.run

print last
