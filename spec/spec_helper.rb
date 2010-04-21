require 'rubygems'
require 'bacon'
require 'differ'
require 'tempfile'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'clamsy'

shared 'has standard files support' do
  class << self
    def get_data_file(file)
      File.join(File.dirname(__FILE__), 'data', file)
    end
    def get_template_odt(name)
      get_data_file("#{name}_example.odt")
    end
    def get_expected_pdf(name)
      get_data_file("#{name}_example.pdf")
    end
    def get_comparable_content(file)
      `pdf2ps #{file} -`.grep(/^[^%][^%]?/).
        reject {|line| line =~ /^q\[\-?\d+( \-?\d+){5}\]concat\n$/ }
    end
    def trash_tmp_files
      (@trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
    end
    def get_tmp_file(file_name)
      ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1]
    end
  end
end

Bacon.summary_on_exit
