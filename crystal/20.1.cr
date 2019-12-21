alias Position = {Int32, Int32}

record Portal, x : Int32, y : Int32, horizontal : Bool, before : Bool do
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
  portals = Hash(String, Array(Portal)).new do |hash, name|
    hash[name] = Array(Portal).new
  end

  map.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if 'A' <= cell <= 'Z'
        if x < row.size - 1 && 'A' <= map[y][x + 1] <= 'Z'
          name = "#{cell}#{map[y][x + 1]}"
          if x > 0 && map[y][x - 1] == '.'
            portals[name] << Portal.new(x, y, horizontal: true, before: false)
          else
            portals[name] << Portal.new(x + 1, y, horizontal: true, before: true)
          end
        end
        if y < map.size - 1 && 'A' <= map[y + 1][x] <= 'Z'
          name = "#{cell}#{map[y + 1][x]}"
          if y > 0 && map[y - 1][x] == '.'
            portals[name] << Portal.new(x, y, horizontal: false, before: false)
          else
            portals[name] << Portal.new(x, y + 1, horizontal: false, before: true)
          end
        end
      end
    end
  end

  portals
end

def build_teleports(portals)
  teleports = {} of Position => Position

  portals.each do |name, pair|
    next if pair.size != 2

    first, second = pair

    teleports[first.position] = second.entrance
    teleports[second.position] = first.entrance
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

seen = Set(Position).new
pending = [{aa.entrance, 0}]
min_steps = nil

until min_steps
  position, steps = pending.shift

  next unless seen.add?(position)

  seen << position

  x, y = position

  cell = map[y][x]
  next if cell == '#'

  if 'A' <= cell <= 'Z'
    # Don't teleport if it's AA
    next if position == aa.position

    # Stop if we found ZZ
    if position == zz.position
      min_steps = steps - 1
      break
    end

    # Teleport!
    pending << {teleports[{x, y}], steps}
    next
  end

  pending << { {x - 1, y}, steps + 1 } if x > 0          # West
  pending << { {x + 1, y}, steps + 1 } if x < width - 1  # East
  pending << { {x, y - 1}, steps + 1 } if y > 0          # North
  pending << { {x, y + 1}, steps + 1 } if y < height - 1 # South
end

puts min_steps
