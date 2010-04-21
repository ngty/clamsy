require 'spec_helper'

describe "Clamsy" do

  behaves_like 'has standard files support'

  before do
    @check_processing_yields_text = lambda do |contexts, example|
      generated_pdf = get_tmp_file('clamsy_pdf').path
      template_odt = get_template_odt(example)
      expected_pdf = get_expected_pdf(example)
      Clamsy.process(contexts, template_odt, generated_pdf)
      get_comparable_content(generated_pdf).should == get_comparable_content(expected_pdf)
    end
  end

  after do
    trash_tmp_files
  end

  it 'should do #{...} plain text replacement' do
    @check_processing_yields_text[
      context = {:someone => 'Peter', :mood => 'Happy'},
      example = :plain_text
    ]
  end

  it 'should do ${...} escaped (santized) replacement' do
    @check_processing_yields_text[
      context = {:someone => '<Peter>', :mood => '<Happy>'},
      example = :escaped_text
    ]
  end

  it 'should do {? ... ?} embedded ruby statements' do
    @someone = Class.new do
      attr_reader :name, :mood
      def initialize(name, mood)
        @name, @mood = name, mood
      end
    end
    @check_processing_yields_text[
      context = {:everyone => [@someone.new('Peter','Happy'), @someone.new('Jane','Sad')]},
      example = :embedded_ruby
    ]
  end

  it 'should concat multiple contexts processing to a single pdf' do
    @check_processing_yields_text[
      contexts = [{:someone => 'Peter', :mood => 'Happy'}, {:someone => 'Jane', :mood => 'Sad'}],
      example = :multiple_contexts
    ]
  end

end
