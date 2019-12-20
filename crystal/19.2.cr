require "./intcode"

def beam?(data, x, y)
  output = nil

  intcode = Intcode.new(data)
  intcode.on_output do |value|
    output = value == 1
  end
  inputs = [x, y]
  intcode.on_input do
    inputs.shift
  end
  intcode.run

  output.not_nil!
end

record Span, y : Int32, min_x : Int32, max_x : Int32 do
  def width
    max_x - min_x + 1
  end
end

def solve(target_size)
  target_size = 100

  data = Intcode(Int32).parse(File.read("#{__DIR__}/../inputs/19.txt"))

  spans = [] of Span

  min_x = nil
  max_x = nil
  closest_span = nil
  y = 1
  while true
    if min_x && max_x
      x = min_x
      in_beam = false
      while true
        if in_beam
          if beam?(data, x, y)
            max_x = x
          else
            break
          end
        elsif beam?(data, x, y)
          in_beam = true
          min_x = x
          max_x = x
        end
        x += 1
      end
      span = Span.new(y, min_x, max_x)
      spans << span

      if spans.size > target_size && span.width >= target_size
        opposite_span = spans[-target_size]
        if opposite_span.min_x <= span.min_x &&
           span.min_x + target_size - 1 <= opposite_span.max_x
          return span.min_x * 10_000 + opposite_span.y
        end
      end
    else
      10.times do |x|
        if beam?(data, x, y)
          min_x = x unless min_x
          max_x = x
        end
      end

      if min_x && max_x
        spans << Span.new(y, min_x, max_x)
      end
    end
    y += 1
  end
end

puts solve(target_size: 100)
