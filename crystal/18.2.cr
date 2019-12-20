def find_letter(map, letter)
  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      return x, y if char == letter
    end
  end

  nil
end

def find_letters(map, letter)
  occurrences = [] of {Int32, Int32}

  map.each_with_index do |row, y|
    row.each_with_index do |char, x|
      occurrences << {x, y} if char == letter
    end
  end

  occurrences
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
    @keys_to_steps = {} of {Array({Int32, Int32}), Array(Char)} => Int32
  end

  def solve
    positions = find_letters(@map, '@')
    if positions.size == 1
      x, y = positions[0]
      @map[y][x] = '#'
      @map[y][x - 1] = '#'
      @map[y][x + 1] = '#'
      @map[y - 1][x] = '#'
      @map[y + 1][x] = '#'
      @map[y - 1][x - 1] = '@'
      @map[y - 1][x + 1] = '@'
      @map[y + 1][x - 1] = '@'
      @map[y + 1][x + 1] = '@'

      positions = find_letters(@map, '@')
    end

    all_keys = find_all_keys(@map).sort!.as(Array(Char))

    solve(positions, all_keys)
  end

  def solve(positions, remaining_keys)
    if remaining_keys.empty?
      return 0
    end

    cache_key = {positions, remaining_keys}

    cached = @keys_to_steps[cache_key]?
    if cached
      return cached
    end

    min_steps = positions.each_with_index.compact_map do |(pos, robot_index)|
      x, y = pos
      keys = find_keys(@map, x, y).sort_by!(&.letter)
      next nil if keys.empty?

      keys.min_of do |key|
        door_x, door_y = key.door_x, key.door_y

        @map[key.y][key.x] = '.'
        @map[door_y][door_x] = '.' if door_x && door_y

        positions[robot_index] = {key.x, key.y}

        steps = key.steps + solve(positions, remaining_keys - [key.letter])

        positions[robot_index] = {x, y}

        @map[key.y][key.x] = key.letter
        @map[door_y][door_x] = key.letter.upcase if door_x && door_y

        steps
      end
    end.min

    @keys_to_steps[cache_key] = min_steps
  end
end

map = File
  .read("#{__DIR__}/../inputs/18.txt")
  .lines
  .map(&.chars)

solver = Solver.new(map)
puts solver.solve
