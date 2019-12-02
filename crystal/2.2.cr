original_data = File
  .read("#{__DIR__}/../inputs/2.txt")
  .split(',')
  .map(&.to_i)

(0..99).each do |noun|
  (0..99).each do |verb|
    output = intcode(original_data.dup, noun, verb)
    if output == 19690720
      puts 100 * noun + verb
      exit
    end
  end
end

def intcode(data, noun, verb)
  data[1] = noun
  data[2] = verb

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

  data[0]
end
