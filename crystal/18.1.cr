def find_letter(map, letter)
  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      return x, y if char == letter
    end
  end

  nil
end

def find_all_keys(map)
  keys = [] of Char

  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      if 'a' <= char <= 'z'
        keys << char
      end
    end
  end

  keys
end

record Key,
  letter : Char,
  x : Int32,
  y : Int32,
  door_x : Int32?,
  door_y : Int32?,
  steps : Int32

struct KeyFinder
  def initialize(@map : Array(Array(Char)))
    @keys = [] of Key
    @seen = {} of {Int32, Int32} => Int32
    @width = @map[0].size.as(Int32)
    @height = @map.size.as(Int32)
  end

  def find(x, y)
    find(x, y, 0)
    @keys
  end

  def find(x, y, steps)
    seen_steps = @seen[{x, y}]?
    return if seen_steps && seen_steps <= steps

    @seen[{x, y}] = steps

    char = @map[y][x]
    return if char == '#' || 'A' <= char <= 'Z'

    if 'a' <= char <= 'z'
      door = find_letter(@map, char.upcase)

      @keys << Key.new(char, x, y, door.try(&.[0]), door.try(&.[1]), steps)
      return
    end

    find(x - 1, y, steps + 1)
    find(x + 1, y, steps + 1)
    find(x, y - 1, steps + 1)
    find(x, y + 1, steps + 1)
  end
end

def find_keys(map, x, y)
  KeyFinder.new(map).find(x, y)
end

class Solver
  def initialize(@map : Array(Array(Char)))
    @keys_to_steps = {} of {Int32, Int32, Array(Char)} => Int32
  end

  def solve
    x, y = find_letter(@map, '@').not_nil!
    all_keys = find_all_keys(@map).sort!.as(Array(Char))

    solve(x, y, all_keys)
  end

  def solve(x, y, remaining_keys)
    if remaining_keys.empty?
      return 0
    end

    cache_key = {x, y, remaining_keys}

    cached = @keys_to_steps[cache_key]?
    if cached
      return cached
    end

    keys = find_keys(@map, x, y).sort_by!(&.letter)

    min_steps = keys.min_of do |key|
      door_x, door_y = key.door_x, key.door_y

      @map[key.y][key.x] = '.'
      @map[door_y][door_x] = '.' if door_x && door_y

      steps = key.steps + solve(key.x, key.y, remaining_keys - [key.letter])

      @map[key.y][key.x] = key.letter
      @map[door_y][door_x] = key.letter.upcase if door_x && door_y

      steps
    end

    @keys_to_steps[cache_key] = min_steps
  end
end

map = File
  .read("#{__DIR__}/../inputs/18.txt")
  .lines
  .map(&.chars)

solver = Solver.new(map)
puts solver.solve
