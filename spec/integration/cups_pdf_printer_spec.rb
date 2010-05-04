require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'has_stardand_integration_support_shared_spec')

describe "Clamsy (using Cups-PDF printer)" do

  behaves_like 'has standard files support'
  behaves_like 'has standard integration support'

  before do
    @check_processing_yields_content = lambda do |contexts, example|
      generated_pdf = tmp_file('clamsy_pdf').path
      Clamsy.process(contexts, template_doc(example), generated_pdf)
      `cp #{generated_pdf} /tmp/abc.pdf`
      expected_content = comparable_content(expected_pdf(example))
      generated_content = comparable_content(generated_pdf)
      generated_content.size.should.equal expected_content.size
      (generated_content - expected_content).should.equal []
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
