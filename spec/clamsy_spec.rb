require 'spec_helper'

describe "Clamsy" do

  before do
    @tmp_pdf = Tempfile.new('clamsy_pdf')
    @data_files = lambda {|file| File.join(File.dirname(__FILE__), 'data', file) }
    @example_files = lambda {|name| @data_files["#{name}_example.odt"] }
    @expected_pdfs = lambda {|name| @data_files["#{name}_example.pdf"] }
    @check_processing_yields_text = lambda do |contexts, example|
      Clamsy.process(contexts, @example_files[example], @tmp_pdf.path)
      generated_content = `pdf2ps #{@tmp_pdf.path} -`.grep(/^[^%][^%]?/)
      expected_content = `pdf2ps #{@expected_pdfs[example]} -`.grep(/^[^%][^%]?/)
      (generated_content - expected_content).should == []
      (expected_content - generated_content).should == []
    end
  end

  after do
    @tmp_pdf.unlink
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
