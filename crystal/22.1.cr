class Deck
  getter cards

  def initialize(size : Int32)
    @cards = Array(Int32).new(size, &.itself)
    @temp = Array(Int32).new(size, 0)
  end

  def deal_into_new_stack
    @cards.reverse!
  end

  def deal_with_increment(n)
    pos = 0
    @cards.size.times do |i|
      @temp[pos] = @cards[i]
      pos = (pos + n) % @cards.size
    end
    @cards.replace(@temp)
  end

  def cut(n)
    @cards.rotate!(n)
  end
end

deck = Deck.new(10007)

File.each_line("#{__DIR__}/../inputs/22.txt") do |line|
  case line
  when /deal with increment (\d+)/
    deck.deal_with_increment($1.to_i)
  when /deal into new stack/
    deck.deal_into_new_stack
  when /cut (-?\d+)/
    deck.cut($1.to_i)
  end
end

puts deck.cards.index(2019)
