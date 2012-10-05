# -*- encoding : utf-8 -*-
require 'charlock_holmes/string'

class String
  def default_encoding!
    default_encoding = Encoding.default_internal || Encoding::UTF_8
    if ascii_only? # no need to encode if ascii
      force_encoding(default_encoding)
    else # should encode
      options = {:invalid => :replace, :undef => :replace, :replace => ''}
      if (detected = detect_encoding) && detected[:encoding]
        force_encoding(detected[:encoding]).encode!(default_encoding, detected[:encoding], options)
      end
      # re-encode through UTF-16 to filter incorrect symbols
      encode!(Encoding::UTF_16, default_encoding, options).encode!(default_encoding, Encoding::UTF_16)
      raise unless valid_encoding? # check result
    end
    self
  rescue
    replace "--broken encoding: #{detect_encoding[:encoding] || 'unknown'}"
  # ensure
  #   return self
  end

  # same as reverse.truncate.reverse
  def rtruncate(length, options = {})
    text = self.dup
    options[:omission] ||= "..."
    options[:separator] ||= '/'

    length_with_room_for_omission = length - options[:omission].mb_chars.length
    chars = text.mb_chars
    stop = options[:separator] ?
      (chars.index(options[:separator].mb_chars, length_with_room_for_omission) || length_with_room_for_omission) : length_with_room_for_omission

    (chars.length > length ? "#{options[:omission]}#{chars[-(stop+1)...-1]}" : text).to_s
  end
end
