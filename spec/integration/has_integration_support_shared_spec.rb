shared 'has integration support' do
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

  before do
    @check_processing_yields_content = lambda do |contexts, example|
      generated_pdf = tmp_file('clamsy_pdf').path
      Clamsy.process(contexts, template_doc(example), generated_pdf)
      (diff_result = `#{CLAMSY_PDFC_SCRIPT} #{expected_pdf(example)} #{generated_pdf}`).
        split("\n").join('').should.match(/(| # of Differences).*(------------------).*(| 0)$/)
    end
  end

  after do
    trash_tmp_files
  end

  it 'should do picture replacement for pictures with matching names' do
    @check_processing_yields_content[
      context = {:_pictures => {
        :sunny_clamsy => data_file('norm_clamsy.png'),
        :norm_clamsy => data_file('sunny_clamsy.png'),
      }},
      example = :picture
    ]
  end

  it 'should do #{...} plain text replacement' do
    @check_processing_yields_content[
      context = {:someone => 'Peter', :mood => 'Happy'},
      example = :plain_text
    ]
  end

  it 'should do ${...} escaped (santized) replacement' do
    @check_processing_yields_content[
      context = {:someone => '<Peter>', :mood => '<Happy>'},
      example = :escaped_text
    ]
  end

  it 'should do {? ... ?} embedded ruby statements processing' do
    @someone = Class.new do
      attr_reader :name, :mood
      def initialize(name, mood)
        @name, @mood = name, mood
      end
    end
    @check_processing_yields_content[
      context = {:everyone => [@someone.new('Peter','Happy'), @someone.new('Jane','Sad')]},
      example = :embedded_ruby
    ]
  end

  it 'should concat multiple contexts processing to a single pdf' do
    @check_processing_yields_content[
      contexts = [{:someone => 'Peter', :mood => 'Happy'}, {:someone => 'Jane', :mood => 'Sad'}],
      example = :multiple_contexts
    ]
  end

end
