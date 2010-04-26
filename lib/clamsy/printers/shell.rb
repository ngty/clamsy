require 'rghost'

module Clamsy
  module Printers
    class Shell

      # The folder where cups-pdf generated pdfs are stored:
      # * in archlinux, this is specified in /etc/cups/cups-pdf.conf
      PDF_OUTPUT_DIR = "/tmp/cups-pdf/#{`whoami`.strip}"

      # The openoffice command to print odt to pdf, requires package cups-pdf & 'Cups-PDF' printer
      # to be set up in cups.
      ODT_TO_PDF_CMD = "ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF"

      class << self

        include Clamsy::TempFiles

        def odts_to_pdf(from_odts, to_pdf)
          begin
            tmp_ps = tmp_file(File.basename(to_pdf, '.pdf'))
            from_odts.map {|odt| tmp_ps << odt_to_ps_stream(odt) }
            tmp_ps.close
            gs_convert(:pdf, tmp_ps.path, to_pdf)
          ensure
            trash_tmp_files
          end
        end

        private

          def odt_to_ps_stream(odt)
            ensure_file_exists!(odt_path = odt.path)
            pdf_path = File.join(PDF_OUTPUT_DIR, File.basename(odt_path, '.odt')) + '.pdf'
            system("#{ODT_TO_PDF_CMD} #{odt_path}")
            gs_convert(:ps, pdf_path)
          end

          def gs_convert(format, src_path, dest_path=nil)
            ensure_file_exists!(src_path)
            method, opts = dest_path ? [:path, {:filename => dest_path}] : [:read, {}]
            RGhost::Convert.new(src_path).to(format, opts).send(method)
          end

          def ensure_file_exists!(file_path)
            exist_flg = false
            0.upto(10) {|i| File.exists?(file_path) ? (exist_flg = true; break) : sleep(1) }
            exist_flg or raise MissingFileError.new(file_path)
          end

      end

    end
  end
end
