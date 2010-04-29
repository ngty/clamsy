require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Template open doc' do

  before do
    @data_file = lambda {|file| File.join(File.dirname(__FILE__), 'data', file) }
  end

  describe '> initializing' do

    it 'should raise Clamsy::FileNotFoundError template doc cannot be found' do
      missing_template = @data_file['missing.odt']
      lambda { Clamsy::TemplateOpenDoc.new(missing_template) }.
        should.raise(Clamsy::FileNotFoundError).
        message.should.equal("File '#{missing_template}' not found.")
    end

    it 'should raise Clamsy::TemplateDocIsCorruptedError if template doc is not a valid document' do
      invalid_template = @data_file['invalid_zip_example.odt']
      lambda { Clamsy::TemplateOpenDoc.new(invalid_template) }.
        should.raise(Clamsy::TemplateDocIsCorruptedError).
        message.should.equal("Template doc '#{invalid_template}' is corrupted.")
    end

    it 'should raise Clamsy::TemplateDocContentIsCorruptedError if template doc has invalid content' do
      invalid_template = @data_file['invalid_content_example.odt']
      lambda { Clamsy::TemplateOpenDoc.new(invalid_template) }.
        should.raise(Clamsy::TemplateDocContentIsCorruptedError).
        message.should.equal("Template doc content '#{invalid_template}'/'content.xml' is corrupted.")
    end

  end

  describe '> rendering' do

    before do
      @zip_content = lambda {|file| Zip::ZipFile.open(file).map {|e| e.get_input_stream.read } }
      @template = lambda {|name| Clamsy::TemplateOpenDoc.new(@data_file["#{name}_before.odt"]) }
      @check_rendering_yields_expected_doc = lambda do |context, example|
        generated_content = @zip_content[@template[example].render(context).path]
        expected_content = @zip_content[@data_file["#{example}_after.odt"]]
        (generated_content - expected_content).should.be.empty
        (expected_content - generated_content).should.be.empty
      end
    end

    it 'should return instance of Tempfile for generated doc' do
      file = @template[:plain_text].render({})
      file.class.should.equal Tempfile
    end

    it 'should do #{...} plain text replacement' do
      @check_rendering_yields_expected_doc[
        context = {:someone => 'Peter', :mood => 'Happy'},
        example = :plain_text
      ]
    end

    it 'should do ${...} escaped (santized) replacement' do
      @check_rendering_yields_expected_doc[
        context = {:someone => '<Peter>', :mood => '<Happy>'},
        example = :escaped_text
      ]
    end

    it 'should do {? ... ?} embedded ruby statements processing' do
      @check_rendering_yields_expected_doc[
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
      @check_rendering_yields_expected_doc[
        context = {:_pictures => {:to_be_replaced_pic => @data_file['clamsy.png']}},
        example = :picture
      ]
    end

    it 'should raise Clamsy::RenderedDocContentIsCorruptedError if rendering yields invalid content' do
      lambda {
        @template[:plain_text].render(:someone => '<Peter>', :mood => '<Happy>')
      }.should.raise(Clamsy::RenderedDocContentIsCorruptedError).message.should.equal(
        'Rendered doc content is corrupted, use ${ ... } where text escaping is needed.'
      )
    end

  end

end
