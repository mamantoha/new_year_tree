require "curses"

Curses.init_screen
Curses.crmode
Curses.start_color
Curses.nl
Curses.noecho

loop do
  begin
    Curses.setpos(10, 10)
    Curses.addstr("+")
    Curses.setpos(5, 5)
    Curses.addstr("!")
    Curses.refresh
  end
end
