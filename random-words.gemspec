# frozen_string_literal: true

require_relative 'lib/random-words/version'

Gem::Specification.new do |spec|
  spec.name = 'random-words'
  spec.version = RandomWords::VERSION
  spec.author = 'Brett Terpstra'
  spec.email = 'me@brettterpstra.com'

  spec.summary = 'Random words generator'
  spec.description = 'Generate random text (lorem ipsum) from a variety of sources. Can be used to generate random words, sentences, or paragraphs.'
  spec.homepage = 'https://github.com/ttscoff/random-words'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = "#{spec.metadata['source_code_uri']}/issues"
  spec.metadata['changelog_uri'] = "#{spec.metadata['source_code_uri']}/blob/main/CHANGELOG.md"
  spec.metadata['github_repo'] = 'git@github.com:ttscoff/random-words.git'

  spec.require_paths << 'lib'
  spec.extra_rdoc_files = ['README.md']
  spec.rdoc_options << '--title' << 'Random Words' << '--main' << 'README.md' << '--markup' << 'markdown'

  spec.bindir = 'bin'
  spec.executables << 'randw'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.strip =~ %r{^((test|spec|features)/|\.git|buildnotes|.*\.taskpaper)} }
  end

  spec.metadata['rubygems_mfa_required'] = 'true'
end
