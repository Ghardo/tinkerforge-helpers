#!/usr/bin/env ruby
scriptself=File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
scriptpath=File.realdirpath(File.dirname(scriptself))
$LOAD_PATH.unshift(scriptpath)

class LCDMenu
  BTN_OK = 0
  BTN_DOWN = 1
  BTN_UP = 2
  BTN_RETURN = 3

  def initialize(lcd, menu)
    if false == menu.is_a?(Hash)
      raise "menu must be a Hash"
    end

    if false == menu.keys.include?('home')
          raise "the menu needs a home screen"
    end

    @indicator = nil
    @entry_index = 0
    @page_index = 0
    @active_menu = 'home'
    @last_menu = []
    @quitcallback = nil
    @menu = menu
    @lcd = lcd
    @lcd.device.register_callback(BrickletLCD20x4::CALLBACK_BUTTON_PRESSED) do |i|
      case i
        when BTN_OK
          self.cb_btn_ok
        when BTN_DOWN
          self.cb_btn_down
        when BTN_UP
          self.cb_btn_up
        when BTN_RETURN
          self.cb_btn_return
      end
    end
  end

  def setIndicator(character)
    @indicator = character
  end

  def show
    self.print_menu 'home'
  end

  def cb_btn_ok
    keys = @menu[@active_menu].keys
    entry = keys[@entry_index]
    field = @menu[@active_menu][entry]
    @entry_index = 0
    @page_index = 0

    if field.is_a?(String) and field.length > 0
      @last_menu.push(@active_menu)
      @active_menu = field
      print_menu field
    elsif field.is_a?(Proc)
      field.call
    end
  end

  def cb_btn_down

    if @entry_index+1 >= @menu['home'].length
      return
    end

    @lcd.write @entry_index%4, 0, " ", false, false
    @entry_index += 1
    @lcd.write @entry_index%4, 0,  @indicator, false, false

    if (@entry_index+1)%4 == 1 then
      self.print_menu(@active_menu,@entry_index)
    end
  end

  def cb_btn_up

    if @entry_index == 0
      return
    end

    @lcd.write @entry_index%4, 0, " ", false, false
    @entry_index -= 1
    @lcd.write @entry_index%4, 0,  @indicator, false, false

    if (@entry_index+1)%4 == 0 then
          self.print_menu(@active_menu,@entry_index-3, 3)
    end
  end

  def cb_btn_return
    @entry_index = 0
    @page_index = 0
    last = @last_menu.pop

    if last == nil
      @quitcallback.call
      return
    else
      @active_menu = last
      print_menu @active_menu
    end
  end

  def print_menu(menu, line = 0, pointer = 0)
    @lcd.clear
    keys = @menu[menu].keys
    for i in 0..3 do
      if keys[line + i] != nil
        @lcd.write i, 1,  keys[line + i], false, true
      end
    end
    @lcd.write pointer, 0, @indicator , false, false
  end

  def menu_quit(&cb_quit)
    @quitcallback = cb_quit
  end
end