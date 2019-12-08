class Intcode
  getter? finished = false

  # This is where we get inputs from
  getter input_channel = Channel(Int32).new

  # This is the next machine that will receive any
  # output, unless it has "finished?"
  property! next_machine : Intcode

  # This is where we send the output, but only if the
  # next machines "finished?" executing code
  property! output_channel : Channel(Int32)

  def initialize(@data : Array(Int32))
    @ip = 0
    @opcode = 0
    @output_value = 0
  end

  def run
    while true
      @opcode = read
      case @opcode % 100
      when 1
        add
      when 2
        multiply
      when 3
        input
      when 4
        output
      when 5
        jump_if_true
      when 6
        jump_if_false
      when 7
        less_than
      when 8
        equals
      when 99
        @finished = true
        break # halt
      else
        raise "Unexpected opcode: #{@opcode}"
      end
    end

    if next_machine.finished?
      output_channel.send @output_value
    end

    @output_value
  end

  private def add
    binary { |x, y| x + y }
  end

  private def multiply
    binary { |x, y| x * y }
  end

  private def input
    @data[read] = input_channel.receive
  end

  private def output
    @output_value = param(0)

    unless next_machine.finished?
      next_machine.input_channel.send @output_value
    end
  end

  private def jump_if_true
    jump_if &.!=(0)
  end

  private def jump_if_false
    jump_if &.==(0)
  end

  private def jump_if
    input1 = param(0)
    input2 = param(1)
    @ip = input2 if yield input1
  end

  private def less_than
    binary { |x, y| x < y ? 1 : 0 }
  end

  private def equals
    binary { |x, y| x == y ? 1 : 0 }
  end

  private def binary
    input1 = param(0)
    input2 = param(1)
    @data[read] = yield input1, input2
  end

  private def param(pos)
    value = read
    mode = (@opcode // (100 * 10**pos)) % 10
    case mode
    when 0 # position mode
      @data[value]
    when 1 # immediate mode
      value
    else
      raise "Unknown mode #{mode} resulting from opcode #{@opcode}, param at pos #{pos}"
    end
  end

  private def read
    @data[@ip].tap { @ip += 1 }
  end
end

code = File
  .read("#{__DIR__}/../inputs/7.txt")
  .split(',')
  .map(&.to_i)

max = (5..9).to_a.each_permutation(reuse: true).max_of do |settings|
  machines = Array.new(5) { |i| Intcode.new(code.dup) }

  # We connect each machine's output to the next machine
  machines.each_with_index do |machine, i|
    machine.next_machine = machines[(i + 1) % 5]
  end

  # Here we'll receive the output of the last machine
  # once machine 0 has finished executing
  result_channel =
    machines[4].output_channel =
      Channel(Int32).new

  # Here we feed each of the machine's input channels.
  # We must do it in separate fibers because `send` is
  # a blocking operation.
  5.times do |i|
    spawn do
      machines[i].input_channel.send settings[i]
      machines[i].input_channel.send 0 if i == 0
    end
  end

  # And now we run each machine on each fiber.
  # This only makes sense when compiling with -Dpreview_mt,
  # at least in Crystal 0.31.1, because there's no IO
  # so if we don't run it with -Dpreview_mt it will be just
  # like the 7.2.cr version, though maybe slower.
  machines.each do |machine|
    spawn machine.run
  end

  result_channel.receive
end
p max
