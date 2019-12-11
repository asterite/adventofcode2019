class Asteroid
  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def distance_to(asteroid : Asteroid)
    (x - asteroid.x).abs + (y - asteroid.y).abs
  end

  def angle_to(asteroid : Asteroid)
    Math.atan2((asteroid.y - y), (asteroid.x - x))
  end

  def visible(asteroids : Array(Asteroid))
    asteroids
      .select(&.!=(self))
      .sort_by(&.distance_to(self))
      .uniq(&.angle_to(self))
  end
end

asteroids = File
  .read_lines("#{__DIR__}/../inputs/10.txt")
  .each_with_index
  .flat_map do |(line, y)|
    line.each_char.with_index.compact_map do |(char, x)|
      Asteroid.new(x, y) if char == '#'
    end
  end
  .to_a

p asteroids.max_of &.visible(asteroids).size
