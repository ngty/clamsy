require File.join(File.dirname(__FILE__), '..', 'spec_helper')

def Clamsy.unconfigure
  @config = nil
end

describe "Clamsy configuration" do

  before do
    Clamsy.unconfigure
    $bundled_config_file = File.join(File.dirname(__FILE__),'..','..','lib','clamsy.yml')
    $user_config_file = Tempfile.new('clamsy.yml').path
    @write_config = lambda do |data|
      File.open($user_config_file,'w') {|io| YAML.dump(data, io) }
    end
  end

  after do
    class << Clamsy::Configuration
      alias_method :new, :orig_new
    end
  end

  describe '> default (w missing default user config file)' do

    before do
      class << Clamsy::Configuration
        alias_method :orig_new, :new
        def new(file, is_base_config=false)
          file == '~/.clamsy.yml' ? nil : orig_new($bundled_config_file, true)
        end
      end
    end

    should "have :printer as 'cups_pdf'" do
      Clamsy.configure do |config|
        config.printer.should.equal 'cups_pdf'
      end
    end

    should "have :config_file as '~/.clamsy.yml'" do
      Clamsy.configure do |config|
        config.config_file.should.equal '~/.clamsy.yml'
      end
    end

    should "have :cups_output_dir (cups_pdf) as '/var/spool/cups-pdf/#{ENV['USER']}'" do
      Clamsy.configure do |config|
        config.cups_output_dir.should.equal "/var/spool/cups-pdf/#{ENV['USER']}"
      end
    end

    should "have :cups_output_file (cups_pdf) be nil (unspecified)" do
      Clamsy.configure do |config|
        config.cups_output_file.should.equal nil
      end
    end

    should "have :ooffice_cmd (cups_pdf) as " +
      "'ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF'" do
      Clamsy.configure do |config|
        config.ooffice_cmd.should.equal \
          'ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF'
      end
    end

  end

  describe '> configuring (using default user config file)' do

    before do
      class << Clamsy::Configuration
        alias_method :orig_new, :new
        def new(file, is_base_config=false)
          file != '~/.clamsy.yml' ?
            orig_new($bundled_config_file, true) : orig_new($user_config_file)
        end
      end
    end

    should "use specified :printer if it has been specified" do
      @write_config[{'printer' => 'dummy'}]
      Clamsy.configure {|config| config.printer.should.equal 'dummy' }
    end

    should "use default :printer if it has not been specified" do
      @write_config[{}]
      Clamsy.configure {|config| config.printer.should.equal 'cups_pdf' }
    end

    should "raise Clamsy::ConfigFileSettingNotSupportedError if :config_file has been specified" do
      @write_config[{'config_file' => 'ddd'}]
      lambda { Clamsy.configure {|config| 'do nothing here' } }.
        should.raise(Clamsy::ConfigFileSettingNotSupportedError).
        message.should.equal(
          "Specifying of 'config_file' setting in user config '#{$user_config_file}' is not supported."
        )
    end

    should 'use specified printer-specific settings if they have been specified' do
      @write_config[{'printer' => 'cups_pdf', 'cups_pdf' => {'cups_output_dir' => '/x/y/z'}}]
      Clamsy.configure {|config| config.cups_output_dir.should.equal '/x/y/z' }
    end

    should 'use default printer-specific settings if they have not been specified' do
      Clamsy.configure do |config|
        config.cups_output_dir.should.equal "/var/spool/cups-pdf/#{ENV['USER']}"
      end
    end

  end

  describe '> configuring (using only config proc)' do

    behaves_like 'has standard files support'

    before do
      class << Clamsy::Configuration
        alias_method :orig_new, :new
        def new(file, is_base_config=false)
          file == '~/.clamsy.yml' ? nil : orig_new($bundled_config_file, true)
        end
      end
    end

    should 'use specified :printer if it has been specified' do
      Clamsy.configure do |config|
        config.printer = 'dummy'
        config.printer.should.equal 'dummy'
      end
    end

    should "use default :printer if it has not been specified" do
      Clamsy.configure do |config|
        config.printer.should.equal 'cups_pdf'
        [nil, ''].each do |val|
          config.printer = val
          config.printer.should.equal 'cups_pdf'
        end
      end
    end

    should "use specified :config_file if it has been specified" do
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.config_file.should.equal $user_config_file
      end
    end

    should "use raise Clamsy::FileNotFoundError if the specified config file does not exist" do
      lambda {
        Clamsy.configure {|config| config.config_file = "#{__FILE__}.clamsy.yml" }
      }.should.raise(Clamsy::FileNotFoundError).message.should.equal(
        "File '#{__FILE__}.clamsy.yml' not found."
      )
    end

    should 'use specified printer-specific settings if they have been specified' do
      Clamsy.configure do |config|
        config.cups_output_dir = '/x/y/z'
        config.cups_output_dir.should.equal '/x/y/z'
      end
    end

    should 'use default printer-specific settings if they have not been specified' do
      Clamsy.configure do |config|
        config.cups_output_dir.should.equal "/var/spool/cups-pdf/#{ENV['USER']}"
      end
    end

  end

  describe '> configuring (using only specified user config file in config proc)' do

    should 'use specified :printer if it has been specified' do
      @write_config[{'printer' => 'dummy'}]
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.printer.should.equal 'dummy'
      end
    end

    should 'use default :printer if it has not been specified' do
      @write_config[{}]
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.printer.should.equal 'cups_pdf'
      end
    end

    should "raise Clamsy::ConfigFileSettingNotSupportedError if :config_file has been specified" do
      @write_config[{'config_file' => 'ddd'}]
      lambda {
        Clamsy.configure {|config| config.config_file = $user_config_file }
      }.should.raise(Clamsy::ConfigFileSettingNotSupportedError).
        message.should.equal(
          "Specifying of 'config_file' setting in user config '#{$user_config_file}' is not supported."
        )
    end

    should 'use specified printer-specific settings if they have been specified' do
      @write_config[{'printer' => 'cups_pdf', 'cups_pdf' => {'cups_output_dir' => '/x/y/z'}}]
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.cups_output_dir.should.equal '/x/y/z'
      end
    end

    should 'use default printer-specific settings if they have not been specified' do
      @write_config[{}]
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.cups_output_dir.should.equal "/var/spool/cups-pdf/#{ENV['USER']}"
      end
    end

  end

  describe '> configuring (with clashes in specified user config file & config proc)' do

    should 'use proc specified :printer if it is specified in both config proc & file' do
      @write_config[{'printer' => 'dummy'}]
      Clamsy.configure do |config|
        # NOTE: it doesn't matter how we order the declaration !!
        config.config_file = $user_config_file
        config.printer = 'mummy'
        config.printer.should.equal 'mummy'
        config.config_file = $user_config_file
        config.printer.should.equal 'mummy'
      end
    end

    should 'use proc specified printer-specific settings if they are specified in both config proc & file' do
      @write_config[{'printer' => 'cups_pdf', 'cups_pdf' => {'cups_output_dir' => '/x/y/x'}}]
      Clamsy.configure do |config|
        # NOTE: it doesn't matter how we order the declaration !!
        config.config_file = $user_config_file
        config.cups_output_dir = '/a/b/c'
        config.cups_output_dir.should.equal '/a/b/c'
        config.config_file = $user_config_file
        config.cups_output_dir.should.equal '/a/b/c'
      end
    end

  end

  describe '> configuring can also be done while doing processing' do

    before do
      class << Clamsy
        def generate_pdf(*args) ; end
      end
    end

    should 'use specified :printer if it has been specified' do
      Clamsy.process([], '/dummy/template/doc', '/dummy/final/pdf') do |config|
        config.printer = 'dummy'
      end
      Clamsy.configure {|config| config.printer.should.equal 'dummy' }
    end

    should 'use default :printer if it has not been specified' do
      Clamsy.process([], '/dummy/template/doc', '/dummy/final/pdf')
      Clamsy.configure {|config| config.printer.should.equal 'cups_pdf' }
    end

  end

end

