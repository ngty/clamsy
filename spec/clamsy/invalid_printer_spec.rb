require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class InvalidPrinter < Clamsy::BasePrinter ; end

describe 'Invalid printer' do

  behaves_like 'has standard files support'

  it 'should raise Clamsy::ImplementationNotFoundError' do
    tmp_odt = tmp_file('odt')
    lambda { InvalidPrinter.odts_to_pdf([tmp_odt], "#{__FILE__}.pdf") }.
      should.raise(Clamsy::ImplementationNotFoundError).
      message.should.equal("InvalidPrinter.odt_to_pdf not implemented.")
  end

end

