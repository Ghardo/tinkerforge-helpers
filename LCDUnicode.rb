#!/usr/bin/env ruby
# -*- ruby encoding: utf-8 -*-

class LCDUnicode
  def initialize(config, lcd)

    if !File.exists?(config)
      raise "config file #{config} does not exists or readable"
    end
    @mapping = YAML.load_file(config)
    self._initCustomCharacters(lcd)
  end

  def encode(text)
    encoded = ''
    text.each_codepoint do |char|
      encoded += self._getMapping(char)
    end

    return encoded
  end

  def custom(name)
    index = @mapping['custom'].keys.index(name)
    if index == nil
      raise "unknown custom character '#{name}'"
    end
    return (8 + index).chr
  end

  protected
  def _getMapping(char)
    if @mapping['encoding'].has_key? char
      mapped = @mapping['encoding'][char]
      if mapped.is_a? Integer
        c = mapped.chr
      else
        c = self.custom(mapped)
      end
    else
      c = char.chr
    end

    return c
  end

  def _initCustomCharacters(lcd)
     index = 0
     @mapping['custom'].each do |custom|
      lcd.device.set_custom_character index, custom[1]
      index += 1
     end
  end
end