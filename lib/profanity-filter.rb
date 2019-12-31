# frozen_string_literal: true

require 'profanity-filter/version'
require 'profanity-filter/engines/composite'
require 'profanity-filter/engines/partial_match_strategy'
require 'profanity-filter/engines/allow_duplicate_characters_strategy'
require 'profanity-filter/engines/allow_symbols_in_words_strategy'
require 'profanity-filter/engines/leet_exact_match_strategy'
require 'web_purify'

class ProfanityFilter
  WP_DEFAULT_LANGS    = [:en].freeze
  WP_LANG_CONVERSIONS = { es: :sp, ko: :kr, ja: :jp }.freeze
  WP_AVAILABLE_LANGS  = [
    :en, :ar, :fr, :de, :hi, :jp, :it, :pt, :ru, :sp, :th, :tr, :zh, :kr, :pa
  ].freeze

  attr_reader :available_strategies

  def initialize(web_purifier_api_key: nil, whitelist: [])
    # If we are using Web Purifier
    @wp_client = web_purifier_api_key ? WebPurify::Client.new(web_purifier_api_key) : nil
    @whitelist = whitelist
    raise 'Whitelist should be an array' unless @whitelist.is_a?(Array)

    exact_match_dictionary = load_exact_match_dictionary
    partial_match_dictionary = load_partial_match_dictionary

    @available_strategies = {
      allow_symbol: ::ProfanityFilterEngine::AllowSymbolsInWordsStrategy.new(
        dictionary:  exact_match_dictionary,
        ignore_case: true
      ),
      duplicate_characters: ::ProfanityFilterEngine::AllowDuplicateCharactersStrategy.new(
        dictionary:  exact_match_dictionary,
        ignore_case: true
      ),
      leet: ::ProfanityFilterEngine::LeetExactMatchStrategy.new(
        dictionary:  exact_match_dictionary,
        ignore_case: true
      ),
      partial_match: ::ProfanityFilterEngine::PartialMatchStrategy.new(
        dictionary:  partial_match_dictionary + exact_match_dictionary,
        ignore_case: true
      ),
    }
  end

  def all_strategy_names
    available_strategies.keys
  end

  def profane?(phrase, lang: nil, strategies: :all)
    return false if phrase == ''
    return false if @whitelist.include?(phrase)

    if use_webpurify?
      !!(pf_profane?(phrase, strategies: strategies) || wp_profane?(phrase, lang: lang))
    else
      !!pf_profane?(phrase, strategies: strategies)
    end
  end

  def profanity_count(phrase, lang: nil, strategies: :all)
    return 0 if phrase == '' || phrase.nil?

    pf_count = pf_profanity_count(phrase, strategies: strategies)
    if use_webpurify?
      pf_count.zero? ? wp_profanity_count(phrase, lang: lang).to_i : pf_count
    else
      pf_count
    end
  end

  private

  def use_webpurify?
    !!@wp_client
  end

  def filter(strategies:)
    ::ProfanityFilterEngine::Composite.new.tap do |engine|
      if strategies == :all
        engine.add_strategies(*available_strategies.values)
      else
        strategies.each do |strategy|
          strategy = strategy.to_sym
          raise "Strategy name \"#{strategy}\" not supported." unless all_strategies.include?(strategy)

          engine.add_strategy(available_strategies[strategy])
        end
      end
    end
  end

  def pf_profane?(phrase, strategies:)
    filter(strategies: strategies).profane?(phrase)
  end

  def pf_profanity_count(phrase, strategies:)
    filter(strategies: strategies).profanity_count(phrase)
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
  rescue StandardError
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
