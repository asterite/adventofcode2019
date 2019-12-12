class Moon
  getter x, y, z
  getter vx, vy, vz

  def initialize(@x : Int32, @y : Int32, @z : Int32)
    @vx = @vy = @vz = 0
  end

  def compute_gravity(moon : Moon)
    @vx += moon.x > x ? 1 : (moon.x < x ? -1 : 0)
    @vy += moon.y > y ? 1 : (moon.y < y ? -1 : 0)
    @vz += moon.z > z ? 1 : (moon.z < z ? -1 : 0)
  end

  def apply_gravity
    @x += @vx
    @y += @vy
    @z += @vz
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  def potential_energy
    @x.abs + @y.abs + @z.abs
  end

  def kinetic_energy
    @vx.abs + @vy.abs + @vz.abs
  end
end

moons = File
  .read_lines("#{__DIR__}/../inputs/12.txt")
  .map do |line|
    x, y, z = line[1...-1].split(",").map { |piece| piece.split('=')[1].to_i }
    Moon.new(x, y, z)
  end

1000.times do |i|
  moons.each_combination(2) do |(moon1, moon2)|
    moon1.compute_gravity(moon2)
    moon2.compute_gravity(moon1)
  end
  moons.each &.apply_gravity
end

puts moons.sum &.total_energy
