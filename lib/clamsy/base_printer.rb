require 'rghost'

module Clamsy

  class ImplementationNotFoundError < Exception ; end
  class PrinterNotFoundError < Exception ; end

  class BasePrinter
    class << self

      include Clamsy::FileSystemSupport
      attr_reader :subclasses, :config

      def docs_to_pdf(from_docs, to_pdf)
        begin
          tmp_ps = tmp_file(File.basename(to_pdf, '.pdf'))
          from_docs.map {|doc| tmp_ps << doc_to_ps_stream(doc.path) }
          tmp_ps.close
          gs_convert(:pdf, tmp_ps.path, to_pdf)
        ensure
          trash_tmp_files
        end
      end

      def get(name, config)
        begin
          require File.join(File.dirname(__FILE__), "#{name}_printer.rb")
          printer = self.subclasses[name.gsub(/[^a-zA-Z0-9]/,'').downcase]
          printer.configure(config) ; printer
        rescue Exception
          raise PrinterNotFoundError.new("Printer '#{name}' cannot be found.")
        end
      end

      protected

        def doc_to_ps_stream(doc_path)
          file_must_exist!(doc_path)
          gs_convert(:ps, doc_to_pdf(doc_path))
        end

        def configure(config)
          @config = config
        end

        def doc_to_pdf(doc_path)
          raise Clamsy::ImplementationNotFoundError.new("#{self.to_s}.doc_to_pdf not implemented.")
        end

        def gs_convert(format, src_path, dest_path=nil)
          file_must_exist!(src_path)
          method, opts = dest_path ? [:path, {:filename => dest_path}] : [:read, {}]
          RGhost::Convert.new(src_path).to(format, opts).send(method)
        end

        def inherited(subclass)
          key = "#{subclass}".sub(/Clamsy::(\w+)Printer/,'\1').downcase
          (@subclasses ||= {})[key] = subclass
        end

    end

  end
end
