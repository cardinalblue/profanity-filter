# frozen_string_literal: true

require_relative 'exact_match_strategy'

module ProfanityFilterEngine
  class LeetExactMatchStrategy < ExactMatchStrategy
    DEFAULT_IGNORE_CASE = true

    private

    def build_word_regexp(word)
      build_leet_dictionary unless defined? LEET_DICTIONARY
      word.chars.map do |char|
        downcase_char = char.downcase
        if LEET_DICTIONARY.include?(downcase_char)
          LEET_DICTIONARY[downcase_char]
        else
          Regexp.escape(char)
        end
      end.join
    end

    def build_leet_dictionary
      lib_dir  = File.expand_path('../../../', __FILE__)
      file     = File.read("#{lib_dir}/profanity-dictionaries/leet_strategy_dictionary.yaml")
      raw_data = YAML.safe_load(file)
      dict     = transform_data_to_regex(raw_data)
      ::ProfanityFilterEngine::LeetExactMatchStrategy.const_set('LEET_DICTIONARY', dict)
    end

    def transform_data_to_regex(dict)
      dict.map do |char, data|
        data_str = data.join('|')
        dict[char] = "(?:#{data_str})"
      end
      dict
    end
  end
end
