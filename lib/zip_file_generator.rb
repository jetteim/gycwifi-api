require 'zip'
require 'fileutils'
# zf.write()
class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir)
    entries.delete('.')
    entries.delete('..')
    io = Zip::File.open(@output_file, Zip::File::CREATE)
    write_entries(entries, '', io)
    io.close
  end

  # A helper method to make the recursion work.
  def write_entries(entries, path, io)
    entries.each do |e|
      zip_file_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zip_file_path)
      if File.directory?(disk_file_path)
        FileUtils.mkdir_p(zip_file_path)
        subdir = Dir.entries(disk_file_path)
        subdir.delete('.')
        subdir.delete('..')
        write_entries(subdir, zip_file_path, io)
      else
        io.get_output_stream(zip_file_path) { |f| f.print(File.open(disk_file_path, 'rb').read) }
      end
    end
  end

  def self.zipdir(dirpath, filepath)
    zf = ZipFileGenerator.new(dirpath, filepath)
    zf.write
    `chmod 666 #{filepath}`
    filepath
  end
end
