require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "Clamsy configuration" do

  before do
    Clamsy.unconfigure
    $bundled_config_file = tmp_file('bundled-clamsy.ym;').path
    $user_config_file = tmp_file('user-clamsy.yml').path
    @write_config = lambda {|file, data| File.open(file,'w') {|io| YAML.dump(data, io) } }
    @write_bundled_config = lambda {|data| @write_config[$bundled_config_file, data] }
    @write_user_config = lambda {|data| @write_config[$user_config_file, data] }

    # NOTE: Essentially, we are just doing some stubbing ...
    class << Clamsy::Configuration ; backup_methods %w{new ruby_platform} ; end
    class << Clamsy ; backup_methods %w{bundled_config_file} ; end
  end

  after do
    # NOTE: Essentially, we are just doing some unstubbing ...
    class << Clamsy::Configuration ; recover_methods %w{new ruby_platform} ; end
    class << Clamsy ; recover_methods %w{bundled_config_file} ; end
  end

  {
    :linux => {
      :printer => 'jod_converter',
      :config_file => '~/.clamsy.yml',
      :java_bin => 'java',
      :ooffice_bin => 'ooffice',
      :cups_pdf => {
        :ooffice_print_args => '-norestore -nofirststartwizard -nologo -headless -pt Cups-PDF',
        :cups_output_dir => "/var/spool/cups-pdf/#{ENV['USER']}",
        :cups_output_file => nil,
      },
      :jod_converter => {
        :ooffice_server_args =>
          '-headless -nofirststartwizard -accept="socket,host=localhost,port=8100;urp;StarOffice.Service"'
      }
    },
    :darwin => {
      :printer => 'jod_converter',
      :config_file => '~/.clamsy.yml',
      :java_bin => 'java',
      :ooffice_bin => '/Applications/OpenOffice.org.app/Contents/MacOS/soffice.bin',
      :cups_pdf => {
        :ooffice_print_args => '-norestore -nofirststartwizard -nologo -headless -pt Cups-PDF',
        :cups_output_dir => "/opt/local/var/spool/cups-pdf/#{ENV['USER']}",
        :cups_output_file => nil,
      },
      :jod_converter => {
        :ooffice_server_args =>
          '-headless -nofirststartwizard -accept="socket,host=localhost,port=8100;urp;StarOffice.Service" &'
      }
    },
    :windows => {},
    :java => {} # jruby
  }.each do |platform, configs|
    describe "> default bundled config (#{platform})" do
      before do
        class << Clamsy::Configuration
          def ruby_platform ; "#{platform}" ; end
          def new(file, is_base_config, default_configs={})
            file == '~/.clamsy.yml' ? nil : _orig_new(CLAMSY_BUNDLED_CONFIG, true)
          end
        end
      end
      if configs.empty?
        # Platform is not yet supported !!
        should 'raise Clamsy::PlatformNotSupportedError' do
          lambda { Clamsy.configure {|config| 'watever' } }.
            should.raise(Clamsy::PlatformNotSupportedError).
            message.should.equal("Platform '#{platform}' is not supported (yet).")
        end
      else
        configs.each do |name, value|
          if value.is_a?(Hash)
            # Printer-specific settings
            value.each do |_name, _value|
              should "have :#{_name} as '#{_value}' (when printer is '#{name}')" do
                Clamsy.configure do |config|
                  config.printer = "#{name}"
                  config.send(_name).should.equal _value
                end
              end
            end
          else
            # Printer-independent settings
            should "have :#{name} as '#{value}'" do
              Clamsy.configure do |config|
                config.send(name).should.equal value
              end
            end
          end
        end
      end
    end
  end

  describe '> configuring (using default user config file)' do

    before do
      class << Clamsy::Configuration
        def ruby_platform ; 'linux' ; end
        def new(file, is_base_config, default_configs={})
          is_base_config ? _orig_new($bundled_config_file, true) :
            _orig_new(file, is_base_config, default_configs)
        end
      end
      @bundled_config = {
        'printer' => 'super',
        'ooffice_bin' => '/super/ooffice_bin',
        'java_bin' => '/super/java',
        'config_file' => $user_config_file,
        'super' => {'super_setting1' => 'super_setting'}
      }
      @write_bundled_config[{'linux' => @bundled_config}]
    end

    %w{printer ooffice_bin java_bin}.each do |setting|
      should "use specified :#{setting} if it has been specified" do
        other_val = @bundled_config[setting].sub('super','duper')
        @write_user_config[{setting => other_val}]
        Clamsy.configure do |config|
          config.send(setting).should.equal other_val
        end
      end
      should "use default :#{setting} if it has not been specified" do
        @write_user_config[{}]
        Clamsy.configure do |config|
          config.send(setting).should.equal @bundled_config[setting]
        end
      end
    end

    should "use specified printer-specific setting if it has been specified" do
      other_val = @bundled_config['super']['super_setting1'].sub('super','duper')
      @write_user_config[{'super' => {'super_setting1' => other_val}}]
      Clamsy.configure do |config|
        config.super_setting1.should.equal other_val
      end
    end

    should "use default printer-specific setting if it has not been specified" do
      @write_user_config[{}]
      Clamsy.configure do |config|
        config.super_setting1.should.equal @bundled_config['super']['super_setting1']
      end
    end

  end

  shared 'configurable using config proc' do

    before do
      class << Clamsy::Configuration
        def ruby_platform ; 'linux' ; end
        def new(file, is_base_config, default_configs={})
          is_base_config ? _orig_new($bundled_config_file, true) :
            _orig_new(file, is_base_config, default_configs)
        end
      end
      @bundled_config = {
        'printer' => 'super',
        'ooffice_bin' => '/super/ooffice_bin',
        'java_bin' => '/super/java',
        'config_file' => $user_config_file,
        'super' => {'super_setting1' => 'super_setting1_val'},
        'duper' => {'duper_setting1' => 'duper_setting1_val'}
      }
      @write_bundled_config[{'linux' => @bundled_config}]
    end

    %w{printer ooffice_bin java_bin}.each do |setting|
      should "use specified :#{setting} if it has been specified" do
        other_val = @bundled_config[setting].sub('super','duper')
        clamsy_configure do |config|
          config.send(:"#{setting}=", other_val)
          config.send(setting).should.equal other_val
        end
      end
      should "use default :#{setting} if it has not been specified" do
        clamsy_configure do |config|
          config.send(setting).should.equal @bundled_config[setting]
        end
      end
    end

    should "use specified printer-specific setting if it has been specified" do
      clamsy_configure do |config|
        config.super_setting1 = 'duper_setting'
        config.super_setting1.should.equal 'duper_setting'
      end
    end

    should "use default printer-specific setting if it has not been specified" do
      clamsy_configure do |config|
        config.super_setting1.should.equal @bundled_config['super']['super_setting1']
      end
    end

    should "use specified :config_file if it has been specified" do
      other_user_config_file = tmp_file('yet_another_user_config_file').path
      clamsy_configure do |config|
        config.config_file = other_user_config_file
        config.config_file.should.equal other_user_config_file
      end
    end

    should "raise Clamsy::FileNotFoundError if the specified config file does not exist" do
      lambda {
        clamsy_configure {|config| config.config_file = "#{__FILE__}.clamsy.yml" }
      }.should.raise(Clamsy::FileNotFoundError).message.should.equal(
        "File '#{__FILE__}.clamsy.yml' not found."
      )
    end

    should 'raise Clamsy::PrinterNotFoundError if the specified printer does not exist' do
      other_printer = 'awesome'
      lambda { clamsy_configure {|config| config.printer = other_printer } }.
        should.raise(Clamsy::PrinterNotFoundError).
        message.should.equal("Printer '#{other_printer}' cannot be found.")
    end

    should 'reload printer-specific config (in bundled config file) when another printer is specified' do
      other_printer = 'duper'
      other_val = @bundled_config[other_printer]['duper_setting1']
      clamsy_configure do |config|
        config.duper_setting1.should.be.nil
        config.printer = other_printer
        config.duper_setting1.should.equal other_val
      end
    end

    should 'reload printer-specific config (in user config file) when another printer is specified' do
      other_printer, other_val = 'duper', 'duper_setting2_val'
      @write_user_config[{other_printer => {'duper_setting2' => other_val}}]
      clamsy_configure do |config|
        config.duper_setting2.should.be.nil
        config.printer = other_printer
        config.duper_setting2.should.equal other_val
      end
    end

  end

  describe '> configuring (using config proc)' do
    class << self
      def clamsy_configure(&blk) ; Clamsy.configure(&blk) ; end
    end
    behaves_like 'configurable using config proc'
  end

  describe '> configuring (using user-specified config file)' do

    before do
      class << Clamsy::Configuration
        def ruby_platform ; 'linux' ; end
        def new(file, is_base_config, default_configs={})
          is_base_config ? _orig_new($bundled_config_file, true) :
            _orig_new(file, is_base_config, default_configs)
        end
      end
      @bundled_config = {
        'printer' => 'super',
        'ooffice_bin' => '/super/ooffice_bin',
        'java_bin' => '/super/java',
        'config_file' => '/default/user/config/file',
        'super' => {'super_setting1' => 'super_setting'},
        'duper' => {'duper_setting1' => 'duper_setting'}
      }
      @write_bundled_config[{'linux' => @bundled_config}]
    end

    %w{printer ooffice_bin java_bin}.each do |setting|
      should "use specified :#{setting} if it has been specified" do
        other_val = @bundled_config[setting].sub('super','duper')
        @write_user_config[{setting => other_val}]
        Clamsy.configure do |config|
          config.config_file = $user_config_file
          config.send(setting).should.equal other_val
        end
      end
      should "use default :#{setting} if it has not been specified" do
        @write_user_config[{}]
        Clamsy.configure do |config|
          config.send(setting).should.equal @bundled_config[setting]
          config.config_file = $user_config_file
          config.send(setting).should.equal @bundled_config[setting]
        end
      end
    end

    should "use specified printer-specific setting if it has been specified" do
      other_val = @bundled_config['super']['super_setting1'].sub('super','duper')
      @write_user_config[{'super' => {'super_setting1' => other_val}}]
      Clamsy.configure do |config|
        config.config_file = $user_config_file
        config.super_setting1.should.equal other_val
      end
    end

    should "use default printer-specific setting if it has not been specified" do
      @write_user_config[{}]
      Clamsy.configure do |config|
        config.super_setting1.should.equal @bundled_config['super']['super_setting1']
      end
    end

    should "raise Clamsy::ConfigFileSettingNotSupportedError if :config_file has been specified" do
      @write_user_config[{'config_file' => '/yet/another/config/file'}]
      lambda {
        Clamsy.configure {|config| config.config_file = $user_config_file }
      }.should.raise(Clamsy::ConfigFileSettingNotSupportedError).
        message.should.equal(
          "Specifying of 'config_file' setting in user config '#{$user_config_file}' is not supported."
        )
    end

  end

  describe '> configuring (with clashes in user config file & config proc)' do

    before do
      class << Clamsy::Configuration
        def ruby_platform ; 'linux' ; end
        def new(file, is_base_config, default_configs={})
          is_base_config ? _orig_new($bundled_config_file, true) :
            _orig_new(file, is_base_config, default_configs)
        end
      end
      @bundled_config = {
        'printer' => 'super',
        'ooffice_bin' => '/super/ooffice_bin',
        'java_bin' => '/super/java',
        'config_file' => $user_config_file,
        'super' => {'super_setting1' => 'super_setting'},
        'duper' => {'duper_setting1' => 'duper_setting'},
        'guper' => {'guper_setting1' => 'guper_setting'},
      }
      @write_bundled_config[{'linux' => @bundled_config}]
    end

    %w{printer ooffice_bin java_bin}.each do |setting|
      should "use proc specified :#{setting} if it has been specified in both config proc & file" do
        config_file_val = @bundled_config[setting].sub('super','duper')
        config_proc_val = @bundled_config[setting].sub('super','guper')
        @write_user_config[{setting => config_file_val}]
        Clamsy.configure do |config|
          config.send(:"#{setting}=", config_proc_val)
          config.send(setting).should.equal config_proc_val
        end
      end
      should "use file specified :#{setting} if it has not been specified in config proc" do
        config_file_val = @bundled_config[setting].sub('super','duper')
        @write_user_config[{setting => config_file_val}]
        Clamsy.configure do |config|
          config.send(setting).should.equal config_file_val
        end
      end
    end

    should "use proc specified printer-specific setting if it has been specified in both config proc & file" do
      config_file_val = @bundled_config['super']['super_setting1'].sub('super','duper')
      config_proc_val = @bundled_config['super']['super_setting1'].sub('super','guper')
      @write_user_config[{'super' => {'super_setting1' => config_file_val}}]
      Clamsy.configure do |config|
        config.super_setting1 = config_proc_val
        config.super_setting1.should.equal config_proc_val
      end
    end

    should "use file specified printer-specific setting if it has not been specified in config proc" do
      config_file_val = @bundled_config['super']['super_setting1'].sub('super','duper')
      @write_user_config[{'printer' => 'super', 'super' => {'super_setting1' => config_file_val}}]
      Clamsy.configure do |config|
        config.super_setting1.should.equal config_file_val
      end
    end

  end

  describe '> configuring can also be done while doing Clamsy.process(...)' do

    class << self
      def clamsy_configure(&blk)
        Clamsy.process([], '/dummy/template/doc', '/dummy/final/pdf', &blk)
      end
    end

    before do
      class << Clamsy
        alias_method :orig_generate_pdf, :generate_pdf
        def generate_pdf(*args) ; end
      end
    end

    after do
      class << Clamsy
        alias_method :generate_pdf, :orig_generate_pdf
      end
    end

    behaves_like 'configurable using config proc'

  end

  describe '> retrieving of config values' do

    before do
      class << Clamsy::Configuration
        def ruby_platform ; 'linux' ; end
        def new(file, is_base_config, default_configs={})
          is_base_config ? _orig_new($bundled_config_file, true) :
            _orig_new(file, is_base_config, default_configs)
        end
      end
    end

    should 'replace any ${...} with matching environment variable value' do
      @write_bundled_config[{
        'linux' => {
          'printer' => 'super',
          'ooffice_bin' => '/super/ooffice_bin',
          'java_bin' => '/super/java',
          'config_file' => '/${USER}/${HOME}/clamsy.yml',
          'super' => {},
      }}]
      Clamsy.configure do |config|
        config.config_file.should.equal "/#{ENV['USER']}/#{ENV['HOME']}/clamsy.yml"
      end
    end

    should "replace any ${...} wo matching environment variable with blank string" do
      @write_bundled_config[{
        'linux' => {
          'printer' => 'super',
          'ooffice_bin' => '/super/ooffice_bin',
          'java_bin' => '/super/java',
          'config_file' => '/${WATEVER}/clamsy.yml',
          'super' => {},
      }}]
      Clamsy.configure do |config|
        config.config_file.should.equal "//clamsy.yml"
      end
    end

  end

end

