require 'rghost'

module Clamsy
  class BasePrinter
    class << self

      include Clamsy::FileSystemSupport

      def odts_to_pdf(from_odts, to_pdf)
        begin
          tmp_ps = tmp_file(File.basename(to_pdf, '.pdf'))
          from_odts.map {|odt| tmp_ps << odt_to_ps_stream(odt.path) }
          tmp_ps.close
          gs_convert(:pdf, tmp_ps.path, to_pdf)
        ensure
          trash_tmp_files
        end
      end

      private

        def odt_to_ps_stream(odt_path)
          file_must_exist!(odt_path)
          gs_convert(:ps, odt_to_pdf(odt_path))
        end

        def odt_to_pdf(odt_path)
          raise Clamsy::ImplementationNotFoundError.new("#{self.to_s}.odt_to_pdf not implemented.")
        end

        def gs_convert(format, src_path, dest_path=nil)
          file_must_exist!(src_path)
          method, opts = dest_path ? [:path, {:filename => dest_path}] : [:read, {}]
          RGhost::Convert.new(src_path).to(format, opts).send(method)
        end

    end
  end
end
