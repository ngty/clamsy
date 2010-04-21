require 'ftools'
require 'digest/md5'
require 'tempfile'
require 'zip/zip'
require 'clamsy/tenjin'
require 'rghost'

module Clamsy

  class MissingFileError < Exception ; end

  class << self

    def process(contexts, template_odt, final_pdf)
      begin
        @template_odt = TemplateOdt.new(template_odt)
        odts = [contexts].flatten.map {|ctx| @template_odt.render(ctx) }
        Shell.print_odts_to_pdf(odts, final_pdf)
      ensure
        @template_odt.trash_tmp_files
      end
    end

  end

  private

    module HasTrashableTempFiles

      def trash_tmp_files
        (@trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
      end

      def tmp_file(file_name)
        ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1]
      end

    end

    class TemplateOdt

      include HasTrashableTempFiles

      def initialize(template_odt)
        @template_odt = template_odt
      end

      def render(context)
        @context_id = Digest::MD5.hexdigest(context.to_s)
        Zip::ZipFile.open(working_odt.path) do |zip|
          zip.select {|entry| entry.file? && entry.to_s =~ /\.xml$/ }.each do |entry|
            zip.get_output_stream(entry.to_s) {|io| io.write(workers[entry].render(context)) }
          end
        end
        working_odt
      end

      private

        def working_odt
          (@working_odts ||= {})[@context_id] ||=
            begin
              dest_odt = tmp_file(@context_id)
              File.copy(@template_odt, dest_odt.path) ; dest_odt
            end
        end

        def workers
          lambda do |entry|
            (@workers ||= {})[entry.to_s] ||=
              begin
                tmp_file = tmp_file("#{@context_id}.#{File.basename(entry.to_s)}")
                tmp_file.write(entry.get_input_stream.read)
                tmp_file.close
                Tenjin::Template.new(tmp_file.path)
              end
          end
        end

    end

    class Shell

      # The folder where cups-pdf generated pdfs are stored:
      # * in archlinux, this is specified in /etc/cups/cups-pdf.conf
      PDF_OUTPUT_DIR = "/tmp/cups-pdf/#{`whoami`.strip}"

      # The openoffice command to print odt to pdf, requires package cups-pdf & 'Cups-PDF' printer
      # to be set up in cups.
      ODT_TO_PDF_CMD = "ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF"

      class << self

        include HasTrashableTempFiles

        def print_odts_to_pdf(from_odts, to_pdf)
          begin
            tmp_ps = tmp_file(File.basename(to_pdf, '.pdf'))
            from_odts.map {|odt| tmp_ps << odt_to_ps_stream(odt) }
            tmp_ps.close
            gs_convert(:pdf, tmp_ps, to_pdf)
          ensure
            trash_tmp_files
          end
        end

        private

          def odt_to_ps_stream(odt)
            odt_path = to_path(odt)
            pdf_path = File.join(PDF_OUTPUT_DIR, File.basename(odt_path, '.odt')) + '.pdf'
            system("#{ODT_TO_PDF_CMD} #{odt_path}")
            gs_convert(:ps, pdf_path)
          end

          def gs_convert(format, src_file, dest_file=nil)
            ensure_file_exists(src_path = to_path(src_file))
            if dest_file
              RGhost::Convert.new(src_path).to(format, :filename => to_path(dest_file))
              dest_file
            else
              RGhost::Convert.new(src_path).to(format).read
            end
          end

          def ensure_file_exists(file)
            path, flag = to_path(file), false
            0.upto(10) {|i| File.exists?(path) ? (flag = true; break) : sleep(1) }
            flag or raise MissingFileError.new(path)
          end

          def to_path(file)
            file.path rescue file
          end

      end

    end

end
