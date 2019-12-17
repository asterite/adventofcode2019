class Oscilator
  include Iterator(Int32)

  PHASE = [0, 1, 0, -1]

  def initialize(@count : Int32)
    @phase_index = 0
    @phase_count = 0
  end

  def next
    value = PHASE[@phase_index]
    @phase_count += 1
    if @phase_count == @count
      @phase_index = (@phase_index + 1) % PHASE.size
      @phase_count = 0
    end
    value
  end
end

digits = File
  .read("#{__DIR__}/../inputs/16.txt")
  .chomp
  .chars
  .map(&.to_i)

100.times do
  digits = Array.new(digits.size) do |vi|
    oscilator = Oscilator.new(vi + 1).skip(1)
    digits.sum do |digit|
      o = oscilator.next.as(Int32)
      (digit * o)
    end.abs % 10
  end
end

puts digits[...8].join
