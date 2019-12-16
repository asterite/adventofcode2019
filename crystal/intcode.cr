class Intcode(T)
  def self.from_file(filename)
    new(parse(File.read(filename)))
  end

  def self.parse(data)
    data.split(',').map { |n| T.new(n) }
  end

  @data : Array(T)
  @ip : T
  @opcode : T
  @relative_base : T
  @stop = false

  def initialize(initial_data : Array(T))
    @data = initial_data.dup
    @ip = T.zero
    @opcode = T.zero
    @relative_base = T.zero
    @on_input = ->read_int
    @on_output = ->(value : T) { puts value }
  end

  def on_input(&@on_input : -> T)
  end

  def on_output(&@on_output : T ->)
  end

  def stop
    @stop = true
  end

  def run
    until @stop
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
    write_data write_param_mode(0), @on_input.call
  end

  private def output
    @on_output.call param(0)
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
    binary { |x, y| x < y ? T.new(1) : T.zero }
  end

  private def equals
    binary { |x, y| x == y ? T.new(1) : T.zero }
  end

  private def adjust_relative_base
    @relative_base += param(0)
  end

  private def binary
    input1 = param(0)
    input2 = param(1)
    write_data write_param_mode(2), (yield input1, input2)
  end

  private record Address(T), address : T
  private record Immediate(T), value : T

  private def param(pos)
    mode = param_mode(pos)
    if mode.is_a?(Immediate)
      mode.value
    else
      read_data mode.address
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
      Address(T).new(value)
    when 1 # immediate mode
      Immediate(T).new(value)
    when 2
      Address(T).new(@relative_base + value)
    else
      raise "Unknown mode #{mode} resulting from opcode #{@opcode}, param at pos #{pos}"
    end
  end

  private def read
    read_data(@ip).tap { @ip += 1 }
  end

  private def read_int
    print "Enter an integer: "
    gets.try { |value| T.new(value.to_i64) } || read_int
  end

  private def read_data(index)
    ensure_enough_memory(index) do
      @data[index]
    end
  end

  private def write_data(index, value)
    ensure_enough_memory(index) do
      @data[index] = value
    end
  end

  private def ensure_enough_memory(index)
    while index >= @data.size
      @data << T.zero
    end
    yield
  end
end
