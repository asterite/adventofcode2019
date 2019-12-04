different_passwords =
  (138241..674034).count do |number|
    digits = number.to_s.chars.map(&.to_i)

    # Two adjacent digits are the same
    digits.each_cons(2).any? { |(x, y)| x == y } &&
      # Going from left to right, the digits never decrease
      digits.each_cons(2).all? { |(x, y)| x <= y }
  end
puts different_passwords
