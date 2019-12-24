class Grid
  getter(outer) { Grid.new(inner: self) }
  getter(inner) { Grid.new(outer: self) }
  getter grid

  @next : Array(Array(Bool))

  def initialize(@grid : Array(Array(Bool)))
    @next = @grid.clone
  end

  def initialize(@inner = nil, @outer = nil)
    @grid = Array.new(5) { Array.new(5) { false } }
    @next = @grid.clone
  end

  def step
    5.times do |y|
      5.times do |x|
        # Skip middle
        next if x == 2 && y == 2

        count = 0

        # Up
        if y == 0
          count += 1 if outer.grid[1][2]
        elsif y == 3 && x == 2
          count += 1 if inner.grid[4][0]
          count += 1 if inner.grid[4][1]
          count += 1 if inner.grid[4][2]
          count += 1 if inner.grid[4][3]
          count += 1 if inner.grid[4][4]
        else
          count += 1 if grid[y - 1][x]
        end

        # Down
        if y == 4
          count += 1 if outer.grid[3][2]
        elsif y == 1 && x == 2
          count += 1 if inner.grid[0][0]
          count += 1 if inner.grid[0][1]
          count += 1 if inner.grid[0][2]
          count += 1 if inner.grid[0][3]
          count += 1 if inner.grid[0][4]
        else
          count += 1 if grid[y + 1][x]
        end

        # Left
        if x == 0
          count += 1 if outer.grid[2][1]
        elsif x == 3 && y == 2
          count += 1 if inner.grid[0][4]
          count += 1 if inner.grid[1][4]
          count += 1 if inner.grid[2][4]
          count += 1 if inner.grid[3][4]
          count += 1 if inner.grid[4][4]
        else
          count += 1 if grid[y][x - 1]
        end

        # Right
        if x == 4
          count += 1 if outer.grid[2][3]
        elsif x == 1 && y == 2
          count += 1 if inner.grid[0][0]
          count += 1 if inner.grid[1][0]
          count += 1 if inner.grid[2][0]
          count += 1 if inner.grid[3][0]
          count += 1 if inner.grid[4][0]
        else
          count += 1 if grid[y][x + 1]
        end

        if grid[y][x] && count != 1
          @next[y][x] = false
        elsif !grid[y][x] && (count == 1 || count == 2)
          @next[y][x] = true
        else
          @next[y][x] = grid[y][x]
        end
      end
    end
  end

  def step_outer(times)
    return if times == 0

    outer.step
    outer.step_outer(times - 1)
  end

  def step_inner(times)
    return if times == 0

    inner.step
    inner.step_inner(times - 1)
  end

  def swap
    5.times do |y|
      5.times do |x|
        @grid[y][x] = @next[y][x]
      end
    end
  end

  def swap_outer(times)
    return if times == 0

    outer.swap
    outer.swap_outer(times - 1)
  end

  def swap_inner(times)
    return if times == 0

    inner.swap
    inner.swap_inner(times - 1)
  end

  def count
    @grid.sum &.count &.==(true)
  end

  def outer_count
    if outer = @outer
      outer.count + outer.outer_count
    else
      0
    end
  end

  def inner_count
    if inner = @inner
      inner.count + inner.inner_count
    else
      0
    end
  end
end

grid = File
  .read("#{__DIR__}/../inputs/24.txt")
  .lines
  .map do |line|
    line.chars.map do |char|
      char == '#'
    end
  end

grid = Grid.new(grid)

200.times do |i|
  grid.step
  grid.step_outer(i + 1)
  grid.step_inner(i + 1)
  grid.swap
  grid.swap_outer(i + 1)
  grid.swap_inner(i + 1)
end

puts grid.count + grid.outer_count + grid.inner_count
