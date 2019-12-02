data = File
  .read("#{__DIR__}/../inputs/2.txt")
  .split(',')
  .map(&.to_i)

data[1] = 12
data[2] = 2

pos = 0
while true
  opcode = data[pos]
  case opcode
  when 1, 2
    input1 = data[data[pos + 1]]
    input2 = data[data[pos + 2]]
    data[data[pos + 3]] = opcode == 1 ? input1 + input2 : input1 * input2
    pos += 4
  when 99
    break
  else
    raise "unexpected opcode: #{opcode}"
  end
end

puts data[0]
