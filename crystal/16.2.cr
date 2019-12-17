# The pattern is something like this:
# ('+' is +1, '.' is 0 and '-' is -1)
#
# +.-.+.-.+.-.+.-.+.-.
# .++..--..++..--..++.
# ..+++...---...+++...
# ...++++....----....-
# ....+++++.....-----.
# .....++++++......---
# ......+++++++.......
# .......++++++++.....
# ........+++++++++...
# .........+++++++++++
# ..........++++++++++
# ...........+++++++++
# ............++++++++
# .............+++++++
# ..............++++++
# ...............+++++
# ................++++
# .................+++
# ..................++
# ...................+
#
# As you can see, digits past the half of the number length
# are easy to compute: they are a partial sum of the digits.
# And if we start from the end we can compute all digits
# (down to the half) in one go by summing and outputting.
#
# That seems to be the trick for this problem: the 7-digit
# number that you get seems to always fall behind the half
# of the digits length.

digits = File
  .read("#{__DIR__}/../inputs/16.txt")
  .chomp
  .*(10_000)
  .chars
  .map(&.to_i)

next_digits = digits.dup

offset = digits[...7].join.to_i

100.times do
  row = digits.size - 1
  sum = 0
  while row >= offset
    sum = (sum + digits[row]).remainder(10)
    next_digits[row] = sum
    row -= 1
  end

  digits, next_digits = next_digits, digits
end

puts digits[offset, 8].join
