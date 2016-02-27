require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Merging pdfs' do

  class << self

    def description(name, size)
      'handle %s %s %s' % [size > 1 ? 'multi' : 'single', name.split('_')].flatten
    end

    def data_file
      lambda {|name| File.expand_path("../data/#{name}.pdf", __FILE__) }
    end

    def should_correctly_merge(name, pages)
      should description(name.to_s, pages.size) do
        sources = pages.map{|n| data_file["#{name}-#{n}"] }
        expected = data_file["#{name}-m#{pages.join}"]
        merged = Clamsy::PDF.merge(sources, tmp_file([name, '.pdf']).path)
        merged.should.be having_same_content_as(expected)
      end
    end

  end

  after do
    trash_tmp_files
  end

  should_correctly_merge 'a4_portrait', [1]
  should_correctly_merge 'a4_portrait', [1,2,3]
  should_correctly_merge 'a4_landscape', [1]
  should_correctly_merge 'a4_landscape', [1,2,3]
  should_correctly_merge 'letter_portrait', [1]
  should_correctly_merge 'letter_portrait', [1,2,3]
  should_correctly_merge 'letter_landscape', [1]
  should_correctly_merge 'letter_landscape', [1,2,3]

end
