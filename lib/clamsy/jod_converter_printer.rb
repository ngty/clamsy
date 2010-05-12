module Clamsy
  class JODConverterPrinter < BasePrinter
    class << self

      private

        def doc_to_pdf(doc_path)
          run_print_server
          pdf_path = tmp_pdf_path(doc_path)
          system("#{print_cmd} #{doc_path} #{pdf_path}")
          file_must_exist!(pdf_path, 10) ; pdf_path
        end

        def tmp_pdf_path(doc_path)
          tmp_file([Digest::MD5.hexdigest(doc_path),'.pdf']).path
        end

        def print_cmd
          [
            "#{config.java_bin} -jar",
            File.join(Clamsy::ROOT, 'jodconverter', 'jodconverter-cli-2.2.2.jar'),
            "--port #{server_port}"
          ].join(' ')
        end

        def run_print_server
          # NOTE: We can probably implement a check to avoid unnecessarily calling of this.
          system("#{config.ooffice_bin} #{config.ooffice_server_args}") rescue nil
          sleep 1
        end

        def server_port
           config.ooffice_server_args.sub(/^.*port=(\d+).*$/,'\1')
        end

    end
  end
end
