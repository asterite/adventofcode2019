puts File
  .open("#{__DIR__}/input.txt")
  .each_line
  .map(&.to_i)
  .map { |mass| fuel(mass) }
  .sum

def fuel(mass)
  fuel = mass // 3 - 2
  fuel += fuel(fuel) if fuel > 0
  fuel
end
