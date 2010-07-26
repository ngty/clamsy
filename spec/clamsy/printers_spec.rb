require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Printers' do

  describe '> getting a printer' do

    should 'raise Clamsy::PrinterNotFoundError when printer is not yet defined' do
      lambda { Clamsy::Printers.get('super_duper', 'dummy_config') }.
        should.raise(Clamsy::PrinterNotFoundError).
        message.should.equal("Printer 'super_duper' cannot be found.")
    end

    should "return Clamsy::Printers::CupsPdf when printer is :cups_pdf" do
      Clamsy::Printers.get(:cups_pdf, 'dummy_config').should.equal(Clamsy::Printers::CupsPdf)
    end

    should "return Clamsy::Printers::JODConverter when printer is :jod_converter" do
      Clamsy::Printers.get(:jod_converter, 'dummy_config').should.equal(Clamsy::Printers::JODConverter)
    end

  end

end
