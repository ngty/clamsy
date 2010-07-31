module Clamsy

  class OofficeServerNotStartedError < Exception ; end

  module Printers
    class JODConverter < Base

      OOFFICE_SERVER_IP = '0.0.0.0'

      class << self

        def doc_to_pdf(doc_path)
          run_ooffice_server
          pdf_path = tmp_pdf_path(doc_path)
          system("#{print_cmd} #{doc_path} #{pdf_path}")
          FileSystem.file_must_exist!(pdf_path, 10) ; pdf_path
        end

        private

          def tmp_pdf_path(doc_path)
            FileSystem.tmp_file([Digest::MD5.hexdigest(doc_path),'.pdf']).path
          end

          def print_cmd
            [
              "#{config.java_bin} -jar",
              Clamsy.root('ext', 'jodconverter', 'jodconverter-cli-2.2.2.jar'),
              "--port #{ooffice_server_port}",
              '>/dev/null 2>&1'
            ].join(' ')
          end

          def run_ooffice_server
            # NOTE: Since it doesn't hurt to repeatedly start ooffice server, we will always start it.
            system("#{config.ooffice_bin} #{config.ooffice_server_args}")
            ooffice_server_must_be_running!
          end

          def ooffice_server_must_be_running!
            # Adapted from http://stackoverflow.com/questions/517219/ruby-see-if-a-port-is-open
            count, max_count = 0, 10
            begin
              Timeout::timeout(1) { TCPSocket.new(OOFFICE_SERVER_IP, ooffice_server_port).close }
            rescue
              (sleep 1; retry) if (count+=1) < max_count
              raise OofficeServerNotStartedError
            end
          end

          def ooffice_server_port
             config.ooffice_server_args.sub(/^.*port=(\d+).*$/,'\1')
          end

      end
    end
  end
end
