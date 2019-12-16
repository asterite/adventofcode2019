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
steps = { {0, 0} => 0 }

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
        new_steps = steps[{prev_x, prev_y}] + 1

        # If we have an existing step count in the new position,
        # only update it if the new steps are lower
        if existing_steps = steps[{x, y}]?
          if new_steps < existing_steps
            steps[{x, y}] = new_steps
          else
            next
          end
        else
          # Otherwise, it's the first time we step on this position
          steps[{x, y}] = new_steps
        end

        # Once we find the oxygen system we know where it is.
        # We still need to traverse all existing directions
        # because we might arrive here later with fewer steps.
        if value == 2
          oxygen_system_location = {x, y}
          next
        end

        # Continue try all directions, except if a next location
        # has less steps than what we have so far
        Direction.each do |new_direction|
          new_x, new_y = apply_direction x, y, new_direction
          existing_steps = steps[{new_x, new_y}]?
          unless existing_steps && existing_steps <= new_steps + 1
            pending_directions << directions + [new_direction]
          end
        end
      end
    end
  end
  intcode.run
end

puts steps[oxygen_system_location.not_nil!]
