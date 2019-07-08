# frozen_string_literal: true

require_relative '../test_helper'

module ProfanityFilterEngine
  class RegexpStrategyTest < Minitest::Test
    FAKE_WORDS = %w(foo bar)

    def setup
      @fake_strategy = ::ProfanityFilterEngine::RegexpStrategy.new(
        dictionary: FAKE_WORDS,
        profanity_regexp: /foo|bar/
      )
      @foo_bar_text = 'foo and bar are not animals.'
      @cat_text = 'cat is a cute animal.'
      super
    end

    def test_profanity_regexp
      expected_regexp = Regexp.union(FAKE_WORDS)
      assert_equal expected_regexp, @fake_strategy.profanity_regexp
    end

    def test_profane?
      assert @fake_strategy.profane?(@foo_bar_text)
      refute @fake_strategy.profane?(@cat_text)
    end

    def test_profane_words
      assert_equal %w(foo bar), @fake_strategy.profane_words(@foo_bar_text)
      assert_equal [], @fake_strategy.profane_words(@cat_text)
    end

    def test_profanity_count
      assert_equal 2, @fake_strategy.profanity_count(@foo_bar_text)
      assert_equal 0, @fake_strategy.profanity_count(@cat_text)
    end
  end
end
