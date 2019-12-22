require "./intcode"

# Jump in these cases:
#
#    A B C D
# 1) ? ? _ #
# 2) _ ? ? ?

code = <<-CODE
  # 1)
  NOT C J
  AND D J
  NOT A T

  # 2)
  OR T J

  # Walk!
  WALK
  CODE

inputs = code
  .lines
  .reject { |line| line.empty? || line.starts_with?('#') }
  .join('\n')
  .chars
  .map(&.ord) + ['\n'.ord]

intcode = Intcode(Int32).from_file("#{__DIR__}/../inputs/21.txt")
intcode.on_input do
  inputs.shift
end
intcode.on_output do |output|
  if output <= Char::MAX.ord
    print output.chr
  else
    puts output
  end
end
intcode.run
