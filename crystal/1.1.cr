puts File
  .read("#{__DIR__}/../inputs/1.txt")
  .each_line
  .map(&.to_i)
  .map { |mass| fuel(mass) }
  .sum

def fuel(mass)
  mass // 3 - 2
end
