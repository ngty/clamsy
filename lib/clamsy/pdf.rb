module Clamsy
  class PDF
    class << self

      def merge(srcs, dest)
        Gjman::PDF.merge(srcs, :to => dest)
      end

    end
  end
end
