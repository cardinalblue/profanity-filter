# frozen_string_literal: true

require_relative '../test_helper'

module ProfanityFilterEngine
  class AllowSymbolsInWordsStrategyTest < Minitest::Test
    def test_different_latin_like_characters
      varients_struct = Struct.new(:o, :a)
      o_vals = %w(o ó ø)
      a_vals = %w(a á å)
      o_vals.product(a_vals).each do |vars_arr|
        vars = varients_struct.new(*vars_arr)
        o = vars.o
        big_o = o.upcase
        a = vars.a
        big_a = a.upcase

        strategy = ::ProfanityFilterEngine::AllowSymbolsInWordsStrategy.new(
          dictionary: ["f#{o}#{o}", "b#{a}r"],
          ignore_case: true
        )

        foo_text = "f f#{o}  f#{o}#{o}"
        assert_equal ["f#{o}#{o}"], strategy.profane_words(foo_text)
        assert_equal 1, strategy.profanity_count(foo_text)
        assert strategy.profane?(foo_text)

        # it should ignore case
        foo_bar_upcase_text = "f#{big_o}#{o} B#{big_a}R"
        assert_equal ["f#{big_o}#{o}", "B#{big_a}R"], strategy.profane_words(foo_bar_upcase_text)
        assert_equal 2, strategy.profanity_count(foo_bar_upcase_text)
        assert strategy.profane?(foo_bar_upcase_text)

        # space inside the word should be matched
        ["f #{o}#{o}", "f #{o} #{o}", "b   #{a} r"].each do |text|
          assert_equal [text], strategy.profane_words(text)
          assert_equal 1, strategy.profanity_count(text)
          assert strategy.profane?(text)
        end

        # symbol inside the word should be matched
        %w(~ ` ! @ # $ % ^ & * ( ) _ + { } | \ [ ] " ' : ; < > ? , . / ¿ ¡).each do |symbol|
          text = "f#{symbol}#{o}#{symbol * 2}#{o}"
          assert_equal [text], strategy.profane_words(text)
          assert_equal 1, strategy.profanity_count(text)
          assert strategy.profane?(text)
        end

        # sub-string should not be matched
        fooo_bbar_text = "f#{o}#{o}#{o} bb#{a}r"
        assert_empty strategy.profane_words(fooo_bbar_text)
        assert_equal 0, strategy.profanity_count(fooo_bbar_text)
        refute strategy.profane?(fooo_bbar_text)

        # character but non-English should not be matched
        non_english_text = "f#{o}你好#{o} bニクキュウ#{a}r"
        assert_empty strategy.profane_words(non_english_text)
        assert_equal 0, strategy.profanity_count(non_english_text)
        refute strategy.profane?(non_english_text)
      end
    end
  end
end
