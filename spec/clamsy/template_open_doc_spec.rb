require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'differ'

describe 'Template open doc' do

  def data_file(file)
    File.join(File.dirname(__FILE__), 'data', file)
  end

  describe '> initializing' do

    it 'should raise Clamsy::FileNotFoundError template doc cannot be found' do
      missing_template = data_file('missing.odt')
      lambda { Clamsy::TemplateOpenDoc.new(missing_template) }.
        should.raise(Clamsy::FileNotFoundError).
        message.should.equal("File '#{missing_template}' not found.")
    end

    it 'should raise Clamsy::TemplateDocIsCorruptedError if template doc is not a valid document' do
      invalid_template = data_file('invalid_zip_example.odt')
      lambda { Clamsy::TemplateOpenDoc.new(invalid_template) }.
        should.raise(Clamsy::TemplateDocIsCorruptedError).
        message.should.equal("Template doc '#{invalid_template}' is corrupted.")
    end

    it 'should raise Clamsy::TemplateDocContentIsCorruptedError if template doc has invalid xml content' do
      invalid_template = data_file('invalid_xml_content_example.odt')
      lambda { Clamsy::TemplateOpenDoc.new(invalid_template) }.
        should.raise(Clamsy::TemplateDocContentIsCorruptedError).
        message.should.equal("Template doc content '#{invalid_template}'/'content.xml' is corrupted.")
    end

    it 'should raise Clamsy::TemplateDocContentIsCorruptedError if has ruby syntax error' do
      invalid_template = data_file('invalid_content_example.odt')
      lambda { Clamsy::TemplateOpenDoc.new(invalid_template) }.
        should.raise(Clamsy::TemplateDocContentIsCorruptedError).
        message.should.equal("Template doc '#{invalid_template}' cannot be compiled due to (ruby) syntax error.")
    end

  end

  describe '> rendering' do

    def zip_content(file)
      Zip::ZipFile.open(file).map do |e|
        return '' if e.get_input_stream == Zip::NullInputStream
        e.get_input_stream.read
      end
    end

    def template(name)
      Clamsy::TemplateOpenDoc.new(data_file("#{name}_before.odt"))
    end

    def check_rendering_yields_expected_doc(context, example)
      generated_content = zip_content(template(example).render(context).path)
      expected_content = zip_content(data_file("#{example}_after.odt"))
      generated_content.should.be.equal expected_content
    end

    it 'should return instance of Tempfile for generated doc' do
      file = template(:plain_text).render({})
      file.class.should.equal Tempfile
    end

    it 'should do #{...} plain text replacement' do
      check_rendering_yields_expected_doc(
        {:someone => 'Peter', :mood => 'Happy'},
        :plain_text
      )
    end

    it 'should do ${...} escaped (santized) replacement' do
      check_rendering_yields_expected_doc(
        {:someone => '<Peter>', :mood => '<Happy>'},
        :escaped_text
      )
    end

    it 'should do {? ... ?} embedded ruby statements processing' do
      check_rendering_yields_expected_doc(
        {
          :everyone => [
            {:name => 'Peter', :mood => 'Happy'},
            {:name => 'Jane', :mood => 'Sad'}
          ]
        },
        :embedded_ruby
      )
    end

    it 'should do picture replacement for pictures with matching names' do
      check_rendering_yields_expected_doc(
        {:_pictures => {:to_be_replaced_pic => data_file('clamsy.png')}},
        :picture
      )
    end

    it 'should raise Clamsy::RenderedDocContentIsCorruptedError if rendering yields invalid content' do
      lambda {
        template(:plain_text).render(:someone => '<Peter>', :mood => '<Happy>')
      }.should.raise(Clamsy::RenderedDocContentIsCorruptedError).message.should.equal(
        'Rendered doc content is corrupted, use ${ ... } where text escaping is needed.'
      )
    end

  end

end
