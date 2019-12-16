require "./intcode"

enum Direction
  North = 1
  South = 2
  West  = 3
  East  = 4
end

def apply_direction(x, y, direction)
  case direction
  when .north? then y -= 1
  when .south? then y += 1
  when .west?  then x -= 1
  when .east?  then x += 1
  end

  {x, y}
end

# Pending series of directions we need to traverse to find
# the oxygen system. We start by looking at all directions.
pending_directions = [
  [Direction::North],
  [Direction::South],
  [Direction::East],
  [Direction::West],
]

# Parse the intcode data once
data = Intcode(Int32).parse(File.read("#{__DIR__}/../inputs/15.txt"))

# Number of minimum steps we need to reach each point
map = Set{ {0, 0} }

# The location where the oxygen system is
oxygen_system_location = nil

until pending_directions.empty?
  # Get a pending direction
  directions = pending_directions.pop

  # We always follow the directions on a fresh Intcode
  # machine from the start
  x = y = 0

  # This is the last direction we've taken
  directions_index = 0

  intcode = Intcode.new(data)
  intcode.on_input do
    # Return the next direction to follow
    directions[directions_index].to_i.tap do
      directions_index += 1
    end
  end
  intcode.on_output do |value|
    # Once we traversed all the current directions we are done
    # with this intcode machine
    if directions_index == directions.size
      intcode.stop
    end

    case value
    when 0
      # Wall, nothing to do
    when 1, 2
      # Space or oxygen system
      prev_x, prev_y = x, y

      # Move a step
      x, y = apply_direction x, y, directions[directions_index - 1]

      # If we consumed all directions, compute minimum steps
      if directions_index == directions.size
        map << {x, y}

        # Once we find the oxygen system we know where it is.
        if value == 2
          oxygen_system_location = {x, y}
        end

        # Continue try all directions, except if we saw that new location
        Direction.each do |new_direction|
          new_x, new_y = apply_direction x, y, new_direction
          unless map.includes?({new_x, new_y})
            pending_directions << directions + [new_direction]
          end
        end
      end
    end
  end
  intcode.run
end

start = oxygen_system_location.not_nil!

# Which spaces we filled with oxygen, and how many minutes it took for it
filled = {start => 0}

# The locations we must still fill with oxygen, and how many minutes
# it will take to reach them
pending_locations = [{start, 0}]

until pending_locations.empty?
  location, minutes = pending_locations.pop

  # Spread air to all directions that are in the map and don't have
  # oxygen yet.
  Direction.each do |direction|
    new_location = apply_direction(*location, direction)
    if map.includes?(new_location) && !filled.has_key?(new_location)
      filled[new_location] = minutes + 1
      pending_locations << {new_location, minutes + 1}
    end
  end
end

# The total time is the maximum of all locations
puts filled.values.max
