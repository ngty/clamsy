require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Base printer' do

  describe '> getting any printer' do

    should 'raise Clamsy::PrinterNotFoundError when printer is not yet defined' do
      lambda { Clamsy::BasePrinter.get('super_duper', 'dummy_config') }.
        should.raise(Clamsy::PrinterNotFoundError).
        message.should.equal("Printer 'super_duper' cannot be found.")
    end

    should "return Clamsy::CupsPdfPrinter when printer is 'cups_pdf'" do
      Clamsy::BasePrinter.get('cups_pdf', 'dummy_config').should.equal Clamsy::CupsPdfPrinter
    end

  end

end
