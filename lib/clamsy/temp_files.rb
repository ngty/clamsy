require 'tempfile'

module Clamsy
  module TempFiles

    def trash_tmp_files
      (@trashable_tmp_files || []).select {|f| f.path }.map(&:unlink)
    end

    def tmp_file(file_name)
      ((@trashable_tmp_files ||= []) << Tempfile.new(file_name))[-1]
    end

  end
end
