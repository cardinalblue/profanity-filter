# frozen_string_literal: true

require_relative 'component'

module ProfanityFilterEngine
  class RegexpStrategy < Component
    DEFAULT_DELIMITER = '(?:\b|^|$|_)'

    attr_reader :dictionary, :profanity_regexp

    attr_writer :profanity_regexp
    private :profanity_regexp=

    def initialize(dictionary:, profanity_regexp: nil)
      @dictionary = dictionary
      @profanity_regexp = profanity_regexp || build_profanity_regexp
    end

    def profane_words(text)
      text.scan(profanity_regexp).uniq
    end

    def profane?(text)
      profanity_regexp.match?(text)
    end

    private

    def build_profanity_regexp
      regexp_list = dictionary.map do |word|
        Regexp.new("#{DEFAULT_DELIMITER}#{Regexp.escape(word)}#{DEFAULT_DELIMITER}")
      end

      Regexp.union(*regexp_list)
    end
  end
end
