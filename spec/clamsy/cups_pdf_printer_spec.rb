require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'clamsy', 'cups_pdf_printer')

class << Clamsy::CupsPdfPrinter
  public :tmp_pdf_path
  attr_accessor :config
end

describe 'Cups pdf printer' do

  before do
    @printer = Clamsy::CupsPdfPrinter
    @printer.config = Class.new { attr_accessor :cups_output_dir, :cups_output_file }.new
  end

  describe '> generating of tmp pdf path (using config.cups_output_file)' do

    should 'return config.cups_output_file if it is not a Proc' do
      @printer.config.cups_output_file = '/a/b/c'
      @printer.tmp_pdf_path('dummy').should.equal '/a/b/c'
    end

    should "return evaluated config.cups_output_file if it is a Proc" do
      @printer.config.cups_output_file = lambda { "/a/b/#{1+2}" }
      @printer.tmp_pdf_path('dummy').should.equal '/a/b/3'
    end

  end

  describe '> generating of tmp pdf path (using config.cups_output_file)' do

    should "use config.cups_output_dir, basename of specified file & pdf file extension" do
      @printer.config.cups_output_dir = '/a/b/c'
      @printer.tmp_pdf_path('/e/f/g/document.odt').should.equal '/a/b/c/document.pdf'
    end

  end

end

