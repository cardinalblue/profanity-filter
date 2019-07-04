# frozen_string_literal: true

require_relative 'regexp_strategy'

module ProfanityFilterEngine
  class ExactMatchStrategy < RegexpStrategy
    DELIMITER = '(?:\b|^|$|_)'
    DEFAULT_IGNORE_CASE = false

    attr_reader :delimiter
    attr_reader :ignore_case

    def initialize(dictionary:, ignore_case: DEFAULT_IGNORE_CASE)
      @dictionary = dictionary
      @delimiter = DELIMITER
      @ignore_case = ignore_case
      @profanity_regexp = build_profanity_regexp
    end

    private

    def build_profanity_regexp
      option = ignore_case ? Regexp::IGNORECASE : nil
      regexp_list = dictionary.map do |word|
        Regexp.new("#{delimiter}#{build_word_regexp(word)}#{delimiter}", option)
      end

      Regexp.union(*regexp_list)
    end

    def build_word_regexp(word)
      Regexp.escape(word)
    end
  end
end
