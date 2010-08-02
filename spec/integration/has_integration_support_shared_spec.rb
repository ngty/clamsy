class Someone
  attr_reader :name, :mood
  def initialize(name, mood)
    @name, @mood = name, mood
  end
end

shared 'has integration support' do

  class << self

    def pic_file(file)
      data_file(:generic, file)
    end

    def data_file(*args)
      File.join([File.dirname(__FILE__), 'data', args.map(&:to_s)].flatten)
    end

    def should_generate_expected_pdf(contexts, name)
      expected_pdf =  data_file(@printer, "#{name}_example.pdf")
      template_doc = data_file(:generic, "#{name}_example.odt")
      generated_pdf = Clamsy.process(contexts, template_doc, tmp_file(%w{clamsy .pdf}).path)
      `cp #{generated_pdf} /tmp/generated.pdf`
      Gjman::PDF.match?(expected_pdf, generated_pdf).should.be.true
    end

  end

  after do
    trash_tmp_files
  end

  it 'should do picture replacement for pictures with matching names' do
    should_generate_expected_pdf \
      context = {:_pictures => {
        :sunny_clamsy => pic_file('norm_clamsy.png'),
        :norm_clamsy => pic_file('sunny_clamsy.png'),
      }},
      example = :picture
  end

  it 'should do #{...} plain text replacement' do
    should_generate_expected_pdf \
      context = {:someone => 'Peter', :mood => 'Happy'},
      example = :plain_text
  end

  it 'should do ${...} escaped (santized) replacement' do
    should_generate_expected_pdf \
      context = {:someone => '<Peter>', :mood => '<Happy>'},
      example = :escaped_text
  end

  it 'should do {? ... ?} embedded ruby statements processing' do
    should_generate_expected_pdf \
      context = {:everyone => [Someone.new('Peter','Happy'), Someone.new('Jane','Sad')]},
      example = :embedded_ruby
  end

  it 'should concat multiple contexts processing to a single pdf' do
    should_generate_expected_pdf \
      contexts = [{:someone => 'Peter', :mood => 'Happy'}, {:someone => 'Jane', :mood => 'Sad'}],
      example = :multiple_contexts
  end

end
