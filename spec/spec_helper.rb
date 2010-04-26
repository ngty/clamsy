require 'rubygems'
require 'bacon'
require 'differ'
require 'tempfile'
require 'digest/md5'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'clamsy'

shared 'has standard files support' do
  class << self
    def trash_tmp_files
      (@trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
    end
    def tmp_file(file_name)
      ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1]
    end
  end
end

Bacon.summary_on_exit
