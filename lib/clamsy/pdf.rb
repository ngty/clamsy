module Clamsy
  class PDF

    JARS_PATH = %w{iText-5.0.3 utils}.map do |name|
      File.expand_path("../../java/#{name}.jar", __FILE__)
    end.join(':')

    def self.merge(srcs, dest)
      if RUBY_PLATFORM =~ /java/i
      else
        begin
          require 'rjb'
          Rjb::load(JARS_PATH)
          Rjb::import('PdfMerger').concat(srcs.join(','), dest)
        rescue LoadError
          system("java -cp #{JARS_PATH} PdfMerger #{srcs.join(',')} #{dest}")
        end
      end
      dest
    end

  end
end
