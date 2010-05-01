module Clamsy
  class CupsPdfPrinter < BasePrinter
    class << self

      private

        def doc_to_pdf(doc_path)
          system("#{config.ooffice_cmd} #{doc_path}")
          pdf_path = tmp_pdf_path(doc_path)
          file_must_exist!(pdf_path, 10) ; pdf_path
        end

        def tmp_pdf_path(doc_path)
          File.join(config.cups_output_dir, File.basename(doc_path, '.doc')) + '.pdf'
        end

    end
  end
end
