record Reaction,
  inputs : Array(ChemicalQuantity),
  output : ChemicalQuantity

class ChemicalQuantity
  getter name, quantity

  def initialize(@name : String, @quantity : Int32)
  end

  def self.parse(line)
    quantity, name = line.split
    new(name, quantity.to_i)
  end
end

class Chemical
  getter name
  getter outputs = Set(Chemical).new
  getter priority
  property quantity : Int32

  def initialize(@name : String)
    @priority = 0
    @quantity = 0
  end

  def compute_priority(priority)
    if priority > @priority
      @priority = priority
    end
    outputs.each &.compute_priority(@priority + 1)
  end
end

reactions = File
  .read_lines("#{__DIR__}/../inputs/14.txt")
  .map do |line|
    inputs, output = line.split(" => ")
    output = ChemicalQuantity.parse(output)
    inputs = inputs.split(", ").map { |input| ChemicalQuantity.parse(input) }
    Reaction.new(inputs, output)
  end

chemicals_by_name = Hash(String, Chemical).new do |h, name|
  h[name] = Chemical.new(name)
end

reactions.each do |reaction|
  reaction.inputs.each do |input|
    chemicals_by_name[input.name].outputs << chemicals_by_name[reaction.output.name]
  end
end

chemicals = chemicals_by_name.values

chemicals.each &.compute_priority(0)
chemicals.sort_by! { |chemical| -chemical.priority }

chemicals_by_name["FUEL"].quantity = 1

chemicals.each do |chemical|
  next if chemical.name == "ORE"

  reaction = reactions.find(&.output.name.==(chemical.name)).not_nil!

  multiplier = (chemical.quantity / reaction.output.quantity).ceil.to_i
  reaction.inputs.each do |input|
    chemicals_by_name[input.name].quantity += input.quantity * multiplier
  end
end

puts chemicals_by_name["ORE"].quantity
