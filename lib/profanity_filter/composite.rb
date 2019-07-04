# frozen_string_literal: true

require 'yaml'
require_relative 'component'

module ProfanityFilterEngine
  class Composite < Component
    attr_reader :strategies

    def initialize
      @strategies = []
    end

    def add_strategy(strategy)
      strategies << strategy
    end

    def add_strategies(*new_strategies)
      strategies.concat(new_strategies)
    end

    def delete_strategy(strategy)
      strategies.delete(strategy)
    end

    def profane?(text)
      strategies.any? { |strategy| strategy.profane?(text) }
    end

    def profane_words(text)
      total_words = strategies.reduce([]) do |words, strategy|
        words.concat(strategy.profane_words(text))
      end
      total_words.uniq
    end
  end
end
