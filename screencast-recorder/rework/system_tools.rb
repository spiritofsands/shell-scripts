# frozen_string_literal: true

# For screen resolution
require 'open3'

# Set of tools to work with OS
module SystemTools
  def self.which(cmd)
    path_next = ENV['PATHEXT']
    exts = path_next ? path_next.split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end

    nil
  end

  def self.access_to_dir?(dir)
    File.writable?(dir)
  end

  def self.user_is_root?
    # Linux
    user = ENV['USER']
    # Windows
    user |= ENV['USERNAME']

    user == 'root'
  end

  def self.screen_resolution
    if self::OS::linux?
      stdout, status = Open3.capture2('xdpyinfo')

      raise "Can't get screen resolution: xdpyinfo exited with status #{status.exitstatus}" \
        unless status.exitstatus.zero?

      dimensions = stdout.scan(/dimensions.*$/).map { |line| line.match(/\d+x\d+/).to_s }

      total = { x: 0, y: 0 }
      dimensions.each do |dim|
        total[:x] += dim.match(/^\d+/).to_s.to_i
        total[:y] += dim.match(/\d+$/).to_s.to_i
      end

      "#{total[:x]}x#{total[:y]}"
    elsif self::OS.windows?
    elsif self::OS.mac?
    end
  end

  # Determining the user's OS
  module OS
    def self.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def self.unix?
      !windows?
    end

    def self.linux?
      unix? && !mac?
    end
  end
end
