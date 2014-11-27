require 'dashy/version'
require "fileutils"
require 'thor'

module Dashy
  class Generator < Thor
    map ['-v', '--version'] => :version

    desc 'install', 'Install Dashy into your project'
    method_options :path => :string, :force => :boolean
    def install
      if dashy_files_already_exist? && !options[:force]
        puts "Dashy files already installed, doing nothing."
      else
        install_files
        puts "Dashy files installed to #{install_path}/"
      end
    end

    desc 'update', 'Update Dashy'
    method_options :path => :string
    def update
      if dashy_files_already_exist?
        remove_dashy_directory
        install_files
        puts "Dashy files updated."
      else
        puts "No existing dashy installation. Doing nothing."
      end
    end

    desc 'version', 'Show Dashy version'
    def version
      say "Dashy #{Dashy::VERSION}"
    end

    private

    def dashy_files_already_exist?
      install_path.exist?
    end

    def install_path
      @install_path ||= if options[:path]
          Pathname.new(File.join(options[:path], 'dashy'))
        else
          Pathname.new('dashy')
        end
    end

    def install_files
      make_install_directory
      copy_in_scss_files
    end

    def remove_dashy_directory
      FileUtils.rm_rf("dashy")
    end

    def make_install_directory
      FileUtils.mkdir_p(install_path)
    end

    def copy_in_scss_files
      FileUtils.cp_r(all_stylesheets, install_path)
    end

    def all_stylesheets
      Dir["#{stylesheets_directory}/*"]
    end

    def stylesheets_directory
      File.join(top_level_directory, "app", "assets", "stylesheets")
    end

    def top_level_directory
      File.dirname(File.dirname(File.dirname(__FILE__)))
    end
  end
end

# Gem structure adapted from thoughtbot/bourbon...
