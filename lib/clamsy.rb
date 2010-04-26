require 'clamsy/tenjin'
require 'clamsy/file_system_support'
require 'clamsy/base_printer'
require 'clamsy/shell_printer'
require 'clamsy/template_odt'

module Clamsy

  class FileNotFoundError < Exception ; end
  class ImplementationNotFoundError < Exception ; end

  class << self

    def process(contexts, template_odt, final_pdf)
      begin
        @template_odt = TemplateOdt.new(template_odt)
        odts = [contexts].flatten.map {|ctx| @template_odt.render(ctx) }
        ShellPrinter.odts_to_pdf(odts, final_pdf)
      ensure
        @template_odt.trash_tmp_files
      end
    end

  end
end
