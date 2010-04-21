require 'rubygems'
require 'bacon'
require 'differ'
require 'tempfile'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'clamsy'

shared 'has standard files support' do
  class << self
    def data_file(file)
      File.join(File.dirname(__FILE__), 'data', file)
    end
    def template_odt(name)
      data_file("#{name}_example.odt")
    end
    def expected_pdf(name)
      data_file("#{name}_example.pdf")
    end
    def comparable_content(file)
      `pdf2ps #{file} -`.grep(/^[^%][^%]?/).
        reject {|line| line =~ /^q\[\-?\d+( \-?\d+){5}\]concat\n$/ }
    end
    def trash_tmp_files
      (@trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
    end
    def tmp_file(file_name)
      ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1]
    end
  end
end

Bacon.summary_on_exit
