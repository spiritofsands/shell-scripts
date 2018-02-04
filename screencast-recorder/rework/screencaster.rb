# frozen_string_literal: true

# Local memes
require './system_tools.rb'

# For options parsing
require 'optparse'

# For video recording
require 'streamio-ffmpeg'

# Checks if all required conditions are met
class Requirements
  DEFAULT_RECORDINGS_DIR = "#{Dir.home}/screencasts".freeze
  def initialize
    parse_options

    @fps ||= 1
    @recordings_dir ||= DEFAULT_RECORDINGS_DIR

    @deps = %w[ffmpeg skicka rtcwake]
    set_os_specific_deps

    ok?
  end

  private

  def set_os_specific_deps
    # Additional OS-specific components
    if SystemTools::OS.linux?
      @deps.concat %w[xdpyinfo]
    elsif SystemTools::OS.windows?
      # TODO
    elsif SystemTools::OS.mac?
      # TODO
    end
  end

  def ok?
    raise ArgumentError, "No access to recordings dir: #{@recordings_dir}" unless SystemTools.access_to_dir?(@recordings_dir)
    raise ArgumentError, "FPS values allowed in 1..24. Provided: #{@fps}" unless fps_ok?

    check_dependencies

    true
  end

  def parse_options
    ARGV.options do |opts|
      opts.on('-f', '--fps=val', Integer) { |fps| @fps = fps }
      opts.on('-d', '--dir=val', String)  { |dir| @recordings_dir = dir }
      opts.parse!
    end
  end

  def fps_ok?
    @fps.between?(1, 24)
  end

  def check_dependencies
    @deps.each do |program|
      raise ArgumentError, "Program #{program} is unavailable" unless SystemTools.which(program)
    end
  end
end

# Main class for recording screen
class Recorder
  def initialize
  end
end
