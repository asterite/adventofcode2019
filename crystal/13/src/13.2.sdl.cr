require "../../intcode"
require "sdl"
require "./sdl_ext"

enum Tile
  Empty  = 0
  Wall   = 1
  Block  = 2
  Paddle = 3
  Ball   = 4
end

class Screen
  BLACK = {0, 0, 0, 0}
  BROWN = {101, 67, 33, 0}
  BLUE  = {0, 0, 127, 0}
  WHITE = {255, 255, 255, 0}
  RED   = {255, 0, 0, 0}

  SCALING_X = 30
  SCALING_Y = 24

  @pitch : Int32
  @screen_width : Int32
  @screen_height : Int32

  def initialize(@width : Int32, @height : Int32)
    @screen_width = (@width + 1) * SCALING_X
    @screen_height = (@height + 1) * SCALING_Y

    SDL.init(SDL::Init::VIDEO)
    @window = SDL::Window.new("Advent of Code 2019 (13)", @screen_width, @screen_height, flags: SDL::Window::Flags.flags(SHOWN, RESIZABLE))
    @renderer = SDL::Renderer.new(@window, SDL::Renderer::Flags::ACCELERATED | SDL::Renderer::Flags::PRESENTVSYNC)
    @texture = SDL::Texture.new(@renderer, SDL::PIXELFORMAT_8888, LibSDL::TextureAccess::STREAMING.value, @screen_width, @screen_height)
    @pixels = Pointer(UInt32).malloc(@screen_width * @screen_height)
    @pitch = @screen_width * 4
  end

  def draw
    @texture.lock(nil, pointerof(@pixels).as(Void**), pointerof(@pitch))

    yield

    @texture.unlock

    @renderer.clear
    @renderer.copy(@texture)
    @renderer.present
  end

  def write_tile(x, y, tile)
    rgba = case tile
           when .empty?
             BLACK
           when .wall?
             BROWN
           when .block?
             BLUE
           when .paddle?
             RED
           when .ball?
             WHITE
           else
             raise "Unknown tile: #{tile}"
           end
    rectangle(x, y, rgba)
  end

  def rectangle(x, y, rgba)
    SCALING_Y.times do |by|
      SCALING_X.times do |bx|
        @pixels[(by + y * SCALING_Y) * @screen_width + x * SCALING_X + bx] = color(*rgba).to_u32
      end
    end
  end

  def color(r, g, b, a)
    (b.to_u32 << 24) + (g.to_u32 << 16) + (r.to_u32 << 8) + a.to_u32
  end
end

map = Hash({Int64, Int64}, Tile).new(:empty)

data = Intcode.parse(File.read("#{__DIR__}/../../../inputs/13.txt"))
data[0] = 2
cached_screen = nil

intcode = Intcode.new(data)
intcode.on_input do
  keys = map.keys
  min_x, max_x = keys.minmax_of &.[0]
  min_y, max_y = keys.minmax_of &.[1]

  cached_screen ||= Screen.new((max_x - min_x).to_i, (max_y - min_y).to_i)
  screen = cached_screen.not_nil!

  screen.draw do
    (min_x..max_x).each do |x|
      (min_y..max_y).each do |y|
        screen.write_tile(x, y, map[{x, y}])
      end
    end
  end

  key = nil

  until key
    SDL::Event.poll do |event|
      case event
      when SDL::Event::Quit
        exit
      when SDL::Event::Keyboard
        case event
        when .keydown?
          case event.sym
          when .escape?, .q?
            exit
          when .left?
            key = -1_i64
          when .right?
            key = 1_i64
          when .down?
            key = 0_i64
          end
        end
      end
    end
  end

  key
end

score = 0_i64

outputs = [] of Int64
intcode.on_output do |value|
  outputs << value
  if outputs.size == 3
    x, y, tile_id = outputs
    outputs.clear

    if x == -1 && y == 0
      score = tile_id
      puts score
    else
      map[{x, y}] = Tile.new(tile_id.to_i)
    end
  end
end

intcode.run
