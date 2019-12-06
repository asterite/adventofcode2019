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

File
  .read("#{__DIR__}/../inputs/6.txt")
  .lines
  .each do |line|
    left, _, right = line.partition(')')
    left_object, right_object = objects[right], objects[left]
    left_object.connect_to(right_object)
    right_object.connect_to(left_object)
  end

objects["YOU"].flood_fill
puts objects["SAN"].distance - 2
