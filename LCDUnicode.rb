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
    last = nil
    text.each_codepoint do |char|
      if @mapping['encoding']['multibyte'].has_key?(char)
        last = char
        next
      end
      encoded += self._getMapping(char, last)
      last = nil
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
  def _getMapping(char, last = nil)

    if @mapping['encoding'].has_key?(char) or
      (@mapping['encoding']['multibyte'].has_key?(last) and
       @mapping['encoding']['multibyte'][last].has_key?(char))

      if last != nil
        pp "#{last.chr} #{char.chr} | #{last} #{char}"
        mapped = @mapping['encoding']['multibyte'][last][char]
      else
        mapped = @mapping['encoding'][char]
      end

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