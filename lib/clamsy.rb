require 'clamsy/tenjin'
require 'clamsy/file_system_support'
require 'clamsy/base_printer'
require 'clamsy/template_open_doc'
require 'clamsy/configuration'

module Clamsy

  class << self

    include FileSystemSupport

    def configure(&blk)
      yield(config)
    end

    def process(contexts, template_doc, final_pdf, &blk)
      block_given? && configure(&blk)
      generate_pdf(contexts, template_doc, final_pdf)
    end

    private

      def generate_pdf(contexts, template_doc, final_pdf)
        begin
          @template_doc = TemplateOpenDoc.new(template_doc)
          docs = [contexts].flatten.map {|ctx| @template_doc.render(ctx) }
          printer.docs_to_pdf(docs, final_pdf)
        ensure
          @template_doc.trash_tmp_files
        end
      end

      def config
        @config ||=
          Configuration.new(File.join(File.dirname(__FILE__), 'clamsy.yml'), true)
      end

      def printer
        Clamsy::BasePrinter.get(config.printer, config)
      end

  end

end
