digits = File
  .read("#{__DIR__}/../inputs/8.txt")
  .chomp
  .chars
  .map(&.to_i)

width = 25
height = 6
layers = digits.in_groups_of(width * height)
layer = layers.min_by &.count(0)
p layer.count(1) * layer.count(2)
