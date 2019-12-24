def print_map(map)
  n = 1
  count = 0

  map.each do |row|
    row.each do |cell|
      if cell
        print '#'
        count += n
      else
        print '.'
      end
      n *= 2
    end
    puts
  end
  puts count
  puts
end

map = File
  .read("#{__DIR__}/../inputs/24.txt")
  .lines
  .map do |line|
    line.chars.map do |char|
      char == '#'
    end
  end

seen = Set(typeof(map)).new

while seen.add?(map)
  print_map map

  next_map = map.clone

  5.times do |y|
    5.times do |x|
      count = 0
      count += 1 if x > 0 && map[y][x - 1]
      count += 1 if x < 4 && map[y][x + 1]
      count += 1 if y > 0 && map[y - 1][x]
      count += 1 if y < 4 && map[y + 1][x]

      if map[y][x] && count != 1
        next_map[y][x] = false
      elsif !map[y][x] && (count == 1 || count == 2)
        next_map[y][x] = true
      end
    end
  end

  map = next_map
end

print_map map
