# frozen_string_literal: true

require_relative 'exact_match_strategy'

module ProfanityFilterEngine
  class AllowDuplicateCharactersStrategy < ExactMatchStrategy
    DEFAULT_IGNORE_CASE = true

    private

    def build_word_regexp(word)
      word.chars.map { |char| Regexp.escape(char) + '+' }.join
    end
  end
end
