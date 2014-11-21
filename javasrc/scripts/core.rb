# encoding: utf-8

require 'java'
import 'java.util.jar.JarFile'
import 'java.util.jar.JarEntry'
import 'org.bukkit.Bukkit'


module Rukkit
  class Core
    class << self

      def logger
        Rukkit::Util.logger
      end

      def init
        @@eventhandlers ||= []
        @@rukkit_java ||= Bukkit.plugin_manager.get_plugin('rukkit')
        @@jar ||= JarFile.new @@rukkit_java.get_class.protection_domain.code_source.location.path
      end

      def run
        # rukkit plugin repository
        logger.info "--> Rukkit plugin repository"
        repo = Rukkit::Util.plugin_repository
        repo_dir = Rukkit::Util.repo_dir
        if File.exists? repo_dir
          update_repository repo_dir
        else
          clone_repository repo_dir, repo
        end
        update_dependencies repo_dir

        # Load user scripts and plugins
        load_scripts repo_dir
        load_plugins repo_dir
      end

      def read_entry(entry_path)
        @@jar.get_input_stream(@@jar.get_entry(entry_path)).to_io.read
      end

      def load_core_scripts
        scripts = [
          :util,
          :core
        ]
        scripts.each do |script|
          logger.info("--> #{script}")
          eval read_entry("scripts/#{script}.rb")
        end
      end

      def load_scripts(repo_dir)
        logger.info "--> Load rukkit scripts"
        scripts_dir = repo_dir + '/scripts/'
        scripts = Rukkit::Util.config 'scripts', :list
        scripts.each do |script|
          logger.info "----> Load #{script}"
          script_path = scripts_dir + script + '.rb'
          require script_path
        end
      end

      def load_plugins(repo_dir)
        @@eventhandlers = []
        @@eventhandlers << Rukkit::Loader
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
            @@eventhandlers << Object.const_get(module_name)
          end
        end
      end

      def update_repository(repo_dir)
        logger.info "----> Pull repository"
        Dir.chdir(repo_dir) do
          `git pull --rebase`
        end
      end

      def clone_repository(repo_dir, repo)
        logger.info "----> Clone repository"
        `git clone #{repo} #{repo_dir}`
      end

      def update_dependencies(repo_dir)
        logger.info "----> Update dependencies"
        Dir.chdir(repo_dir) do
          `bundle install`
        end
      end

      def fire_event(event, *args)
        @@eventhandlers.each do |eventhandler|
          if eventhandler.respond_to? event
            # logger.info "event: #{eventhandler}.#{event}"
            eventhandler.send event, *args
          end
        end
      end
    end
  end

  module Loader
    extend self

    def on_command(sender, command, label, args)
      return unless label == 'rukkit'
      args = args.to_a
      case [args.shift.to_sym, args]
      when [:reload, []]
        Rukkit::Util.broadcast '[Rukkit] reloading'
        Rukkit::Core.load_core_scripts
        Rukkit::Core.load_scripts Rukkit::Util.repo_dir
        Rukkit::Core.load_plugins Rukkit::Util.repo_dir
        Rukkit::Util.broadcast '[Rukkit] reloaded'
      when [:update, []]
        Rukkit::Util.broadcast '[Rukkit] updating'
        Rukkit::Core.update_repository Rukkit::Util.repo_dir
        Rukkit::Core.load_core_scripts
        Rukkit::Core.load_scripts Rukkit::Util.repo_dir
        Rukkit::Core.load_plugins Rukkit::Util.repo_dir
        Rukkit::Util.broadcast '[Rukkit] updated'
      when [:update_self, []]
        # TODO: Self update
      else
        Rukkit::Util.logger.info('Invalid command.')
      end
    end
  end

end

Rukkit::Core.init
Rukkit::Core.run
Rukkit::Core

