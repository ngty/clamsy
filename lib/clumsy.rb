require 'ftools'
require 'digest/md5'
require 'tempfile'
require 'zip/zip'
require 'clumsy/tenjin'

module Clumsy

  class << self

    def process(contexts, template_odt, final_pdf)
      begin
        @template_odt = TemplateOdt.new(template_odt)
        odts = [contexts].flatten.map {|ctx| @template_odt.render(ctx) }
        puts final_pdf
        Shell.print_odts_to_pdf(odts, final_pdf)
      ensure
        @template_odt.trash_tmp_files
      end
    end

  end

  private

    module HasTrashableTempFiles

      def trash_tmp_files
        (@trashable_tmp_files || []).map(&:unlink)
      end

      def get_tmp_file(file_name)
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
              dest_odt = get_tmp_file(@context_id)
              File.copy(@template_odt, dest_odt.path) ; dest_odt
            end
        end

        def workers
          lambda do |entry|
            (@workers ||= {})[entry.to_s] ||=
              begin
                tmp_file = get_tmp_file("#{@context_id}.#{File.basename(entry.to_s)}")
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

      # PDF to PS & vice versa
      PDF_TO_PS_CMD = "pdf2ps"
      PS_TO_PDF_CMD = "ps2pdf"

      # Misc commands
      CAT_CMD = 'cat'

      class << self

        include HasTrashableTempFiles

        def print_odts_to_pdf(from_odts, to_pdf)
          begin
            tmp_ps = get_tmp_file(File.basename(to_pdf, '.pdf')).path
            puts "#{PS_TO_PDF_CMD} #{tmp_ps} #{to_pdf}" # DEBUG
            system([
              "#{CAT_CMD} #{convert_odts_to_pss(from_odts).join(' ')} > #{tmp_ps}",
              "#{PS_TO_PDF_CMD} #{tmp_ps} #{to_pdf}"
            ].join(' && '))
            puts File.exists?(to_pdf) ? 'exists !!' : 'missing !!' # DEBUG
          ensure
            trash_tmp_files
          end
        end

        private

          def convert_odts_to_pss(odts)
            odts.map(&:path).map do |odt_file|
              ps_file = get_tmp_file(basename = File.basename(odt_file, '.odt')).path
              pdf_file = File.join(PDF_OUTPUT_DIR, basename) + '.pdf'
              system("#{ODT_TO_PDF_CMD} #{odt_file}")
              # Abit clumsy ... but prevents occasional error for subsequent PDF_TO_PS_CMD
              0.upto(10) {|_| File.exists?(pdf_file) ? break : sleep(1) }
              system("#{PDF_TO_PS_CMD} #{pdf_file} #{ps_file}")
              ps_file
            end
          end

      end

    end

#  module Contexts2Odts
#    class << self
#
#      def convert(contexts, template_odt)
#        begin
#          @source_odt = template_odt
#          contexts.map {|@context| convert_context_to_odt }
#        ensure
#          trash_tmp_files
#        end
#      end
#
#      private
#
#        def convert_context_to_odt
#          Zip::ZipFile.open(working_odt.path) do |zip|
#            zip.select {|entry| entry.file? && entry.to_s =~ /\.xml$/ }.each do |entry|
#              zip.get_output_stream(entry.to_s) do |io|
#                io.write(templates[entry].render(@context.data))
#              end
#            end
#          end
#          working_odt
#        end
#
#        def templates
#          lambda do |entry|
#            (@templates ||= {})[entry.to_s] ||=
#              begin
#                tmp_file = get_tmp_file("#{@context.id}.#{File.basename(entry.to_s)}")
#                tmp_file.write(entry.get_input_stream.read)
#                tmp_file.close
#                Tenjin::Template.new(tmp_file.path)
#              end
#          end
#        end
#
#        def working_odt
#          (@working_odts ||= {})[@context.id] ||=
#            begin
#              dest_odt = get_tmp_file(@context.id, false)
#              File.copy(@source_odt, dest_odt.path) ; dest_odt
#            end
#        end
#
#        def get_tmp_file(file_name, trashable=true)
#          if trashable
#            ((@trashable_tmp_files ||= []) << Tempfile.new(file_name, '/tmp'))[-1]
#          else
#            Tempfile.new(file_name, '/tmp')
#          end
#        end
#
#        def trash_tmp_files
#          (@trashable_tmp_files || []).map(&:unlink)
#        end
#
#    end
#  end

#  module Odts2Pdf
#
#    # The folder where cups-pdf generated pdfs are stored:
#    # * in archlinux, this is specified in /etc/cups/cups-pdf.conf
#    PDF_OUTPUT_DIR = "/tmp/cups-pdf/#{`whoami`.strip}"
#
#    # The openoffice command to print odt to pdf, requires package cups-pdf & 'Cups-PDF' printer
#    # to be set up in cups.
#    ODT_TO_PDF_CMD = "ooffice -norestore -nofirststartwizard -nologo -headless -pt Cups-PDF",
#
#    # PDF to PS & vice versa
#    PDF_TO_PS_CMD = "pdf2ps"
#    PS_TO_PDF_CMD = "ps2pdf"
#
#    # Misc commands
#    CAT_CMD = 'cat'
#
#    class << self
#
#      def convert(from_odts, to_pdf)
#        begin
#          to_ps = get_tmp_file(File.basename(to_pdf, '.pdf'))
#          system([
#            "#{CAT_CMD} #{convert_odts_to_pss(from_odts).join(' ')} > #{to_ps}",
#            "#{PS_TO_PDF_CMD} #{to_ps} #{to_pdf}"
#          ].join(' && '))
#        ensure
#          trash_tmp_files
#        end
#      end
#
#      private
#
#        def convert_odts_to_pss(odts)
#          odts.map do |odt|
#            ps_file = get_tmp_file(basename = File.basename(odt, '.odt'))
#            system([
#              "#{ODT_TO_PDF_CMD} #{odt}",
#              "#{PDF_TO_PS_CMD} #{File.join(PDF_OUTPUT_DIR, basename)}.pdf #{ps_file}"
#            ].join(' && '))
#            ps_file
#          end
#        end
#
#        def get_tmp_file(file_name)
#          ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1].path
#        end
#
#        def trash_tmp_files
#          (@trashable_tmp_files || []).map(&:unlink)
#        end
#
#    end
#
#  end

end

