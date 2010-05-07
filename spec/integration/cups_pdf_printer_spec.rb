require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'has_integration_support_shared_spec')

describe "Clamsy (using Cups-PDF printer)" do

  before do
    Clamsy.configure do |config|
      config.printer = 'cups_pdf'
    end
  end

  behaves_like 'has integration support'

end
