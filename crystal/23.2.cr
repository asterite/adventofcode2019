require "./intcode"

def run_intcode(address, channels, sizes, nat, mutex)
  intcode = Intcode(Int64).from_file("#{__DIR__}/../inputs/23.txt")

  intcode.on_input do
    select
    when value = channels[address].receive
      mutex.synchronize { sizes[address] -= 1 }
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
        nat.send({x, y})
        next
      end

      mutex.synchronize { sizes[target_address] += 2 }

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

sizes = Array.new(50, 1)
mutex = Mutex.new

nat_package = nil
nat = Channel({Int64, Int64}).new(100)

seen = Set(Int64).new

50.times do |address|
  spawn run_intcode address, channels, sizes, nat, mutex
end

spawn do
  loop do
    nat_package = nat.receive
  end
end

loop do
  sleep(0.01)

  mutex.synchronize do
    if nat_package && sizes.all? &.==(0)
      x, y = nat_package.not_nil!
      nat_package = nil

      # puts y
      unless seen.add?(y)
        puts y
        exit
      end

      sizes[0] += 2

      channels[0].send(x)
      channels[0].send(y)
    end
  end
end
