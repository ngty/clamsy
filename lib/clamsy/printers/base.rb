module Clamsy
  module Printers
    class Base
      class << self

        attr_reader :config

        def docs_to_pdf(from_docs, to_pdf)
          Gjman::PDF.merge(
            from_docs.map{|doc| doc_to_pdf(doc.path) },
            :to => to_pdf
          )
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
