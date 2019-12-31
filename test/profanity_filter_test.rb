# frozen_string_literal: true

require 'test_helper'
require 'web_purify'
require 'rr'
require 'pry'

class ProfanityFilterTest < Minitest::Test
  def setup
    @filter = ProfanityFilter.new
    @filter_with_wp = ProfanityFilter.new(web_purifier_api_key: 'fake_api_key')
  end

  def test_that_it_has_a_version_number
    refute_nil ::ProfanityFilter::VERSION
  end

  def test_profanity_with_default_config
    prepare_profane_words

    @profanity_one_match.each do |word|
      assert @filter.profane?(word)
      assert_equal 1, @filter.profanity_count(word)
    end

    @profanity_two_matches.each do |word|
      assert @filter.profane?(word)
      assert_equal 2, @filter.profanity_count(word)
    end

    assert @filter.profane?(@profanity_five_matches_with_emoji)
    assert_equal 5, @filter.profanity_count(@profanity_five_matches_with_emoji)

    @not_profane_words.each do |word|
      refute @filter.profane? word
    end
  end

  def test_profanity_wp_enabled
    prepare_profane_words

    @not_profane_words.each do |word|
    any_instance_of(WebPurify::Client) do |wp_client|
          mock(wp_client).check_count(word, lang: expected_langs(:en)) { 0 }.once
        refute @filter_with_wp.profane? word
      end
    end
  end

  def test_profanity_with_unsupported_whitelist_format
    assert_raises do
      ProfanityFilter.new(whitelist: 'unsupported')
    end
  end

  def test_profanity_with_whitelist
    profane_word = 'shit'
    assert ProfanityFilter.new.profane?(profane_word)
    refute ProfanityFilter.new(whitelist: [profane_word]).profane?(profane_word)
  end

  def test_config_strategies_with_nonexistent_name_throws_exception
    assert_raises do
      @filter.profane?('_', strategies: 'nonexistent')
    end
  end

  def test_config_with_one_strategy
    duplicated_profane_word = 'shhhhhhit'
    refute @filter.profane?(duplicated_profane_word, strategies: [])
    assert @filter.profane?(duplicated_profane_word, strategies: [:duplicate_characters])

    allow_symbol_profane_word = 's@h@i@t'
    refute @filter.profane?(allow_symbol_profane_word, strategies: [])
    assert @filter.profane?(allow_symbol_profane_word, strategies: [:allow_symbol])

    leet_profane_word = 'sĦit'
    refute @filter.profane?(leet_profane_word, strategies: [])
    assert @filter.profane?(leet_profane_word, strategies: [:leet])

    partial_match_profane_word = 'random🖕 string'
    refute @filter.profane?(partial_match_profane_word, strategies: [])
    assert @filter.profane?(partial_match_profane_word, strategies: [:partial_match])
  end

  def test_config_with_basic_and_all_strategies
    # :basic strategies is the legacy 'tolerant' filter,
    # containing 'allow_symbol' and 'partial match' strategies.
    # :all strategies is the legacy 'strict' filter,
    # containing all four strategies.

    only_strict_profane_texts = [
      'You are s.h-!7!',
      'You are ssshiiittt!',
    ]

    only_strict_profane_texts.each do |word|
      assert_equal 0, @filter.profanity_count(word, strategies: :basic)
      assert_equal 1, @filter.profanity_count(word, strategies: :all)

      refute @filter.profane?(word, strategies: :basic)
      assert @filter.profane?(word, strategies: :all)
    end
  end

  def test_wp_profanity_count
    profanity_0 = 'hi'
    profanity_1 = 'tits'
    profanity_2 = 'tits fuck'
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count(profanity_0, lang: expected_langs(:en)) { 0 }.once
      mock(wp_client).check_count(profanity_1, lang: expected_langs(:en)) { 1 }.once
      mock(wp_client).check_count(profanity_2, lang: expected_langs(:en)) { 2 }.once
    end

    assert 0, @filter_with_wp.send('wp_profanity_count', profanity_0)
    assert 1, @filter_with_wp.send('wp_profanity_count', profanity_1)
    assert 2, @filter_with_wp.send('wp_profanity_count', profanity_2)
  end

  def test_WebPurify_request_timeout
    # Test if the process of checking profanity of words with WebPurify will
    # auto-terminate, if it exceeds a fixed amount of time (5 seconds).
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('tits', lang: expected_langs(:en)) { sleep(0.2); 1 }
    end

    assert !@filter_with_wp.send('wp_profane?', 'tits', lang: 'bogus', timeout_duration: 0.1)

    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('tits', lang: expected_langs(:en)) { 1 }
    end
    assert @filter_with_wp.send('wp_profane?', 'tits', lang: 'bogus', timeout_duration: 0.1)
  end

  def test_wp_profane_default_language
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('tits', lang: expected_langs(:en)) { 1 }
    end
    assert @filter_with_wp.send('wp_profane?', 'tits', lang: 'bogus')
  end

  def test_wp_profane_with_a_language_not_recognized_by_WebPurify
    # Test if the language codes that are send to the WebPurify API are
    # the ones that it recognized (e.g. :sp instead of :es).
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('el tittos', lang: expected_langs(:sp)) { 1 }
    end
    assert @filter_with_wp.send('wp_profane?', 'el tittos', lang: :es)
  end

  def test_wp_profane_with_a_long_language_code
    # Test if the language codes that are send to the WebPurify API are
    # the ones that it recognized (e.g. :sp instead of :es).
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('tittou', lang: expected_langs(:zh)) { 1 }
    end
    assert @filter_with_wp.send('wp_profane?', 'tittou', lang: 'zh-Hant')
  end

  def test_profane_should_not_fail_if_lang_nil
    any_instance_of(WebPurify::Client) do |wp_client|
      mock(wp_client).check_count('bogus', lang: expected_langs) { 1 }
    end
    assert_silent do
      @filter_with_wp.profane? 'bogus', lang: nil
    end
  end

  def test_profane_and_profanity_count_when_web_purify_fails
    mock.instance_of(WebPurify::Client).check_count(anything, anything) do
      raise StandardError
    end.times(2)

    assert_equal false, @filter_with_wp.profane?('foo')
    assert_equal 0, @filter_with_wp.profanity_count('foo')
  end

  private

  def prepare_profane_words
    @profanity_one_match = [
      'bullshit',
      'fuck',
      'f.u.c.k',
      'f uck',
      'FUCK',
      'FU-CK',
      'Fu-cK',
      'badmotherfucker',
      'bad.mother*fu-c_ker',
      'fu-ckpolitics',
      'fuc kpolitics',
      'bull shit',
      'bull-shit',
    ]

    @profanity_two_matches = [
      'FUCK_THIS_SHIT',
      'FuCk_THiS_shIT',
      'fU_cK_THIS_shI_T',
      'bad mothe rfucker',
      '`F:+![U__@C]?#-k.<$}t%H,"i^_S&|s{*H>(i)=~T;',
    ]

    @profanity_five_matches_with_emoji = 'You areshit! 🖕  s*h!i-- t sh !7 sshhiiit sh!7'

    @not_profane_words = %w(basses phuket)
  end

  def with_webpurify
    begin
      AppConfig[:webpurify_filtering] = true
      yield
    ensure
      AppConfig.delete :webpurify_filtering
    end
  end

  def expected_langs lang = nil
    (ProfanityFilter::WP_DEFAULT_LANGS + [lang]).to_a.uniq.compact.join(',')
  end
end

