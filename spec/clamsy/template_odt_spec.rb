require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Template odt' do

  describe '> initializing' do
    it 'should raise Clamsy::FileNotFoundError odt template cannot be found' do
      missing_template = "#{__FILE__}.x"
      lambda { Clamsy::TemplateOdt.new(missing_template) }.
        should.raise(Clamsy::FileNotFoundError).
        message.should.equal("File '#{missing_template}' not found.")
    end
  end

  describe '> rendering' do

    before do
      @data_file = lambda {|file| File.join(File.dirname(__FILE__), 'data', file) }
      @template = lambda {|name| Clamsy::TemplateOdt.new(@data_file["#{name}_before.odt"]) }
      @zip_content = lambda {|file| Zip::ZipFile.open(file).map {|e| e.get_input_stream.read } }
      @check_rendering_yields_expected_odt = lambda do |context, example|
        generated_content = @zip_content[@template[example].render(context).path]
        expected_content = @zip_content[@data_file["#{example}_after.odt"]]
        (generated_content - expected_content).should.be.empty
        (expected_content - generated_content).should.be.empty
      end
    end

    it 'should return instance of Tempfile for generated odt' do
      file = @template[:plain_text].render({})
      file.class.should.equal Tempfile
    end

    it 'should do #{...} plain text replacement' do
      @check_rendering_yields_expected_odt[
        context = {:someone => 'Peter', :mood => 'Happy'},
        example = :plain_text
      ]
    end

    it 'should do ${...} escaped (santized) replacement' do
      @check_rendering_yields_expected_odt[
        context = {:someone => '<Peter>', :mood => '<Happy>'},
        example = :escaped_text
      ]
    end

    it 'should do {? ... ?} embedded ruby statements processing' do
      @check_rendering_yields_expected_odt[
        context = {
          :everyone => [
            {:name => 'Peter', :mood => 'Happy'},
            {:name => 'Jane', :mood => 'Sad'}
          ]
        },
        example = :embedded_ruby
      ]
    end

    it 'should do picture replacement for pictures with matching names' do
      @check_rendering_yields_expected_odt[
        context = {:_pictures => {:to_be_replaced_pic => @data_file['clamsy.png']}},
        example = :picture
      ]
    end

  end

end
