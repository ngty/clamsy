require 'yaml'

module Clamsy

  class ConfigFileSettingNotSupportedError < Exception ; end
  class PlatformNotSupportedError < Exception ; end

  module Configuration

    ENV_REPLACE_PATTERN = /(\$\{(.*?)\})/

    def self.new(file, is_base_config, default_config={})
      if (config = YAML.load_file(path = File.expand_path(file)) rescue nil)
        config = replace_with_env_vars(config)
        klass, config = is_base_config ? [BundledFileConfig, config[platform]] : [UserFileConfig, config]
        klass.new(default_config.merge(config).merge(:config_src => path))
      end
    end

    def self.platform
      case ruby_platform
        when /linux/  then 'linux'
        else raise PlatformNotSupportedError.new("Platform '#{ruby_platform}' is not supported (yet).")
      end
    end

    def self.ruby_platform
      RUBY_PLATFORM
    end

    def self.merge_configs(*args)
      args.inject({}) do |memo, hash|
        hash.inject(memo) do |m, arg|
          key, val = arg
          key == :config_src ? m.merge(key => val) : m.merge("#{key}" => val)
        end
      end
    end

    def method_missing(method, *args)
      !"#{method}".include?('=') ? get_config_var(method) :
        set_config_var("#{method}".sub('=','').to_sym, args[0])
    end

    protected

      def initialize_config_vars(config)
        @config, @config_vars = config, {
          :printer => (printer = config['printer']),
          :ooffice_bin => config['ooffice_bin'],
          :java_bin => config['java_bin'],
          :printer_specific => (config[printer] || {}).
            inject({}) {|memo, args| memo.merge(args[0].to_sym => args[1]) }
        }
      end

      def set_config_var(name, value)
        case name
        when :printer, :ooffice_bin, :java_bin then @config_vars[name] = value
        else (@config_vars[:printer_specific] ||= {})[name] = value
        end
      end

      def get_config_var(name)
        case name
        when :printer, :ooffice_bin, :java_bin then @config_vars[name]
        else (@config_vars[:printer_specific] ||= {})[name]
        end
      end

      def self.replace_with_env_vars(hash)
        hash.inject({}) do |memo, args|
          key, val = args
          if val.is_a?(Hash)
            memo.merge(key => replace_with_env_vars(val))
          elsif !val.nil?
            while val[ENV_REPLACE_PATTERN,1]
              (m = val.match(ENV_REPLACE_PATTERN)) && val.sub!(m[1], ENV[m[2]] || '')
            end
            memo.merge(key => val)
          else
            memo
          end
        end
      end

  end

  private

    class BundledFileConfig

      include Configuration
      include FileSystemSupport
      attr_reader :config_file

      def initialize(config)
        initialize_config_vars(config)
        @config_file = config['config_file']
        @configs = {
          :default => self,
          :user_proc => new_proc_config,
          :user_file => new_user_config(@config_file)
        }
      end

      def config_file=(file)
        file_must_exist!(@config_file = file)
        @configs[:user_file] = new_user_config(file)
      end

      private

        def set_config_var(name, value)
          if name == :printer
            super(:printer, value)
            reset_printer_specific_settings(value)
          end
          @configs[:user_proc].send(:"#{name}=", value)
        end

        def get_config_var(name)
          key = [:user_proc, :user_file].find do |k|
            @configs[k] && (val = @configs[k].send(name)) && !"#{val}".strip.empty?
          end
          key ? @configs[key].send(name) : super(name)
        end

        def reset_printer_specific_settings(printer)
          if @config[printer]
            initialize_config_vars(@config.merge('printer' => printer))
            @configs[:user_file] = new_user_config(config_file)
          else
            raise PrinterNotFoundError.new("Printer '#{printer}' cannot be found.")
          end
        end

        def new_user_config(file)
          Configuration.new(file, false, 'printer' => @config_vars[:printer])
        end

        def new_proc_config
          UserProcConfig.new({})
        end

    end

    class UserFileConfig

      include Configuration

      def initialize(config)
        ensure_valid_config!(config)
        initialize_config_vars(config)
      end

      private

        def ensure_valid_config!(config)
          if file = config['config_file']
            raise ConfigFileSettingNotSupportedError.new \
              "Specifying of 'config_file' setting in user config '%s' is not supported." %
                config[:config_src]
          end
        end

    end

    class UserProcConfig
      include Configuration
      def initialize(config) ; initialize_config_vars(config) ; end
    end

end
