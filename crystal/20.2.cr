alias Down = Bool
alias Position = {Int32, Int32}
alias Level = Int32

record Portal, name : String, x : Int32, y : Int32,
  horizontal : Bool, before : Bool, down : Down do
  def position
    {x, y}
  end

  def entrance
    if horizontal
      return x + (before ? 1 : -1), y
    else
      return x, y + (before ? 1 : -1)
    end
  end
end

def find_portals(map)
  width = map[0].size
  height = map.size

  portals = Hash(String, Array(Portal)).new do |hash, name|
    hash[name] = Array(Portal).new
  end

  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if 'A' <= cell <= 'Z'
        if x < row.size - 1 && 'A' <= map[y][x + 1] <= 'Z'
          name = "#{cell}#{map[y][x + 1]}"
          if x > 0 && map[y][x - 1] == '.'
            portals[name] << Portal.new(name, x, y,
              horizontal: true, before: false, down: x != width - 2)
          else
            portals[name] << Portal.new(name, x + 1, y,
              horizontal: true, before: true, down: x != 0)
          end
        end
        if y < map.size - 1 && 'A' <= map[y + 1][x] <= 'Z'
          name = "#{cell}#{map[y + 1][x]}"
          if y > 0 && map[y - 1][x] == '.'
            portals[name] << Portal.new(name, x, y,
              horizontal: false, before: false, down: y != height - 2)
          else
            portals[name] << Portal.new(name, x, y + 1,
              horizontal: false, before: true, down: y != 0)
          end
        end
      end
    end
  end

  portals
end

def build_teleports(portals)
  teleports = {} of Position => {Position, Down}

  portals.each do |name, pair|
    next if pair.size != 2

    first, second = pair

    teleports[first.position] = {second.entrance, first.down}
    teleports[second.position] = {first.entrance, second.down}
  end

  teleports
end

map = File
  .read("#{__DIR__}/../inputs/20.txt")
  .lines
  .map(&.chars)

width = map[0].size
height = map.size

portals = find_portals(map)

aa = portals["AA"].first
zz = portals["ZZ"].first

teleports = build_teleports(portals)

seen = Set({Level, Position}).new
pending = [{aa.entrance, 0, 0}]
min_steps = nil

until min_steps
  position, level, steps = pending.shift

  next unless seen.add?({level, position})

  x, y = position

  cell = map[y][x]
  next if cell == '#'

  if 'A' <= cell <= 'Z'
    # Don't teleport if it's AA or ZZ
    next if position == aa.position || (level > 0 && position == zz.position)

    if level == 0 && position == zz.position
      min_steps = steps - 1
      break
    end

    # Teleport!
    next_position, down = teleports[{x, y}]
    next if level == 0 && !down

    pending << {next_position, level + (down ? 1 : -1), steps}
    next
  end

  pending << { {x - 1, y}, level, steps + 1 } if x > 0          # West
  pending << { {x + 1, y}, level, steps + 1 } if x < width - 1  # East
  pending << { {x, y - 1}, level, steps + 1 } if y > 0          # North
  pending << { {x, y + 1}, level, steps + 1 } if y < height - 1 # South
end

puts min_steps
