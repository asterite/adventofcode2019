class Asteroid
  UP = Math.atan2(-1, 0)

  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def distance_to(asteroid : Asteroid)
    (x - asteroid.x).abs + (y - asteroid.y).abs
  end

  def angle_to(asteroid : Asteroid)
    angle = Math.atan2((asteroid.y - y), (asteroid.x - x))
    angle += Math::PI * 2 if angle < UP
    angle
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

station = asteroids.max_by &.visible(asteroids).size

counter = 0
loop do
  station
    .visible(asteroids)
    .sort_by { |other| station.angle_to(other) }
    .each do |other|
      counter += 1
      if counter == 200
        puts 100 * other.x + other.y
        exit
      end

      asteroids.delete(other)
    end
end
