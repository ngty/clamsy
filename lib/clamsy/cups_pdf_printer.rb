module Clamsy
  class CupsPdfPrinter < BasePrinter
    class << self

      private

        def doc_to_pdf(doc_path)
          system("#{config.ooffice_bin} #{config.ooffice_print_args} #{doc_path}")
          pdf_path = tmp_pdf_path(doc_path)
          file_must_exist!(pdf_path, 10) ; pdf_path
        end

        def tmp_pdf_path(doc_path)
          if output_file = config.cups_output_file
            output_file.is_a?(Proc) ? output_file.call : output_file
          else
            # NOTE: we don't attempt to trim away the extension cos it is a hard
            # fact that internally we are always working with paths derived from
            # Tempfile instances, thus, no need for extension replacing.
            File.join(config.cups_output_dir, File.basename(doc_path)) + '.pdf'
          end
        end

    end
  end
end
