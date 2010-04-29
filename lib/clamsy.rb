require 'clamsy/tenjin'
require 'clamsy/file_system_support'
require 'clamsy/base_printer'
require 'clamsy/shell_printer'
require 'clamsy/template_open_doc'

module Clamsy

  class ImplementationNotFoundError < Exception ; end

  class << self

    def process(contexts, template_doc, final_pdf)
      begin
        @template_doc = TemplateOpenDoc.new(template_doc)
        docs = [contexts].flatten.map {|ctx| @template_doc.render(ctx) }
        ShellPrinter.odts_to_pdf(docs, final_pdf)
      ensure
        @template_doc.trash_tmp_files
      end
    end

  end
end
