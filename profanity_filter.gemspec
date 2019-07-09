lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'profanity_filter/version'

Gem::Specification.new do |spec|
  spec.name          = 'profanity_filter'
  spec.version       = ProfanityFilter::VERSION
  spec.authors       = ['Maso Lin', 'Jenny Shih']
  spec.email         = ['dev@cardinalblue.com']

  spec.summary       = 'To detect if a given string contains profane words.'
  spec.description   = 'Detects profane words using multiple strategies,
                        including similarities, diacritics(sound alterations),
                        constructions (multi-part), injections and unicode.'
  spec.homepage      = 'https://github.com/cardinalblue/profanity-filter'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/cardinalblue/profanity-filter'
  spec.metadata['changelog_uri'] = 'https://github.com/cardinalblue/profanity-filter/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'webpurify'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rr'
end
