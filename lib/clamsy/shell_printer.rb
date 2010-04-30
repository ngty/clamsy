module Clamsy
  class ShellPrinter < BasePrinter

    # The folder where cups-pdf generated pdfs are stored:
    # * in archlinux, this is specified in /etc/cups/cups-pdf.conf
    require 'yaml'
    clamsy_config = YAML.load_file("#{ENV['HOME']}/.clamsy") rescue nil
    pdf_output_dir = clamsy_config ? clamsy_config['pdf_output_dir'] : "/tmp/cups-pdf/#{ENV['USER']}"

    PDF_OUTPUT_DIR = pdf_output_dir

    # The openoffice command to print odt to pdf, requires package cups-pdf & 'Cups-PDF' printer
    # to be set up in cups.
    ODT_TO_PDF_CMD = "ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF"

    class << self

      private

        def odt_to_pdf(odt_path)
          system("#{ODT_TO_PDF_CMD} #{odt_path}")
          pdf_path = File.join(PDF_OUTPUT_DIR, File.basename(odt_path, '.odt')) + '.pdf'
          file_must_exist!(pdf_path, 10) ; pdf_path
        end

    end
  end
end
