class Intcode
  def initialize(initial_data : Array(Int64))
    @data = Hash(Int64, Int64).new(0)
    initial_data.each_with_index do |value, index|
      @data[index.to_i64] = value.to_i64
    end

    @ip = 0_i64
    @opcode = 0_i64
    @relative_base = 0_i64
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
      when  9 then adjust_relative_base
      when 99 then break # halt
      else         raise "Unexpected opcode: #{@opcode % 100}"
      end
    end
  end

  private def add
    binary { |x, y| x + y }
  end

  private def multiply
    binary { |x, y| x * y }
  end

  private def input
    @data[write_param_mode(0)] = read_int
  end

  private def output
    puts param(0)
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
    binary { |x, y| x < y ? 1_i64 : 0_i64 }
  end

  private def equals
    binary { |x, y| x == y ? 1_i64 : 0_i64 }
  end

  private def adjust_relative_base
    @relative_base += param(0)
  end

  private def binary
    input1 = param(0)
    input2 = param(1)
    @data[write_param_mode(2)] = yield input1, input2
  end

  private record Address, address : Int64
  private record Immediate, value : Int64

  private def param(pos)
    mode = param_mode(pos)
    if mode.is_a?(Immediate)
      mode.value
    else
      @data[mode.address]
    end
  end

  private def write_param_mode(pos)
    mode = param_mode(pos)
    unless mode.is_a?(Address)
      raise "got immediate param mode for instruction that writes data"
    end
    mode.address
  end

  private def param_mode(pos)
    value = read
    mode = (@opcode // (100 * 10**pos)) % 10
    case mode
    when 0 # position mode
      Address.new(value)
    when 1 # immediate mode
      Immediate.new(value)
    when 2
      Address.new(@relative_base + value)
    else
      raise "Unknown mode #{mode} resulting from opcode #{@opcode}, param at pos #{pos}"
    end
  end

  private def read
    @data[@ip].tap { @ip += 1 }
  end

  private def read_int
    print "Enter an integer: "
    gets.try &.to_i64? || read_int
  end
end
