[![Gem Version](https://badge.fury.io/rb/profanity-filter.svg)](https://badge.fury.io/rb/profanity-filter)

## Profanity Filter
Strategies to publish offensive texts online can be roughly grouped into 5 categories:
1. Similarities, eg. b ⇔ 6
2. Diacritics(sound alteration), eg. u ⇔ ü, ù, ú
3. Constructions(multi-part), eg. W ⇔ VV, V ⇔ \/
4. Injections, eg. s-h-i-t, shhhhhhhhhhhit
5. Unicode(same shape but different unicode), eg ⒜, ⍺, ａ, 𝐚, 𝑎, 𝒂, 𝒶, 𝓪, 𝔞, 𝕒, 𝖆, 𝖺, 𝗮, 𝘢, 𝙖

This profanity filter implements:
- [Full Support] diacritics, injections, unicode
- [Partial Support] similarities, constructions

This gem is also integrated with [Web Purify](https://www.webpurify.com). Usage example below.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'profanity-filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install profanity-filter

## Usage

```ruby
# without WebPurify 
pf = ProfanityFilter.new

# with WebPurify
pf = ProfanityFilter.new(web_purifier_api_key: [YOUR-API-KEY])

pf.profane? ('ssssshit')
# => true

pf.profanity_count('fjsdio fdsk fU_cK_THIS_shI_T')
# => 2
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cardinalblue/profanity-filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ProfanityFilter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cardinalblue/profanity-filter/blob/master/CODE_OF_CONDUCT.md).
