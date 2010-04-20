require 'spec_helper'

describe "Clamsy" do

  before do
    @tmp_pdf = Tempfile.new('clamsy_pdf')
    @example_file = lambda {|name| File.join(File.dirname(__FILE__), 'odts', "#{name}_example.odt") }
    @check_processing_yields_text = lambda do |contexts, example_name, expected_text|
      Clamsy.process(contexts, @example_file[example_name], @tmp_pdf.path)
      true.should == true
      # #puts @tmp_pdf.read
      # File.open('/home/ty.archlinux/dev/ty/clamsy/spec/pdfs/plain_text_example.pdf', 'r') {|fh|
      #   puts Differ.diff(fh.read, @tmp_pdf.read)
      # }
      # `cp #{@tmp_pdf.path} /tmp/bcd.pdf`
      # puts `pdf2ps #{@tmp_pdf.path} /tmp/a`
      # # puts `cat /tmp/a`
      # puts `ps2ascii /tmp/a`
      # puts `diff /home/ty.archlinux/dev/ty/clamsy/spec/pdfs/plain_text_example.ps /tmp/a`
      # puts File.exists?(@tmp_pdf.path) ? '... exists !!' : '... missing !!' # DEBUG
      # system("cp #{@tmp_pdf.path} /tmp/abc")
      # puts `ps2ascii /tmp/abc`
      # @tmp_pdf.close
      # puts `cat #{@tmp_pdf.path}`
      # system("ps2ascii #{@tmp_pdf.path} /tmp/abc")
      # puts `cat /tmp/abc`
    end
  end

  after do
    # [@tmp_pdf, @tmp_txt].map(&:unlink)
  end

  it 'should do #{...} plain text replacement' do
    @check_processing_yields_text[
      context = {:someone => 'Peter', :mood => 'Happy'},
      example_name = :plain_text,
      expected_text = "Peter is Happy"
    ]
  end

  it 'should do ${...} escaped (santized) replacement' do
    @check_processing_yields_text[
      context = {:someone => '<Peter>', :mood => '<Happy>'},
      example_name = :escaped_text,
      expected_text = "&lt;Peter&gt; is &lt;Happy&gt;"
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
      example_name = :embedded_ruby,
      expected_text = ['Peter is Happy', 'Jane is Sad'].join("\n")
    ]
  end

  it 'should concat multiple contexts processing to a single pdf' do
    @check_processing_yields_text[
      contexts = [{:someone => 'Peter', :mood => 'Happy'}, {:someone => 'Jane', :mood => 'Sad'}],
      example_name = :plain_text,
      expected_text = ['Peter is Happy', 'Jane is Sad'].join("\n")
    ]
  end

end
