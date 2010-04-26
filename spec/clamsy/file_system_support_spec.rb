require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class FSSInstance
  include Clamsy::FileSystemSupport
  def trashable_tmp_files
    @trashable_tmp_files || []
  end
end

describe 'File system support (ensuring file exists)' do

  before do
    @instance = FSSInstance.new
    @missing_file = "#{__FILE__}.x"
    @check_test_passes_and_completes_in_n_secs = lambda do |seconds_to_wait, test_proc|
      started_at = Time.now
      test_proc.call
      (Time.now - started_at).to_i.should.equal seconds_to_wait
    end
  end

  describe '> when given N seconds to wait' do

    it 'should wait & raise Clamsy::FileNotFoundError if file eventually does not exist' do
      @check_test_passes_and_completes_in_n_secs[
        seconds_to_wait = 2, lambda do
          lambda { @instance.file_must_exist!(@missing_file, seconds_to_wait) }.
            should.raise(Clamsy::FileNotFoundError).
            message.should.equal("File '#{@missing_file}' not found.")
        end
      ]
    end

    it 'should wait & not raise Clamsy::FileNotFoundError if file eventually exists' do
      # Hmm ... don't really know how to test this yet.
      true.should.be.true
    end

  end

  describe '> when not given any seconds to wait' do

    it 'should immediately raise Clamsy::FileNotFoundError if file does not exist' do
      @check_test_passes_and_completes_in_n_secs[
        seconds_to_wait = 0, lambda do
          lambda { @instance.file_must_exist!(@missing_file) }.
            should.raise(Clamsy::FileNotFoundError).
            message.should.equal("File '#{@missing_file}' not found.")
        end
      ]
    end

    it 'should not raise Clamsy::FileNotFoundError if file exists' do
      @check_test_passes_and_completes_in_n_secs[
        seconds_to_wait = 0,
        lambda { @instance.file_must_exist!(__FILE__) }
      ]
    end

  end

end

describe 'File system support (trashable temp files)' do

  before do
    @instance = FSSInstance.new
  end

  it 'should always return a new temp file upon request' do
    (file = @instance.tmp_file).class.should.equal Tempfile
  end

  it 'should support customizing of name of requested temp file' do
    (file = @instance.tmp_file('zzyyxx')).class.should.equal Tempfile
    file.path.should.match(/zzyyxx/)
  end

  it 'should cache newly requested temp file' do
    orig_count = @instance.trashable_tmp_files.size
    file = @instance.tmp_file
    @instance.trashable_tmp_files.size.should.equal orig_count.succ
    file.path.should.equal @instance.trashable_tmp_files[-1].path
  end

  it 'should support trashing/deleting all previously requested temp files' do
    (0..1).each {|_| @instance.tmp_file }
    orig_count = @instance.trashable_tmp_files.size
    @instance.trash_tmp_files
    @instance.trashable_tmp_files.should.be.empty
  end

end
