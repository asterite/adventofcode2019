class Intcode
  getter? finished = false
  getter inputs
  getter output_value

  def initialize(@data : Array(Int32), @inputs : Array(Int32))
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
        break
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
    @output_value
  end

  private def add
    binary { |x, y| x + y }
  end

  private def multiply
    binary { |x, y| x * y }
  end

  private def input
    @data[read] = @inputs.shift
  end

  private def output
    @output_value = param(0)
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
  machines = settings.map_with_index do |setting, i|
    Intcode.new(code.dup, [setting])
  end

  machines[0].inputs << 0

  until machines.all? &.finished?
    5.times do |i|
      machines[(i + 1) % 5].inputs << machines[i].run
    end
  end

  machines[4].output_value
end
p max
