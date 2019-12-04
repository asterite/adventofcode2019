different_passwords =
  (138241..674034).count do |number|
    digits = number.to_s.chars.map(&.to_i)

    # Two adjacent digits are the same,
    # are not part of a larger group of matching digits
    digits.chunk_while { |x, y| x == y }.any? &.size.==(2) &&
      # Going from left to right, the digits never decrease
      digits.each_cons(2).all? { |(x, y)| x <= y }
  end
puts different_passwords
