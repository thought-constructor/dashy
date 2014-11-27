# CodeKit needs relative paths
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require "dashy/generator"

unless defined?(Sass)
  require 'sass'
end

require "sass/script/functions/dashy"

module Dashy
  if defined?(Rails) && defined?(Rails::Engine)
    class Engine < ::Rails::Engine
      require 'dashy/engine'
    end

    module Rails
      class Railtie < ::Rails::Railtie
        rake_tasks do
          load "tasks/install.rake"
        end
      end
    end
  else
    dashy_path = File.expand_path("../../app/assets/stylesheets", __FILE__)
    ENV["SASS_PATH"] = [ENV["SASS_PATH"], dashy_path].compact.join(File::PATH_SEPARATOR)
  end
end

# Gem structure adapted from thoughtbot/bourbon...
