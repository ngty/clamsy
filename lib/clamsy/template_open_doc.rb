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
    end

    private

      def initialize_template_workers
        begin
          OpenDoc.per_content_entry(@template_doc) \
            {|@entry| (@template_workers_cache ||= {})[@entry.to_s] = template_worker }
          @template_workers = lambda {|entry| @template_workers_cache[entry.to_s] }
        rescue Zip::ZipError
          raise TemplateDocIsCorruptedError.new \
            "Template doc '#{@template_doc}' is corrupted."
        end
      end

      def template_worker
        file, content = tmp_file, @entry.get_input_stream.read
        File.open(file.path, 'w') {|f| f.write(content) }
        enhance_worker_with_picture_paths(Tenjin::Template.new(file.path), content)
      end

      def enhance_worker_with_picture_paths(worker, content)
        begin
          class << worker ; attr_accessor :picture_paths ; end
          worker.picture_paths = OpenDoc.extract_picture_paths(content)
          worker
        rescue Nokogiri::XML::SyntaxError
          raise TemplateDocContentIsCorruptedError.new \
            "Template doc content '#{@template_doc}'/'#{@entry.to_s}' is corrupted."
        end
      end

  end

  private

    class OpenDoc

      def self.per_content_entry(file, &blk)
        Zip::ZipFile.open(file) do |zip|
          zip.select {|entry| entry.file? && entry.to_s =~ /\.xml$/ }.each do |entry|
            class << entry ; attr_accessor :zip ; end
            entry.zip = zip
            yield(entry)
          end
        end
      end

      def self.string_to_xml_doc(string)
        Nokogiri::XML(string.gsub(':','')) do |config|
          config.options = Nokogiri::XML::ParseOptions::STRICT
        end
      end

      def self.extract_picture_paths(content)
        string_to_xml_doc(content).
          xpath('//drawframe').inject({}) do |memo, node|
            name = node.attributes['drawname']
            path = node.xpath(%\//drawimage/@xlinkhref\)[0]
            memo.merge(path ? {:"#{name.value}" => path.value} : {})
          end
      end

      def initialize(file, workers, context)
        @file, @workers, @context = file, workers, context
      end

      def transform
        OpenDoc.per_content_entry(@file.path) do |@entry|
          @entry.zip.get_output_stream(@entry.to_s) do |@io|
            replace_texts ; replace_pictures
          end
        end
        @file
      end

      private

        def replace_texts
          begin
            @io.write(content = @workers[@entry].render(@context))
            OpenDoc.string_to_xml_doc(content)
          rescue Nokogiri::XML::SyntaxError
            raise Clamsy::RenderedDocContentIsCorruptedError.new \
              'Rendered doc content is corrupted, use ${ ... } where text escaping is needed.'
          end
        end

        def replace_pictures
          (@context[:_pictures] || {}).each do |name, src_path|
            (dest_path = @workers[@entry].picture_paths[:"#{name}"]) \
              && @entry.zip.replace(dest_path, src_path)
          end
        end

    end

end
