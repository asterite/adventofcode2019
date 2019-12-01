puts File
  .open("#{__DIR__}/input.txt")
  .each_line
  .map(&.to_i)
  .map { |mass| fuel(mass) }
  .sum

def fuel(mass)
  total = 0
  while mass > 0
    fuel = mass // 3 - 2
    total += fuel if fuel > 0
    mass = fuel
  end
  total
end
