require "./intcode"

def run_intcode(address, channels, result)
  intcode = Intcode(Int64).from_file("#{__DIR__}/../inputs/23.txt")

  intcode.on_input do
    select
    when value = channels[address].receive
    # puts "#{address}) got input: #{value}"
      value
    else
      Fiber.yield
      -1_i64
    end
  end

  outputs = [] of Int64

  intcode.on_output do |value|
    outputs << value
    if outputs.size == 3
      target_address, x, y = outputs
      outputs.clear

      if target_address == 255
        result.send(y)
        next
      end

      # puts "#{address}) sending to #{target_address}: #{x}, #{y}"

      target_channel = channels[target_address]
      target_channel.send(x)
      target_channel.send(y)
    else
      Fiber.yield
    end
  end
  intcode.run
end

channels = Array.new(50) { Channel(Int64).new(100) }
channels.each_with_index do |channel, address|
  channel.send(address.to_i64)
end

result = Channel(Int64).new

50.times do |address|
  spawn run_intcode address, channels, result
end

puts result.receive
