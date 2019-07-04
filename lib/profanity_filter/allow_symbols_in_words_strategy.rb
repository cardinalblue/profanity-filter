# frozen_string_literal: true

require_relative 'exact_match_strategy'

module ProfanityFilterEngine
  class AllowSymbolsInWordsStrategy < ExactMatchStrategy
    SYMBOLS_REGEXP = '(?:\p{Mark}|\p{Separator}|\p{Symbol}|\p{Punctuation})*'
    DEFAULT_IGNORE_CASE = true

    private

    def build_word_regexp(word)
      word.chars.map { |char| Regexp.escape(char) }.join(SYMBOLS_REGEXP)
    end
  end
end
