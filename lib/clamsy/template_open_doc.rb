require 'digest/md5'
require 'nokogiri'
require 'zip/zip'
require 'ftools'

module Clamsy

  class TemplateDocIsNotFoundError < Exception ; end
  class TemplateDocIsCorruptedError < Exception ; end
  class TemplateDocContentIsCorruptedError < Exception ; end
  class RenderedDocContentIsCorruptedError < Exception ; end

  class TemplateOpenDoc

    include Clamsy::FileSystemSupport

    def initialize(template_doc)
      file_must_exist!(@template_doc = template_doc)
      initialize_template_workers
    end

    def render(context)
      File.copy(@template_doc, (file = tmp_file).path)
      OpenDoc.new(file, @template_workers, context).transform
      file
    end

    private

      def initialize_template_workers
        begin
          OpenDoc.per_content_entry(@template_doc) do |entry|
            (@template_workers ||= {})[entry.to_s] = template_worker(entry)
          end
        rescue Zip::ZipError
          raise TemplateDocIsCorruptedError.new \
            "Template doc '#{@template_doc}' is corrupted."
        end
      end

      def template_worker(entry)
        begin
          file, content = tmp_file, entry.get_input_stream.read
          file.write(content) ; file.close
          OpenDoc.string_to_xml_doc(content) # check validity of xml content
          Tenjin::Template.new(file.path)
        rescue Nokogiri::XML::SyntaxError
          raise TemplateDocContentIsCorruptedError.new \
            "Template doc content '#{@template_doc}'/'#{entry.to_s}' is corrupted."
        end
      end

  end

  private

    class OpenDoc

      class << self

        def per_content_entry(file, &blk)
          Zip::ZipFile.open(file) do |zip|
            zip.select {|entry| entry.file? && entry.to_s =~ /\.xml$/ }.each do |entry|
              class << entry ; attr_accessor :zip ; end
              entry.zip = zip
              yield(entry)
            end
          end
        end

        def string_to_xml_doc(string)
          Nokogiri::XML(string.gsub(':','')) do |config|
            config.options = Nokogiri::XML::ParseOptions::STRICT
          end
        end

      end

      def initialize(file, workers, context)
        @file, @workers, @context = file, workers, context
      end

      def transform
        OpenDoc.per_content_entry(@file.path) do |@entry|
          @entry.zip.get_output_stream(@entry.to_s) do |io|
            begin
              content = @workers[@entry.to_s].render(@context)
              io.write(content)
              @xml_doc = OpenDoc.string_to_xml_doc(content)
              replace_pictures
              @xml_doc = nil
            rescue Nokogiri::XML::SyntaxError
              raise Clamsy::RenderedDocContentIsCorruptedError.new \
                'Rendered doc content is corrupted, use ${ ... } where text escaping is needed.'
            end
          end
        end
      end

      private

        def replace_pictures
          (@context[:_pictures] || {}).each do |name, src_path|
            (dest_path = picture_dest_path(name)) && @entry.zip.replace(dest_path, src_path)
          end
        end

        def picture_dest_path(name)
          node = @xml_doc.xpath(%\//drawframe[@drawname="#{name}"]/drawimage/@xlinkhref\)[0]
          node && node.value
        end

    end

end
