# frozen_string_literal: true

require_relative '../test_helper'

module ProfanityFilterEngine
  class CompositeTest < Minitest::Test
    def setup
      super
      @exact_match_strategy = ::ProfanityFilterEngine::ExactMatchStrategy.new(
        dictionary: %w(foo bar),
        ignore_case: true
      )
      @partial_match_strategy = ::ProfanityFilterEngine::PartialMatchStrategy.new(
        dictionary: %w(🖕),
        ignore_case: true
      )
      @composite = ::ProfanityFilterEngine::Composite.new
    end

    def test_add_strategy
      @composite.add_strategy(@exact_match_strategy)
      assert_equal [@exact_match_strategy], @composite.strategies
    end

    def test_add_strategies
      @composite.add_strategies(@exact_match_strategy, @partial_match_strategy)
      assert_equal [@exact_match_strategy, @partial_match_strategy], @composite.strategies

      new_composite = Composite.new
      new_composite.add_strategies([@exact_match_strategy, @partial_match_strategy])
      assert_equal [@exact_match_strategy, @partial_match_strategy], @composite.strategies
    end

    def test_delete_strategy
      @composite.add_strategies(@exact_match_strategy, @partial_match_strategy)
      assert_equal [@exact_match_strategy, @partial_match_strategy], @composite.strategies
      @composite.delete_strategy(@exact_match_strategy)
      assert_equal [@partial_match_strategy], @composite.strategies
    end

    def test_profane?
      @composite.add_strategies(@exact_match_strategy, @partial_match_strategy)

      profane_foo_text = 'foo is a foo.'
      assert @composite.profane?(profane_foo_text)

      profane_emoji_text = '🖕 is a middle finger.'
      assert @composite.profane?(profane_emoji_text)

      profane_foo_and_emoji_text = 'foo and 🖕 are profane.'
      assert @composite.profane?(profane_foo_and_emoji_text)

      safe_text = 'I like 🐈.'
      refute @composite.profane?(safe_text)
    end

    def test_profane_words
      @composite.add_strategies(@exact_match_strategy, @partial_match_strategy)

      profane_foo_text = 'foo is a foo.'
      assert_equal %w(foo), @composite.profane_words(profane_foo_text)

      profane_emoji_text = '🖕 is a middle finger.'
      assert_equal %w(🖕), @composite.profane_words(profane_emoji_text)

      profane_foo_and_emoji_text = 'foo and 🖕 are profane.'
      assert_equal %w(foo 🖕), @composite.profane_words(profane_foo_and_emoji_text)

      safe_text = 'I like 🐈.'
      assert_empty @composite.profane_words(safe_text)
    end

    def test_profanity_count
      @composite.add_strategies(@exact_match_strategy, @partial_match_strategy)

      profane_foo_text = 'foo is a foo.'
      assert_equal 1, @composite.profanity_count(profane_foo_text)

      profane_emoji_text = '🖕 is a middle finger.'
      assert_equal 1, @composite.profanity_count(profane_emoji_text)

      profane_foo_and_emoji_text = 'foo and 🖕 are profane.'
      assert_equal 2, @composite.profanity_count(profane_foo_and_emoji_text)

      safe_text = 'I like 🐈.'
      assert_equal 0, @composite.profanity_count(safe_text)
    end
  end
end
