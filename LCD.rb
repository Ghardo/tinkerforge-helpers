#!/usr/bin/env ruby
# -*- ruby encoding: utf-8 -*-

require 'tinkerforge/ip_connection'
require 'tinkerforge/bricklet_lcd_20x4'

include Tinkerforge

class Tinkerforge_LCD

  POS_RIGHT = 'right'
  POS_CENTER = 'center'
  POS_LEFT = 0

  attr_reader :device

  def initialize(ipcon, uid)
    @device = BrickletLCD20x4.new uid, ipcon # Create device object
    @device.clear_display
  end

  def setBacklightOn
    @device.backlight_on
  end

  def setBacklightOff
    @device.backlight_off
  end

  def backlightToggle
    if @device.is_backlight_on
      @device.backlight_off
    else
      @device.backlight_on
    end
  end

  def clearline(line)
    self.write line, 0, " " * 20
  end

  def clear
    @device.clear_display
  end

  def write(line, pos, text, filled = false, wrap = false)
    case pos
      when "right"
        pos = 20 - text.length
      when "center"
        pos = ((20 - text.length)/2).to_i
    end

    @device.write_line line, pos, text

    if wrap and text.length > 20
      self.write line+1, 0, text[20,text.length]
    elsif filled
      self.fillblank line, pos, text
    end
  end

  def fillblank(line, pos, text)
    if text == nil or text.length >= 20
      return
    end

    case pos
      when POS_RIGHT
        @device.write_line line, 0, " " * (20 - text.length)
      when POS_CENTER
        pos = ((20 - text.length)/2).to_i
        @device.write_line line, 0, " " * (pos - 1)
        @device.write_line line, pos + text.length, " " * (pos - 1)
      when POS_LEFT
        @device.write_line line, text.length, " " * (20 - text.length)
    end
  end
end
