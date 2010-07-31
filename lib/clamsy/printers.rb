require 'clamsy/printers/base'

module Clamsy

  class PrinterNotFoundError < Exception ; end

  module Printers
    class << self

      def get(name, config)
        begin
          require Clamsy.root('clamsy', 'printers', name.to_s)
          (printer = self[name]).configure(config)
        rescue Exception
          raise PrinterNotFoundError.new("Printer '#{name}' cannot be found.")
        end
      end

      def [](name)
        (@supported ||= {})[name.to_s.gsub('_','').downcase]
      end

      def []=(name, printer)
        (@supported ||= {})[name.to_s.gsub('_','').downcase] = printer
      end

    end
  end

end
