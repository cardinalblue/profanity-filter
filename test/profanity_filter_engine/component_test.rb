# frozen_string_literal: true

require_relative '../test_helper'
require 'rr'

module ProfanityFilterEngine
  class ComponentTest < Minitest::Test
    def setup
      super
      @c = ::ProfanityFilterEngine::Component.new
    end
    def test_profane?
      assert_raises NotImplementedError do
        @c.profane?('foo')
      end
    end

    def test_profane_words
      assert_raises NotImplementedError do
        @c.profane_words('foo')
      end
    end

    def test_profanity_count
      mock(@c).profane_words('foo bar') { ['foo', 'bar'] }
      assert_equal 2, @c.profanity_count('foo bar')
    end
  end
end
