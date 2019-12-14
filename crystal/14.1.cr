# This is a reaction like:
# 7 A, 1 E => 1 FUEL
record Reaction,
  inputs : Array(ChemicalQuantity),
  output : ChemicalQuantity

# This is each chemical quantity in a reaction
class ChemicalQuantity
  getter name, quantity

  def initialize(@name : String, @quantity : Int32)
  end

  def self.parse(line)
    quantity, name = line.split
    new(name, quantity.to_i)
  end
end

# This is a chemical's information
class Chemical
  # It's name
  getter name

  # What elements this chemical produces (across all reactions)
  getter outputs = Set(Chemical).new

  # The chemical's priority: the biggest the number, the later
  # it happens in the reaction. ORE has a priority of 0 and
  # FUEL will have the maximum priority.
  getter priority

  # This is the total quantity needed so far.
  property quantity : Int32

  def initialize(@name : String)
    @priority = 0
    @quantity = 0
  end

  # To compute the priority we start from ORE and
  # the outputs' priority will be one more that this
  # chemical's priority. If it had a previous priority,
  # the bigger one wins.
  def compute_priority(priority)
    if priority > @priority
      @priority = priority
    end
    outputs.each &.compute_priority(@priority + 1)
  end
end

# Parse the file into reactions
reactions = File
  .read_lines("#{__DIR__}/../inputs/14.txt")
  .map do |line|
    inputs, output = line.split(" => ")
    output = ChemicalQuantity.parse(output)
    inputs = inputs.split(", ").map { |input| ChemicalQuantity.parse(input) }
    Reaction.new(inputs, output)
  end

# Store all different chemicals by name
chemicals_by_name = Hash(String, Chemical).new do |h, name|
  h[name] = Chemical.new(name)
end

# Gather all chemical outputs
reactions.each do |reaction|
  reaction.inputs.each do |input|
    chemicals_by_name[input.name].outputs << chemicals_by_name[reaction.output.name]
  end
end

# Get just the Chemicals from the hash
chemicals = chemicals_by_name.values

# Compute the priority of each element, starting from 0
chemicals.each &.compute_priority(0)

# Sort by priority, so FUEL will be first and ORE will be last
chemicals.sort_by! { |chemical| -chemical.priority }

# We need one FUEL to begin with
chemicals_by_name["FUEL"].quantity = 1

# Now for each chemical, which are sorted by priority,
# we compute how many inputs we need
chemicals.each do |chemical|
  # ORE doesn't need inputs to be produced
  next if chemical.name == "ORE"

  # Find the reaction that produces this chemical
  reaction = reactions.find(&.output.name.==(chemical.name)).not_nil!

  # How many times we need to apply this reaction?
  multiplier = (chemical.quantity / reaction.output.quantity).ceil.to_i

  # Add the quantities that we need directly in each chemical
  reaction.inputs.each do |input|
    chemicals_by_name[input.name].quantity += input.quantity * multiplier
  end
end

puts chemicals_by_name["ORE"].quantity
