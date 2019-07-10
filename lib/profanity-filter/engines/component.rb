# frozen_string_literal: true

module ProfanityFilterEngine
  class Component
    def profane?(text)
      raise NotImplementedError
    end

    def profane_words(text)
      raise NotImplementedError
    end

    def profanity_count(text)
      profane_words(text).size
    end
  end
end
