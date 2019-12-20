require "./intcode"

count = 0

50.times do |x|
  50.times do |y|
    intcode = Intcode(Int32).from_file("#{__DIR__}/../inputs/19.txt")
    intcode.on_output do |value|
      count += 1 if value == 1
    end
    inputs = [x, y]
    intcode.on_input do
      inputs.shift
    end
    intcode.run
  end
end

puts count
