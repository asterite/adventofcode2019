puts File
  .open("#{__DIR__}/input.txt")
  .each_line
  .map(&.to_i)
  .map { |mass| fuel(mass) }
  .sum

def fuel(mass)
  mass // 3 - 2
end
