wires = File
  .read("#{__DIR__}/../inputs/3.txt")
  .lines
  .map do |line|
    line.split(",").map do |movement|
      {movement[0], movement[1..].to_i}
    end
  end

grid = {} of {Int32, Int32} => Int32
minimum = nil

wires.each_with_index do |wire, wire_index|
  pos = {0, 0}
  steps = 0
  wire.each do |direction, amount|
    dx = 0
    dy = 0
    case direction
    when 'U' then dy = 1
    when 'D' then dy = -1
    when 'L' then dx = -1
    when 'R' then dx = 1
    else          raise "Unexpected direction: #{direction}"
    end

    amount.times do
      steps += 1
      pos = {pos[0] + dx, pos[1] + dy}
      distance = pos.sum(&.abs)
      if wire_index == 0
        grid[pos] ||= steps
      elsif pos != {0, 0} && (first_wire_steps = grid[pos]?) &&
            (!minimum || first_wire_steps + steps < minimum)
        minimum = first_wire_steps + steps
      end
    end
  end
end

puts minimum
