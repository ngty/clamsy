require 'digest/md5'
require 'nokogiri'
require 'zip/zip'
require 'ftools'

module Clamsy
  class TemplateOdt

    include Clamsy::FileSystemSupport

    def initialize(template_odt)
      file_must_exist!(@template_odt = template_odt)
    end

    def render(context)
      @context_id = Digest::MD5.hexdigest(context.to_s)
      Zip::ZipFile.open(working_odt.path) do |@zip|
        @zip.select {|entry| entry.file? && entry.to_s =~ /\.xml$/ }.each do |entry|
          replace_texts(entry, context)
          replace_pictures(entry, context[:_pictures] || {})
        end
      end
      working_odt
    end

    private

      def replace_texts(entry, context)
        @zip.get_output_stream(entry.to_s) do |io|
          begin
            string_to_doc(content = workers[entry].render(context))
            io.write(content)
          rescue Nokogiri::XML::SyntaxError
            raise Clamsy::FileCorruptedError.new(
              'Rendered file is corrupted, use ${ ... } where text escaping is needed.'
            )
          end
        end
      end

      def replace_pictures(entry, pictures)
        xpaths = lambda {|name| %\//drawframe[@drawname="#{name}"]/drawimage/@xlinkhref\ }
        doc = string_to_doc(entry.get_input_stream.read)
        pictures.each do |name, path|
          (node = doc.xpath(xpaths[name])[0]) && @zip.replace(node.value, path)
        end
      end

      def working_odt
        (@working_odts ||= {})[@context_id] ||=
          begin
            dest_odt = tmp_file
            File.copy(@template_odt, dest_odt.path) ; dest_odt
          end
      end

      def workers
        lambda do |entry|
          (@workers ||= {})[entry.to_s] ||=
            begin
              tmp_xml = tmp_file
              tmp_xml.write(entry.get_input_stream.read)
              tmp_xml.close
              Tenjin::Template.new(tmp_xml.path)
            end
        end
      end

      def string_to_doc(string)
        Nokogiri::XML(string.gsub(':','')) do |config|
          config.options = Nokogiri::XML::ParseOptions::STRICT
        end
      end

  end
end
