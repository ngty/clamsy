#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$current_dir_file = lambda {|f| File.join(File.expand_path(File.dirname(__FILE__)), f) }
$data_file = lambda {|f| $current_dir_file["data/#{f}"] }
$tmp_file = lambda {|f| $current_dir_file["tmp/#{f}"] }
require $data_file['contexts.rb']
require 'clamsy'

template_doc_path = $data_file['student_offer_letter.odt']
final_pdf_path = $tmp_file['student_offer_letters.pdf']

print "Generating #{final_pdf_path} ... "
Clamsy.process($contexts, template_doc_path, final_pdf_path)
puts "done"
