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

      def reload_jar
        @@jar = JarFile.new @@rukkit_java.get_class.protection_domain.code_source.location.path
      end

      def run
        # rukkit plugin repository
        repo = Rukkit::Util.plugin_repository
        repo_dir = Rukkit::Util.repo_dir
        clone_or_update_repository repo_dir, repo

        # Load user scripts and plugins
        load_scripts repo_dir
        load_plugins repo_dir
      end

      def read_entry(entry_path)
        @@jar.get_input_stream(@@jar.get_entry(entry_path)).to_io.read
      end

      def update_load_paths
        gems_dirs = Rukkit::Util.gems_dirs
        $LOAD_PATH.concat(Dir.glob File.expand_path(gems_dirs))
      end

      def load_core_scripts
        logger.info "--> Load rukkit core scripts"
        reload_jar
        scripts = [
          :util,
          :core
        ]
        scripts.each do |script|
          logger.info("----> #{script}")
          eval read_entry("scripts/#{script}.rb")
        end
      end

      def load_scripts(repo_dir)
        update_load_paths
        logger.info "--> Load rukkit user scripts"
        scripts_dir = repo_dir + '/scripts/'
        scripts = Rukkit::Util.config 'scripts', :list
        scripts.each do |script|
          logger.info "----> Load #{script}"
          script_path = scripts_dir + script + '.rb'
          load script_path
        end
      end

      def load_plugins(repo_dir)
        update_load_paths
        @@eventhandlers = []
        logger.info "--> Load rukkit user plugins"
        plugins_dir = repo_dir + '/plugins/'
        plugins = Rukkit::Util.config 'plugins', :list
        plugins.each do |plugin|
          logger.info "----> Load #{plugin}"
          plugin_path = plugins_dir + plugin + '.rb'
          load plugin_path

          # register plugin to eventhandler mappings
          module_name = Rukkit::Util.camelize plugin
          if eval("defined? #{module_name}") == 'constant'
            @@eventhandlers << Object.const_get(module_name)
            # logger.info "------> #{@@eventhandlers.map(&:to_s)}"
          end
        end
        logger.info "----> #{@@eventhandlers.map(&:to_s)}"
        @@eventhandlers.unshift Rukkit::Loader
      end

      def clone_or_update_repository(repo_dir, repo)
        logger.info "--> Rukkit plugin repository"
        if File.exists? repo_dir
          update_repository repo_dir
        else
          clone_repository repo_dir, repo
        end
        update_dependencies repo_dir
      end

      def update_repository(repo_dir)
        logger.info "----> Pull repository"
        Dir.chdir(repo_dir) do
          `git pull --rebase`.split("\n").each do |l|
            logger.info "------> #{l}"
          end
        end
      end

      def clone_repository(repo_dir, repo)
        logger.info "----> Clone repository"
        `git clone #{repo} #{repo_dir}`.split("\n").each do |l|
          logger.info "------> #{l}"
        end
      end

      def update_dependencies(repo_dir)
        logger.info "----> Update dependencies"
        jruby = 'java -jar ~/.m2/repository/org/jruby/jruby-complete/1.7.16.1/jruby-complete-1.7.16.1.jar'
        # For disable rbenv shims
        ENV['PATH'] = ENV['PATH'].split(":").reject{
          |path| path == "#{ENV['HOME']}/.rbenv/shims"
        }.join(":")

        `mkdir -p #{Rukkit::Util.gem_home}`
        ENV['GEM_HOME'] = Rukkit::Util.gem_home

        Dir.chdir(repo_dir) do
          if `#{jruby} -S gem list | grep bundler` == ''
            logger.info "------> Install bundler gem"
            `#{jruby} -S gem install bundler`.split("\n").each do |l|
              logger.info "--------> #{l}"
            end
          end
          logger.info "------> Install rubygems"
          `#{jruby} -S #{Rukkit::Util.bundler_path} install --path /rukkit/vendor/bundler`.split("\n").each do |l|
            logger.info "--------> #{l}"
          end
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
      case args.shift.to_sym
      when :reload
        Lingr.post '[RUKKIT] reloading'
        Rukkit::Util.broadcast '[Rukkit] reloading'
        Rukkit::Core.load_core_scripts
        Rukkit::Core.load_scripts Rukkit::Util.repo_dir
        Rukkit::Core.load_plugins Rukkit::Util.repo_dir
        Rukkit::Util.broadcast '[Rukkit] reloaded'
        Lingr.post '[RUKKIT] reloaded'
      when :update
        Lingr.post '[RUKKIT] updating'
        Rukkit::Util.broadcast '[Rukkit] updating'
        Rukkit::Core.clone_or_update_repository Rukkit::Util.repo_dir, Rukkit::Util.plugin_repository
        Rukkit::Core.load_core_scripts
        Rukkit::Core.load_scripts Rukkit::Util.repo_dir
        Rukkit::Core.load_plugins Rukkit::Util.repo_dir
        Rukkit::Util.broadcast '[Rukkit] updated'
        Lingr.post '[RUKKIT] updated'
      when :eval
        # TODO: Safe eval
      when :update_self
        # TODO: Self update
      else
        Rukkit::Util.logger.info('Invalid command.')
      end
    end
  end

end

Rukkit::Core.init
Rukkit::Core

