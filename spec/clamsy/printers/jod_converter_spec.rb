require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(Clamsy::ROOT, 'clamsy', 'printers', 'jod_converter')

class << Clamsy::Printers::JODConverter
  public :ooffice_server_must_be_running!, :ooffice_server_port, :run_ooffice_server
  attr_accessor :config
end

describe 'JODConverter printer' do

  before do
    @printer = Clamsy::Printers::JODConverter
    @printer.config = Class.new { attr_accessor :ooffice_server_args, :ooffice_bin }.new
    @ooffice_server_port = '89999' # see <PROJECT_ROOT>/spec/fake_ooffice_server.rb
  end

  describe '> determining ooffice server port' do
    should 'grab port number from config.ooffice_server_args' do
      @printer.config.ooffice_server_args = %\-headless -nofirststartwizard -accept="\ +
        %\socket,host=localhost,port=#{@ooffice_server_port};urp;StarOffice.Service"\
      @printer.ooffice_server_port.should.equal @ooffice_server_port
    end
  end

  describe '> running ooffice server' do

    before do
      $ooffice_server_port = @ooffice_server_port
      @pid_file = tmp_file('fake_ooffice_server.pid').path
      @printer.config.ooffice_bin = File.join(CLAMSY_SPEC_DIR, 'fake_ooffice_server.rb')
      class << @printer
        alias_method :orig_ooffice_server_port, :ooffice_server_port
        def ooffice_server_port ; $ooffice_server_port ; end
      end
    end

    after do
      pid = IO.read(@pid_file).to_i rescue 0
      Process.kill('SIGHUP', pid) unless pid.zero?
      trash_tmp_files
      class << @printer
        alias_method :ooffice_server_port, :orig_ooffice_server_port
      end
    end

    should 'start ooffice server binding to specified server port' do
      @printer.config.ooffice_server_args = "spawn #{@ooffice_server_port} #{@pid_file}"
      lambda { @printer.run_ooffice_server }.should.not.raise(Clamsy::OofficeServerNotStartedError)
    end

    should 'raise Clamsy::OofficeServerNotStartedError if ooffice server is not running' do
      @printer.config.ooffice_server_args = "no #{@ooffice_server_port} #{@pid_file}"
      lambda { @printer.run_ooffice_server }.should.raise(Clamsy::OofficeServerNotStartedError)
    end
  end

end

