module Clamsy
  module Printers
    class Base
      class << self

        attr_reader :config

        def docs_to_pdf(from_docs, to_pdf)
          tmp_pdfs = from_docs.map{|doc| doc_to_pdf(doc.path) }
          Gjman::PDF.merge(tmp_pdfs, :to => to_pdf)
        end

        def configure(config)
          @config = config ; self
        end

        def inherited(subclass)
          Printers["#{subclass}".sub('Clamsy::Printers::','')] = subclass
        end

      end
    end
  end
end
