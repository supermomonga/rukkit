# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'


module Rukkit
  class Core

    def logger
      Rukkit::Util.logger
    end

    def initialize
      @eventhandlers = []
    end

    def run
      # rukkit plugin repository
      logger.info "--> Rukkit plugin repository"
      repo = Rukkit::Util.plugin_repository
      repo_dir = Rukkit::Util.rukkit_dir + 'repository'

      if File.exists? repo_dir
        update_repository repo_dir
      else
        clone_repository repo_dir, repo
      end
      update_dependencies repo_dir

      # Load scripts
      logger.info "--> Load rukkit scripts"
      scripts_dir = repo_dir + '/scripts/'
      scripts = Rukkit::Util.config 'scripts', :list
      scripts.each do |script|
        logger.info "----> Load #{script}"
        script_path = scripts_dir + script + '.rb'
        require script_path
      end

      # Load plugins
      logger.info "--> Load rukkit plugins"
      plugins_dir = repo_dir + '/plugins/'
      plugins = Rukkit::Util.config 'plugins', :list
      plugins.each do |plugin|
        logger.info "----> Load #{plugin}"
        plugin_path = plugins_dir + plugin + '.rb'
        require plugin_path

        # register plugin to eventhandler mappings
        module_name = Rukkit::Util.camelize plugin
        if eval("defined? #{module_name}") == 'constant'
          @eventhandlers << Object.const_get(module_name)
        end
      end
    end

    def update_repository(repo_dir)
      logger.info "----> Pull repository"
      `cd #{repo_dir}; git pull --rebase`
    end

    def clone_repository(repo_dir, repo)
      logger.info "----> Clone repository"
      `git clone #{repo} #{repo_dir}`
    end

    def update_dependencies(repo_dir)
      logger.info "----> Update dependencies"
      `cd #{repo_dir}; bundle install`
    end

    def fire_event(event, *args)
      @eventhandlers.each do |eventhandler|
        if eventhandler.respond_to? event
          # logger.info "event: #{eventhandler}.#{event}"
          eventhandler.send event, *args
        end
      end
    end

  end
end

core = Rukkit::Core.new
core.run
core

