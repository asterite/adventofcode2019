class Moon
  getter x, vx

  def initialize(@x : Int32)
    @vx = 0
  end

  def compute_gravity(moon : Moon)
    @vx += moon.x > x ? 1 : (moon.x < x ? -1 : 0)
  end

  def apply_gravity
    @x += @vx
  end

  def state
    {@x, @vx}
  end
end

moon_data = File
  .read_lines("#{__DIR__}/../inputs/12.txt")
  .map do |line|
    line[1...-1].split(",").map { |piece| piece.split('=')[1].to_i }
  end

all_steps = [0, 1, 2].map do |i|
  moons = moon_data.map { |tuple| Moon.new(tuple[i]) }
  initial_state = moons.map &.state

  (1_u64...UInt64::MAX).find do
    moons.each_combination(2, reuse: true) do |(moon1, moon2)|
      moon1.compute_gravity(moon2)
      moon2.compute_gravity(moon1)
    end
    moons.each &.apply_gravity

    initial_state == moons.map &.state
  end.not_nil!
end

p all_steps.reduce(1_u64) { |x, y| x.lcm(y) }
