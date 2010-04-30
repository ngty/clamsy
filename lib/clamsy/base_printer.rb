require 'rghost'

module Clamsy
  class BasePrinter
    class << self

      include Clamsy::FileSystemSupport

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

      protected

        def doc_to_ps_stream(doc_path)
          file_must_exist!(doc_path)
          gs_convert(:ps, doc_to_pdf(doc_path))
        end

        def doc_to_pdf(doc_path)
          raise Clamsy::ImplementationNotFoundError.new("#{self.to_s}.doc_to_pdf not implemented.")
        end

        def gs_convert(format, src_path, dest_path=nil)
          file_must_exist!(src_path)
          method, opts = dest_path ? [:path, {:filename => dest_path}] : [:read, {}]
          RGhost::Convert.new(src_path).to(format, opts).send(method)
        end

    end
  end
end
