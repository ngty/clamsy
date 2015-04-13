# Still needed for gjman, but not used in clamsy anymore
class File
  def self.move(from, to)
    FileUtils.move(from, to)
  end
end

require 'gjman/pdf'
require 'clamsy/tenjin'
require 'clamsy/pdf'
require 'clamsy/file_system'
require 'clamsy/printers'
require 'clamsy/template_open_doc'
require 'clamsy/configuration'

module Clamsy

  ROOT = File.expand_path(File.dirname(__FILE__))

  class << self

    def configure(&blk)
      yield(config)
    end

    def root(*args)
      args.size == 0 ? ROOT : File.join(ROOT, *args)
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
          FileSystem.trash_tmp_files
        end
      end

      def config
        @config ||= Configuration.new(bundled_config_file, true)
      end

      def bundled_config_file
        Clamsy.root('clamsy.yml')
      end

      def printer
        Clamsy::Printers.get(config.printer, config)
      end

  end

end
