class SpaceObject
  getter distance = Int32::MAX

  def initialize(@name : String)
    @connections = Set(SpaceObject).new
  end

  def connect_to(object : SpaceObject)
    @connections << object
  end

  def flood_fill(distance = 0)
    if distance < @distance
      @distance = distance
      @connections.each &.flood_fill(@distance + 1)
    end
  end
end

objects = Hash(String, SpaceObject).new do |hash, name|
  hash[name] = SpaceObject.new(name)
end

File.each_line("#{__DIR__}/../inputs/6.txt") do |line|
  left, _, right = line.partition(')')
  objects[right].connect_to(objects[left])
  objects[left].connect_to(objects[right])
end

objects["YOU"].flood_fill
puts objects["SAN"].distance - 2
