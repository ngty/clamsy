require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'has_integration_support_shared_spec')

describe "Clamsy (using Cups-PDF printer)" do

  before do
    @printer = 'cups_pdf'
    Clamsy.configure{|config| config.printer = @printer }
  end

  behaves_like 'has integration support'

end
