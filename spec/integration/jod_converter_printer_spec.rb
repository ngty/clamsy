require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'has_integration_support_shared_spec')

describe "Clamsy (using JODConverter printer)" do

  before do
    Clamsy.configure {|config| config.printer = 'jod_converter' }
  end

  behaves_like 'has integration support'

end
