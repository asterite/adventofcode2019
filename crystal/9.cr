require "./intcode"

data = File
  .read("#{__DIR__}/../inputs/9.txt")
  .split(',')
  .map(&.to_i64)

Intcode.new(data).run
