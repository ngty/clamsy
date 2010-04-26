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
          @zip.get_output_stream(entry.to_s) {|io| io.write(workers[entry].render(context)) }
          replace_pictures(entry, context[:_pictures] || {})
        end
      end
      working_odt
    end

    private

      def replace_pictures(entry, pictures)
        xpaths = lambda {|name| %\//drawframe[@drawname="#{name}"]/drawimage/@xlinkhref\ }
        doc = Nokogiri::XML(entry.get_input_stream.read.gsub(':','')) # Hack to avoid namespace error
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

  end
end
