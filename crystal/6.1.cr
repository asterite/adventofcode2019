class SpaceObject
  def initialize(@name : String)
    @left_objects = Set(SpaceObject).new
  end

  def add_left_object(object : SpaceObject)
    @left_objects << object
  end

  getter(orbits_count : Int32) do
    @left_objects.sum(0) do |object|
      object.orbits_count + 1
    end
  end
end

objects = Hash(String, SpaceObject).new do |hash, name|
  hash[name] = SpaceObject.new(name)
end

File.each_line("#{__DIR__}/../inputs/6.txt") do |line|
  left, _, right = line.partition(')')
  objects[right].add_left_object(objects[left])
end

puts objects.values.sum &.orbits_count
