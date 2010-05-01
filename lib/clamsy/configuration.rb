require 'yaml'

module Clamsy

  class ConfigFileSettingNotSupportedError < Exception ; end

  module Configuration

    def self.new(file, is_base_config=false)
      if (config = YAML.load_file(path = File.expand_path(file)) rescue nil)
        config.update(:config_src => path)
        is_base_config ? BundledFileConfig.new(config) : UserFileConfig.new(config)
      end
    end

    def initialize_config_vars(config)
      @config_vars = {
        :printer => (printer = config['printer']),
        :printer_specific => (config[printer] || {}).
          inject({}) {|memo, args| memo.merge(args[0].to_sym => args[1]) }
      }
    end

    def method_missing(method, *args)
      !"#{method}".include?('=') ? get_config_var(method) :
        set_config_var("#{method}".sub('=','').to_sym, args[0])
    end

    protected

      def set_config_var(name, value)
        case name
        when :printer then @config_vars[name] = value
        else (@config_vars[:printer_specific] ||= {})[name] = value
        end
      end

      def get_config_var(name)
        replace_with_env_vars(
          case name
          when :printer then @config_vars[name]
          else (@config_vars[:printer_specific] ||= {})[name]
          end
        )
      end

      def replace_with_env_vars(val)
        val && %w{HOME USER}.inject(val) do |v,k|
          v.sub("\#{#{k}}",ENV[k])
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
          :default => self, :user_proc => UserProcConfig.new({}),
          :user_config => Configuration.new(@config_file)
        }
      end

      def config_file=(file)
        file_must_exist!(@config_file = file)
        @configs[:user_config] = Configuration.new(file)
      end

      private

        def set_config_var(name, value)
          @configs[:user_proc].send(:"#{name}=", value)
        end

        def get_config_var(name)
          key = [:user_proc, :user_config].find do |k|
            @configs[k] && (val = @configs[k].send(name)) && !"#{val}".strip.empty?
          end
          key ? replace_with_env_vars(@configs[key].send(name)) : super(name)
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
