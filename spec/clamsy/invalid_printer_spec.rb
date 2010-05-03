require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class InvalidPrinter < Clamsy::BasePrinter ; end

describe 'Invalid printer' do

  describe '> converting docs to pdf' do

    behaves_like 'has standard files support'

    it 'should raise Clamsy::ImplementationNotFoundError' do
      tmp_doc = tmp_file('doc')
      lambda { InvalidPrinter.docs_to_pdf([tmp_doc], "#{__FILE__}.pdf") }.
        should.raise(Clamsy::ImplementationNotFoundError).
        message.should.equal("InvalidPrinter.doc_to_pdf not implemented.")
    end

  end

end

