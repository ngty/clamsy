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
            ext = doc_path.split('.').last
            File.join(config.cups_output_dir, File.basename(doc_path)).sub(/#{ext}$/, 'pdf')
          end
        end

    end
  end
end
