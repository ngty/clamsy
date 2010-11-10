module Clamsy
  class PDF

    JAVA_CLASS_PATH = %w{iText-5.0.3 utils}.map do |name|
      File.expand_path("../java/#{name}.jar", __FILE__)
    end.join(':')

    def self.merge(srcs, dest)
      if RUBY_PLATFORM =~ /java/i
      else
        begin
          require 'rjb'
          Rjb::load(JAVA_CLASS_PATH)
          Rjb::import('PdfMerger').concat(srcs.join(','), dest)
        rescue LoadError

        end
      end
      dest
    end

  end
end
