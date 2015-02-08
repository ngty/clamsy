
module Clamsy
  module Printers
    class Libreoffice < Base
      class << self
        def doc_to_pdf(doc_path)
          pdf_path = Tempfile.new(['clumsy', Time.now.to_i, '.pdf'])

          Dir.mktmpdir {|dir|
            system("libreoffice --headless --convert-to pdf --outdir #{ dir }  #{doc_path})"
            system("mv *.pdf #{ pdf_path }")
          }
          
          return pdf_path
        end
      end
    end
  end
end
