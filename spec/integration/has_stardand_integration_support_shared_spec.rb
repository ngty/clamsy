shared 'has standard integration support' do
  class << self

    INSIGNIFICANT_AND_UNMATCHABLE_PATTERNS = [
      /^q\[\-?\d+\.?\d*( \-?\d+\.?\d*){5}\]concat\n$/,
      /^\d+\.?\d*( \d+\.?\d*){3} re\n$/
    ]

    def data_file(file)
      File.join(File.dirname(__FILE__), 'data', file)
    end

    def template_doc(name)
      data_file("#{name}_example.odt")
    end

    def expected_pdf(name)
      data_file("#{name}_example.pdf")
    end

    def comparable_content(file)
      RGhost::Convert.new(file).to(:ps).read.grep(/^[^%][^%]?/).
        reject {|line| INSIGNIFICANT_AND_UNMATCHABLE_PATTERNS.any? {|regexp| regexp =~ line } }
    end

  end
end
