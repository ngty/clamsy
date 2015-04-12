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

    def initialize(template_doc)
      FileSystem.file_must_exist!(@template_doc = template_doc)
      initialize_template_workers
    end

    def render(context)
      File.copy(@template_doc, (file = tmp_doc(context)).path)
      OpenDoc.new(file, @template_workers, context).transform
    end

    private

      def tmp_doc(context)
        @template_doc_suffix ||= ".#{@template_doc.to_s.split('.').last}"
        uid = Digest::MD5.hexdigest(Time.now.to_s + context.to_s)
        tmp_file([uid, @template_doc_suffix])
      end

      def initialize_template_workers
        begin
          OpenDoc.per_content_entry(@template_doc) \
            {|entry| (@template_workers_cache ||= {})[entry.to_s] = template_worker(entry) }
          @template_workers = lambda {|entry| @template_workers_cache[entry.to_s] }
        rescue Zip::ZipError
          raise TemplateDocIsCorruptedError.new \
            "Template doc '#{@template_doc}' is corrupted."
        end
      end

      def template_worker(entry)
        file, content = FileSystem.tmp_file, entry.get_input_stream.read
        File.open(file.path, 'w') {|f| f.write(content) }
        worker = Tenjin::Template.new(file.path)
        check_worker_has_valid_syntax(worker = Tenjin::Template.new(file.path))
        enhance_worker_with_picture_paths(worker, content, entry)
      end

      def check_worker_has_valid_syntax(worker)
        begin
          worker.render
        rescue SyntaxError
          raise TemplateDocContentIsCorruptedError.new \
            "Template doc '#{@template_doc}' cannot be compiled due to (ruby) syntax error."
        rescue
          # Well, other errors are expected since context is not yet defined.
        end
      end


      def enhance_worker_with_picture_paths(worker, content, entry)
        begin
          class << worker ; attr_accessor :picture_paths ; end
          worker.picture_paths = OpenDoc.extract_picture_paths(content)
          worker
        rescue Nokogiri::XML::SyntaxError
          raise TemplateDocContentIsCorruptedError.new \
            "Template doc content '#{@template_doc}'/'#{entry.to_s}' is corrupted."
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
        return Nokogiri::XML('') if string.empty?
        Nokogiri::XML(string.gsub(':','')) do |config|
          config.options = Nokogiri::XML::ParseOptions::STRICT
        end
      end

      def self.extract_picture_paths(content)
        doc = string_to_xml_doc(content)
        nodes = lambda {|path| doc.xpath(path) }
        nodes['//drawframe/@drawname'].inject({}) do |memo, node|
          path = nodes[%\//drawframe[@drawname="#{node.value}"]//drawimage/@xlinkhref\][0]
          memo.merge(path ? {:"#{node.value}" => path.value} : {})
        end
      end

      def initialize(file, workers, context)
        @file, @workers, @context = file, workers, context
      end

      def transform
        OpenDoc.per_content_entry(@file.path) do |entry|
          entry.zip.get_output_stream(entry.to_s) do |io|
            replace_texts(entry, io) ; replace_pictures(entry, io)
          end
        end
        @file
      end

      private

        def replace_texts(entry, io)
          begin
            io.write(content = @workers[entry].render(@context))
            OpenDoc.string_to_xml_doc(content)
          rescue Nokogiri::XML::SyntaxError
            raise Clamsy::RenderedDocContentIsCorruptedError.new \
              'Rendered doc content is corrupted, use ${ ... } where text escaping is needed.'
          end
        end

        def replace_pictures(entry, io)
          (@context[:_pictures] || {}).each do |name, src_path|
            (dest_path = @workers[entry].picture_paths[:"#{name}"]) \
              && entry.zip.replace(dest_path, src_path)
          end
        end

    end

end
