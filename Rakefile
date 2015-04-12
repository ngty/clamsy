require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "clamsy"
    gem.summary = %Q{Clamsy makes PDF generation simple}
    gem.description = %Q{Ruby wrapper for generating a single pdf for multiple contexts from an odt template.}
    gem.email = "ngty77@gmail.com"
    gem.homepage = "http://github.com/ngty/clamsy"
    gem.authors = ["NgTzeYang"]
    gem.add_dependency "rubyzip", "= 0.9.4"
    gem.add_dependency "gjman", "= 0.1.0"
    gem.add_dependency "nokogiri", "= 1.4.1"
    gem.add_development_dependency "bacon", ">= 1.1.0"
    gem.add_development_dependency "eventmachine", ">= 0.12.10"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings

    gem.post_install_message = <<-POST_INSTALL_MESSAGE

  ///////////////////////////////////////////////////////////////////////////////////////////////////

    :: CLAMSY ::

    Thank you for installing clamsy-0.0.5.

    Starting from this release, the default printer has been changed from 'cups_pdf' to
    'jod_convertor'. If java is in your PATH, and openoffice is installed the standard way,
    most probably, no additional action is required after this gem installation.

    We are in the process of constructing the clamsy wiki @ http://wiki.github.com/ngty/clamsy, pls
    take a look there for solution(s) to your problem(s).

    Alternatively, you may wish to post ur problem @ http://github.com/ngty/clamsy/issues.

    Have a nice day !!

  ///////////////////////////////////////////////////////////////////////////////////////////////////

POST_INSTALL_MESSAGE

  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :spec

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "clamsy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
