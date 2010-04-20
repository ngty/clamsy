require 'rubygems'
require 'bacon'
require 'differ'
require 'tempfile'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'clamsy'

Bacon.summary_on_exit
