# frozen_string_literal: true

require_relative '../test_helper'

module ProfanityFilterEngine
  class AllowDuplicateCharactersStrategyTest < Minitest::Test
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

        strategy = ::ProfanityFilterEngine::AllowDuplicateCharactersStrategy.new(
          dictionary: ["f#{o}#{o}", "b#{a}r"],
          ignore_case: true
        )

        %W(f f#{o} ff#{o}).each do |text|
          assert_equal [], strategy.profane_words(text)
          assert_equal 0, strategy.profanity_count(text)
          refute strategy.profane?(text)
        end

        %W(f#{o}#{o} ff#{o}#{o} f#{o}#{o}#{o}#{o} b#{a}r b#{a}#{a}r).each do |text|
          assert_equal [text], strategy.profane_words(text)
          assert_equal 1, strategy.profanity_count(text)
          assert strategy.profane?(text)
        end

        foo_bar_upcase_text = "f#{big_o}#{o} B#{big_a}R"
        assert_equal ["f#{big_o}#{o}", "B#{big_a}R"], strategy.profane_words(foo_bar_upcase_text)
        assert_equal 2, strategy.profanity_count(foo_bar_upcase_text)
        assert strategy.profane?(foo_bar_upcase_text)

        # sub-string should not be matched
        fooo_bbar_text = "f#{o}#{o}k xb#{a}r"
        assert_empty strategy.profane_words(fooo_bbar_text)
        assert_equal 0, strategy.profanity_count(fooo_bbar_text)
        refute strategy.profane?(fooo_bbar_text)

        # space and symbol inside the word should not be matched
        symbols = %w(~ ` ! @ # $ % ^ & * ( ) _ + { } | \ [ ] " ' : ; < > ? , . / ¿ ¡)
        foo_with_symbol_text = symbols.reduce("f #{o}#{o}") do |meme, symbol|
          meme + " f#{symbol}#{o}#{o}"
        end
        assert_empty strategy.profane_words(foo_with_symbol_text)
        assert_equal 0, strategy.profanity_count(foo_with_symbol_text)
        refute strategy.profane?(foo_with_symbol_text)
      end
    end
  end
end
