# Source - https://stackoverflow.com/a
# Posted by Erik Skoglund, modified by community. See post 'Timeline' for change history
# Retrieved 2025-11-30, License - CC BY-SA 3.0

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end
