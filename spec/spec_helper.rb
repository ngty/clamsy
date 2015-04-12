require 'rubygems'
require 'bacon'
require 'tempfile'
require 'digest/md5'
require 'yaml'

unless Object.const_defined?(:CLAMSY_LIB_DIR)
  CLAMSY_LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','lib')
  CLAMSY_SPEC_DIR = File.expand_path(File.dirname(__FILE__))
  CLAMSY_BUNDLED_CONFIG = File.join(CLAMSY_LIB_DIR, 'clamsy.yml')
end

$LOAD_PATH.unshift(CLAMSY_SPEC_DIR)
$LOAD_PATH.unshift(CLAMSY_LIB_DIR)
require 'clamsy'

def Module.backup_methods(meths)
  meths.each {|meth| alias_method :"_orig_#{meth}", :"#{meth}" }
end

def Module.recover_methods(meths)
  meths.each {|meth| alias_method :"#{meth}", :"_orig_#{meth}" }
end

def Clamsy.unconfigure
  @config = nil
end

def trash_tmp_files
  ($trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
  $trashable_tmp_files = nil
end

def tmp_file(args)
  (($trashable_tmp_files ||= []) << Tempfile.new(args))[-1]
end

def having_same_content_as(expected)
  lambda {|file| Gjman::PDF.match?(file, expected) }
end

Bacon.summary_on_exit
