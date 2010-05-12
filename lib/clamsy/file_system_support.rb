require 'tempfile'
require 'digest/md5'

module Clamsy

  class FileNotFoundError < Exception ; end

  module FileSystemSupport

    def file_must_exist!(path, timeout=0)
      if timeout.zero?
        File.exists?(path) or raise_file_not_found_error(path)
      else
        0.upto(timeout.pred) {|i| File.exists?(path) ? (return true) : sleep(1) }
        raise_file_not_found_error(path)
      end
    end

    def trash_tmp_files
      (@trashable_tmp_files || []).each {|f| f.path && f.unlink }
      @trashable_tmp_files = nil
    end

    def tmp_file(basename = nil)
      basename ||= Digest::MD5.hexdigest(Time.now.to_s)
      ((@trashable_tmp_files ||= []) << Tempfile.new(basename))[-1]
    end

    protected

      def raise_file_not_found_error(path)
        raise Clamsy::FileNotFoundError.new("File '#{path}' not found.")
      end

  end
end
