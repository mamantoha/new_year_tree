require "ncurses"

class NewYearTree
  alias Coordinates = NamedTuple(y: Int32, x: Int32, char: String)

  getter cols : Int32, lines : Int32

  COLORS = [
    NCurses::RED,
    NCurses::GREEN,
    NCurses::YELLOW,
    NCurses::BLUE,
    NCurses::MAGENTA,
    NCurses::CYAN,
    NCurses::WHITE
  ]

  macro define_colors
    {% for color in COLORS %}
      NCurses.init_color_pair({{color}}, {{color}}, NCurses::BLACK)
    {% end %}
  end

  def initialize
    NCurses.init
    NCurses.cbreak
    NCurses.no_echo
    NCurses.start_color
    NCurses.curs_set(0)

    define_colors

    @cols = NCurses.cols || 100
    @lines = NCurses.lines || 100
  end

  def run
    header_indent = 5
    section_size = 4
    sections_count = (lines - header_indent) / section_size - 1
    next_year = Time.now.year + 1

    begin
      border = sections_border(header_indent, section_size)
      ornament = sections_ornament(header_indent, section_size)
      star = star(header_indent, cols / 2)

      loop do
        draw_text_on_center(1, "Happy New #{next_year} Year!")
        draw_sections_border(border)
        draw_sections_ornament(ornament)
        draw_star(star)

        NCurses.refresh
        sleep(0.5)
      end
    ensure
      NCurses.end_win
    end
  end

  def sections_border(header_indent, section_size)
    coordinates = [] of Coordinates
    sections_count = (lines - header_indent) / section_size - 1

    sections_count.times do |i|
      line = header_indent + (section_size * i) + 1
      indent = (2 * section_size - 4) * i + 1

      return coordinates if cols / 2 < indent + section_size + 2

      section_size.times do |i|
        coordinates << {y: line + i, x: cols / 2 - indent - i * 2, char: "/"}
        coordinates << {y: line + i, x: cols / 2 + indent + i * 2, char: "\\"}
      end
    end

    return coordinates
  end

  def sections_ornament(header_indent, section_size)
    coordinates = [] of Coordinates

    sections_count = (lines - header_indent) / section_size - 1

    sections_count.times do |i|
      line = header_indent + (section_size * i) + 1
      indent = (2 * section_size - 4) * i + 1

      return coordinates if cols / 2 < indent + section_size + 2

      section_size.times do |i|
        range = (cols / 2 - indent + 1 - i * 2...cols / 2 + indent + i * 2)

        ornaments = range.to_a.zip(Array.new(range.size) { rand(0..range.size/2) })
        ornaments.each do |gift|
          if gift[1] == 0
            coordinates << {y: line + i, x: gift[0], char: "O"}
          end
        end
      end
    end

    return coordinates
  end

  def star(y : Int32, x : Int32)
    coordinates = [] of Coordinates
    coordinates = [
      {y: y, x: x, char: "0"},
      {y: y - 1, x: x, char: "|"},
      {y: y - 2, x: x, char: "|"},
      {y: y + 1, x: x, char: "|"},
      {y: y + 2, x: x, char: "|"},
      {y: y, x: x - 1, char: "="},
      {y: y, x: x - 2, char: "-"},
      {y: y, x: x - 3, char: "-"},
      {y: y, x: x + 1, char: "="},
      {y: y, x: x + 2, char: "-"},
      {y: y, x: x + 3, char: "-"},
      {y: y + 1, x: x - 1, char: "/"},
      {y: y - 1, x: x - 1, char: "\\"},
      {y: y + 1, x: x + 1, char: "\\"},
      {y: y - 1, x: x + 1, char: "/"},
    ]
  end

  def draw_star(coordinates)
    NCurses.stdscr.with_attr(:bold) do
      NCurses.stdscr.with_color(NCurses::RED) do
        coordinates.each do |c|
          NCurses.setpos(c[:y], c[:x])
          NCurses.addstr(c[:char])
        end
      end
    end
  end

  def draw_sections_border(coordinates)
    NCurses.stdscr.with_color(NCurses::GREEN) do
      coordinates.each do |c|
        NCurses.setpos(c[:y], c[:x])
        NCurses.addstr(c[:char])
      end
    end
  end

  def draw_sections_ornament(coordinates)
    coordinates.each do |c|
      NCurses.stdscr.with_color(COLORS.sample) do
        NCurses.setpos(c[:y], c[:x])
        NCurses.addstr(c[:char])
      end
    end
  end

  def draw_text_on_center(y : Int32, text = "")
    NCurses.stdscr.with_color(NCurses::BLUE) do
      NCurses.setpos(y, cols / 2 - (text.size / 2))
      NCurses.addstr(text)
    end
 end
end

NewYearTree.new.run
