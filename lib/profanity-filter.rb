# frozen_string_literal: true

require 'profanity-filter/version'
require 'profanity-filter/engines/composite'
require 'profanity-filter/engines/partial_match_strategy'
require 'profanity-filter/engines/allow_duplicate_characters_strategy'
require 'profanity-filter/engines/allow_symbols_in_words_strategy'
require 'profanity-filter/engines/leet_exact_match_strategy'
require 'web_purify'

class ProfanityFilter
  WP_DEFAULT_LANGS = [:en].freeze
  WP_AVAILABLE_LANGS = [
    :en, :ar, :fr, :de, :hi, :jp, :it, :pt, :ru, :sp, :th, :tr, :zh, :kr, :pa
  ].freeze
  WP_LANG_CONVERSIONS = { es: :sp, ko: :kr, ja: :jp }.freeze

  attr_reader :strict_filter, :tolerant_filter

  def initialize(web_purifier_api_key: nil)
    # If we are using Web Purifier
    @wp_client = web_purifier_api_key ? WebPurify::Client.new(web_purifier_api_key) : nil

    exact_match_dictionary = load_exact_match_dictionary
    partial_match_dictionary = load_partial_match_dictionary

    allow_symbol_strategy = ::ProfanityFilterEngine::AllowSymbolsInWordsStrategy.new(
      dictionary: exact_match_dictionary,
      ignore_case: true
    )
    duplicate_characters_strategy = ::ProfanityFilterEngine::AllowDuplicateCharactersStrategy.new(
      dictionary: exact_match_dictionary,
      ignore_case: true
    )
    leet_strategy = ::ProfanityFilterEngine::LeetExactMatchStrategy.new(
      dictionary: exact_match_dictionary,
      ignore_case: true
    )
    partial_match_strategy = ::ProfanityFilterEngine::PartialMatchStrategy.new(
      dictionary: partial_match_dictionary,
      ignore_case: true
    )

    # Set up strict filter.
    @strict_filter = ::ProfanityFilterEngine::Composite.new
    @strict_filter.add_strategies(
      leet_strategy,
      allow_symbol_strategy,
      partial_match_strategy,
      duplicate_characters_strategy
    )
    # Set up tolerant filter.
    @tolerant_filter = ::ProfanityFilterEngine::Composite.new
    @tolerant_filter.add_strategies(
      allow_symbol_strategy,
      partial_match_strategy
    )
  end

  def profane?(phrase, lang: nil, strictness: :tolerant)
    return false if phrase == '' || phrase.nil?

    is_profane = pf_profane?(phrase, strictness: strictness)
    if !is_profane && use_webpurify?
      wp_is_profane = wp_profane?(phrase, lang: lang)
      is_profane = wp_is_profane unless wp_is_profane.nil?
    end

    !!is_profane
  end

  def profanity_count(phrase, lang: nil, strictness: :tolerant)
    return 0 if phrase == '' || phrase.nil?

    banned_words_count = pf_profanity_count(phrase, strictness: strictness)
    if banned_words_count == 0 && use_webpurify?
      wp_banned_words_count = wp_profanity_count(phrase, lang: lang)
      banned_words_count = wp_banned_words_count unless wp_banned_words_count.nil?
    end

    banned_words_count
  end

  private

  def use_webpurify?
    !!@wp_client
  end

  def filter(strictness: :tolerant)
    case strictness
    when :strict
      @strict_filter
    when :tolerant
      @tolerant_filter
    else
      @tolerant_filter
    end
  end

  def pf_profane?(phrase, strictness: :tolerant)
    filter(strictness: strictness).profane?(phrase)
  end

  def pf_profanity_count(phrase, strictness: :tolerant)
    filter(strictness: strictness).profanity_count(phrase)
  end

  def wp_profane?(phrase, lang: nil, timeout_duration: 5)
    profanity_count = wp_profanity_count(phrase, lang: lang, timeout_duration: timeout_duration)

    if profanity_count.nil? || profanity_count == 0
      false
    else
      true
    end
  end

  def wp_profanity_count(phrase, lang: nil, timeout_duration: 5)
    Timeout::timeout(timeout_duration) do
      @wp_client.check_count phrase, lang: wp_langs_list_with(lang)
    end
  rescue StandardError => e
    nil
  end

  def wp_langs_list_with(lang)
    langs = Set.new(WP_DEFAULT_LANGS)

    if lang
      lang = shorten_language(lang).to_sym
      lang = WP_LANG_CONVERSIONS[lang] || lang
      if WP_AVAILABLE_LANGS.include?(lang)
        langs << lang
      end
    end

    langs.to_a.join(',')
  end

  def load_dictionary(file_path)
    dir = File.dirname(__FILE__)
    YAML.load(File.read("#{dir}/profanity-dictionaries/#{file_path}.yaml"))
  end

  def load_exact_match_dictionary
    en_dictionary = load_dictionary('en')
    es_dictionary = load_dictionary('es')
    pt_dictionary = load_dictionary('pt')
    en_dictionary + es_dictionary + pt_dictionary
  end

  def load_partial_match_dictionary
    load_dictionary('partial_match')
  end

  def shorten_language(lang)
    lang && lang.to_s.downcase[0, 2]
  end
end
