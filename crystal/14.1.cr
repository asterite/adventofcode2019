# This is a reaction like:
# 7 A, 1 E => 1 FUEL
record Reaction,
  inputs : Array(ChemicalQuantity),
  output : ChemicalQuantity do
  def self.parse(line)
    inputs, output = line.split(" => ")
    output = ChemicalQuantity.parse(output)
    inputs = inputs.split(", ").map { |input| ChemicalQuantity.parse(input) }
    new(inputs, output)
  end
end

# This is each chemical quantity in a reaction
record ChemicalQuantity,
  name : String,
  quantity : Int32 do
  def self.parse(text)
    quantity, name = text.split
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
  def compute_priority(priority = 0)
    @priority = priority if priority > @priority
    outputs.each &.compute_priority(@priority + 1)
  end
end

# Parse the file into reactions
reactions = File
  .read_lines("#{__DIR__}/../inputs/14.txt")
  .map do |line|
    Reaction.parse(line)
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

# Compute the priority starting from ORE
chemicals_by_name["ORE"].compute_priority

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

# At the end we should have the ORE that we need
puts chemicals_by_name["ORE"].quantity
