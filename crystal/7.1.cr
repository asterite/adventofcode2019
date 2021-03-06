class Intcode
  def initialize(@data : Array(Int32), @inputs : Array(Int32))
    @ip = 0
    @opcode = 0
    @output = 0
  end

  def run
    while true
      @opcode = read
      case @opcode % 100
      when  1 then add
      when  2 then multiply
      when  3 then input
      when  4 then output
      when  5 then jump_if_true
      when  6 then jump_if_false
      when  7 then less_than
      when  8 then equals
      when 99 then break # halt
      else         raise "Unexpected opcode: #{@opcode}"
      end
    end
    @output
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
    @output = param(0)
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

max = (0..4).to_a.each_permutation(reuse: true).max_of do |settings|
  settings.reduce(0) do |input, setting|
    Intcode.new(code.dup, [setting, input]).run
  end
end
p max
