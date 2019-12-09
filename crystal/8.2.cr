digits = File
  .read("#{__DIR__}/../inputs/8.txt")
  .chomp
  .chars
  .map(&.to_i)

width = 25
height = 6
layers = digits.in_groups_of(width * height, filled_up_with: 2)

image = Array.new(height) { Array.new(width, 2) }

layers.reverse_each do |layer|
  layer.in_groups_of(width, filled_up_with: 2).each_with_index do |row, row_index|
    row.each_with_index do |pixel, column_index|
      image[row_index][column_index] = pixel unless pixel == 2
    end
  end
end

image.each do |row|
  row.each do |pixel|
    print pixel == 1 ? 'x' : ' '
  end
  puts
end
