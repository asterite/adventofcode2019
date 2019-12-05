class Intcode
  def initialize(@data : Array(Int32))
    @ip = 0
    @opcode = 0
  end

  def run
    while true
      @opcode = read
      case @opcode % 100
      when  1 then add
      when  2 then multiply
      when  3 then input
      when  4 then output
      when 99 then break # halt
      else         raise "Unexpected opcode: #{@opcode}"
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
    @data[read] = read_int
  end

  private def read_int
    print "Enter an integer: "
    gets.try &.to_i? || read_int
  end

  private def output
    puts param(0)
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

data = File
  .read("#{__DIR__}/../inputs/5.txt")
  .split(',')
  .map(&.to_i)

Intcode.new(data).run
