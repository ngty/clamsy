require 'yaml'

module Clamsy
  class ShellPrinter < BasePrinter

    # The folder where cups-pdf generated pdfs are stored:
    # * in archlinux, this is specified in /etc/cups/cups-pdf.conf
    clamsy_config = YAML.load_file("#{ENV['HOME']}/.clamsy") rescue nil
    PDF_OUTPUT_DIR = clamsy_config ? clamsy_config['pdf_output_dir'] : "/tmp/cups-pdf/#{ENV['USER']}"

    # The openoffice command to print doc to pdf, requires package cups-pdf & 'Cups-PDF' printer
    # to be set up in cups.
    DOC_TO_PDF_CMD = "ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF"

    class << self

      private

        def doc_to_pdf(doc_path)
          system("#{DOC_TO_PDF_CMD} #{doc_path}")
          pdf_path = File.join(PDF_OUTPUT_DIR, File.basename(doc_path, '.doc')) + '.pdf'
          file_must_exist!(pdf_path, 10) ; pdf_path
        end

    end
  end
end
