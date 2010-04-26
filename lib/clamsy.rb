require 'clamsy/tenjin'
require 'clamsy/errors'
require 'clamsy/temp_files'
require 'clamsy/template_odt'
require 'clamsy/printers/shell'

module Clamsy
  class << self

    def process(contexts, template_odt, final_pdf)
      begin
        @template_odt = TemplateOdt.new(template_odt)
        odts = [contexts].flatten.map {|ctx| @template_odt.render(ctx) }
        Printers::Shell.odts_to_pdf(odts, final_pdf)
      ensure
        @template_odt.trash_tmp_files
      end
    end

  end
end
