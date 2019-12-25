# I played the game manually until I built the entire map:
#
# . . . . . . .
# . . 8 7 . . .
# . . . 6 . . .
# . . 9 5 . . .
# . . . | . . .
# . ? . | . . .
# . I H | . . .
# . . G | . . .
# . . A 4 . . .
# . . B | . . .
# . E . | . . .
# . D 0 1 2 . .
# . . C . 3 F .
# . . . . . . .
#
# 0 - Hull breach
# 1 - Observatory (asterisk)
# 2 - Gift wrapping center
# 3 - Warp drive maintenance (escape pod X)
# 4 - Arcade (giant electromagnet X)
# 5 - Passages (hypercube)
# 6 - Storage (coin)
# 7 - Navigation (easter egg)
# 8 - Hot chocolate fountain
# 9 - Holodeck
# A - Crew quarters
# B - Engineering (molten lava X)
# C - Sick bay (infinite loop X)
# D - Stables (fixed point)
# E - Hallway (sand)
# F - Science lab (photons X)
# G - Corridor (spool of cat6)
# H - Kitchen (shell)
# I - Security checkpoint
#
# Then I wrote a program to traverse the entire map,
# with instructions to take everything along the way...
# except that I run the program multiple times with "take"
# instructions toggled off, trying all combinations, until
# it succeeds. I first did that manually (using `gets` after
# every run), then I knew "Oh, hello" was in the success
# output so that's the resulting program.

require "./intcode"

text = <<-TEXT
west # D
take fixed point
north # E
take sand
south # D
east # 0
east # 1
take asterisk
north # 4
north # 5
take hypercube
north # 6
take coin
north # 7
take easter egg
south # 6
south # 5
south # 4
west # A
north # G
take spool of cat6
north # H
take shell
west # I
inv
north # ?
TEXT

number_of_takes = text.scan(/take/).size
combinations = 2 ** number_of_takes
combinations.times do |combination|
  total_output = IO::Memory.new

  input = [] of Int32

  count = 0
  text.each_line do |line|
    line = line.split('#').first.strip
    next if line.empty?

    if line.starts_with?("take")
      skip = combination.bit(count) == 0
      count += 1
      next if skip
    end

    line.each_char do |char|
      input << char.ord
    end
    input << '\n'.ord
  end

  intcode = Intcode(Int64).from_file("#{__DIR__}/../inputs/25.txt")
  intcode.on_output do |output|
    total_output << output.chr
    print output.chr
  end
  intcode.on_input do
    value = input.shift?
    if value
      value.to_i64
    else
      intcode.stop
      '\n'.ord.to_i64
    end
  end
  intcode.run

  if total_output.to_s.includes?("Oh, hello!")
    break
  end
end
