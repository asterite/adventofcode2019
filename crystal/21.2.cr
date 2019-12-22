require "./intcode"

# I'm still not sure why it works, but...
#
# Jump in these cases:
#
#    A B C D E F G H I
# 1) _ _ _ # ? ? ? # ?
# 2) _ ? ? ? ? ? ? ? ?

code = <<-CODE
  # 1)
  NOT J J
  AND D J
  AND H J
  NOT T T
  AND A T
  AND B T
  AND C T
  NOT T T
  AND T J

  # 2)
  NOT A T
  OR T J

  # Run!
  RUN
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
