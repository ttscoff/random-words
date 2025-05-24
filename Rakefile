require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'standard/rake'
require 'yard'
require 'tty-spinner'
require 'English'

## Docker error class
class DockerError < StandardError
  def initialize(msg = nil)
    msg = msg ? "Docker error: #{msg}" : 'Docker error'
    super
  end
end

# task :doc, [*Rake.application[:yard].arg_names] => [:yard]

Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.rdoc_files.include('README.rdoc', 'lib/**/*.rb', 'bin/**/*')
  rd.title = 'RandomWords'
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/random-words/**/*.rb']
  t.options = ['--markup-provider=redcarpet', '--markup=markdown', '--no-private', '-p', 'yard_templates']
  # t.stats_options = ['--list-undoc']
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/**/*_spec.rb'
end

task default: %i[test]

desc 'Alias for build'
task package: :build

task test: 'spec'
task lint: 'standard'
task format: 'standard:fix'

desc 'Open an interactive ruby console'
task :console do
  require 'irb'
  require 'bundler/setup'
  require 'random-words'
  ARGV.clear
  IRB.start
end

desc 'Development version check'
task :ver do
  gver = `git ver`
  cver = IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).match(/^#+ (\d+\.\d+\.\d+(\w+)?)/)[1]
  res = `grep VERSION lib/random-words/version.rb`
  version = res.match(/VERSION *= *['"](\d+\.\d+\.\d+(\w+)?)/)[1]
  puts "git tag: #{gver}"
  puts "version.rb: #{version}"
  puts "changelog: #{cver}"
end

desc 'Changelog version check'
task :cver do
  puts IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).match(/^#+ (\d+\.\d+\.\d+(\w+)?)/)[1]
end

desc 'Bump incremental version number'
task :bump, :type do |_, args|
  args.with_defaults(type: 'inc')
  version_file = 'lib/random-words/version.rb'
  content = IO.read(version_file)
  content.sub!(/VERSION = '(?<major>\d+)\.(?<minor>\d+)\.(?<inc>\d+)(?<pre>\S+)?'/) do
    m = Regexp.last_match
    major = m['major'].to_i
    minor = m['minor'].to_i
    inc = m['inc'].to_i
    pre = m['pre']

    case args[:type]
    when /^maj/
      major += 1
      minor = 0
      inc = 0
    when /^min/
      minor += 1
      inc = 0
    else
      inc += 1
    end

    $stdout.puts "At version #{major}.#{minor}.#{inc}#{pre}"
    "VERSION = '#{major}.#{minor}.#{inc}#{pre}'"
  end
  File.open(version_file, 'w+') { |f| f.puts content }
end

desc 'Run tests in Docker'
task :dockertest, :version, :login, :attempt do |_, args|
  args.with_defaults(version: 'all', login: false, attempt: 1)
  `open -a Docker`

  Rake::Task['clobber'].reenable
  Rake::Task['clobber'].invoke
  Rake::Task['build'].reenable
  Rake::Task['build'].invoke

  case args[:version]
  when /^a/
    %w[26 27 30 33 34].each do |v|
      Rake::Task['dockertest'].reenable
      Rake::Task['dockertest'].invoke(v, false)
    end
    Process.exit 0
  when /^3\.?4/
    version = '3.4'
    img = 'randwtest34'
    file = 'docker/Dockerfile-3.4'
  when /^3\.?3/
    version = '3.3'
    img = 'randwtest33'
    file = 'docker/Dockerfile-3.3'
  when /^2\.?6/
    version = '2.6'
    img = 'randwtest26'
    file = 'docker/Dockerfile-2.6'
  when /^2/
    version = '2.7'
    img = 'randwtest27'
    file = 'docker/Dockerfile-2.7'
  else
    version = '3.0'
    img = 'randwtest30'
    file = 'docker/Dockerfile-3.0'
  end

  spinner = TTY::Spinner.new("[:spinner] Updating Docker image (#{version})...", hide_cursor: true)
  `docker build . --file #{file} -t #{img} &> /dev/null`

  unless $CHILD_STATUS.success?
    spinner.error
    spinner.stop
    raise DockerError, 'Error building docker image'
  end

  spinner.success
  spinner.stop

  dirs = {
    File.dirname(__FILE__) => '/randw',
    File.expand_path('~/.config') => '/root/.config'
  }
  dir_args = dirs.map { |s, d| " -v '#{s}:#{d}'" }.join(' ')
  exec "docker run #{dir_args} --name #{img} -it #{img} /bin/bash -l" if args[:login]

  spinner = TTY::Spinner.new("[:spinner] Running tests (#{version})...", hide_cursor: true)

  spinner.auto_spin
  output = `docker run --name #{img} --rm #{dir_args} -it #{img} 2>&1`
  if $CHILD_STATUS.success?
    spinner.success
    spinner.stop
  else
    spinner.error
    spinner.stop
    raise DockerError, 'Error running docker image'
    puts output
  end

  # commit = puts `bash -c "docker commit $(docker ps -a|grep #{img}|awk '{print $1}'|head -n 1) #{img}"`.strip

  # puts commit&.empty? ? "Error commiting Docker tag #{img}" : "Committed Docker tag #{img}"
rescue DockerError
  raise StandardError.new('Docker not responding') if args[:attempt] > 3

  `open -a Docker`
  sleep 3
  Rake::Task['dockertest'].reenable
  Rake::Task['dockertest'].invoke(args[:version], args[:login], args[:attempt] + 1)
end
