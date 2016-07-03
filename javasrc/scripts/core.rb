# encoding: utf-8

require 'java'
import 'java.util.jar.JarFile'
import 'java.util.jar.JarEntry'
import 'org.bukkit.Bukkit'

module Rukkit
  class Core
    class << self

      def log
        Rukkit::Util.log
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
        unload_plugins
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
        log.info "--> Load rukkit core scripts"
        reload_jar
        scripts = [
          :util,
          :core
        ]
        scripts.each do |script|
          log.info("----> #{script}")
          eval read_entry("scripts/#{script}.rb")
        end
      end

      def load_scripts(repo_dir)
        update_load_paths
        log.info "--> Load rukkit user scripts"
        scripts_dir = repo_dir + '/scripts/'
        scripts = Rukkit::Util.config 'scripts', :list
        scripts.each do |script|
          script_path = scripts_dir + script + '.rb'
          log.info "----> Load #{script}"
          log.info "------> Load #{script_path}"
          load script_path
        end
      end

      def unload_plugins
        @@eventhandlers ||= []
        @@eventhandlers.each do |eh|
          eh.deinitialize if eh.respond_to? :deinitialize
        end
      end

      def load_plugins(repo_dir)
        update_load_paths
        @@eventhandlers = []
        log.info "--> Load rukkit user plugins"
        plugins_dir = repo_dir + '/plugins/'
        plugins = Rukkit::Util.config 'plugins', :list
        plugins.each do |plugin|
          log.info "----> Load #{plugin}"
          plugin_path = plugins_dir + plugin + '.rb'
          load plugin_path

          # register plugin to eventhandler mappings
          module_name = Rukkit::Util.camelize(plugin)
          if eval("defined? #{module_name}") == 'constant'
            @@eventhandlers << Object.const_get(module_name)
            # log.info "------> #{@@eventhandlers.map(&:to_s)}"
          end
        end
        log.info "----> #{@@eventhandlers.map(&:to_s)}"
        @@eventhandlers.unshift Rukkit::Loader
      end

      def clone_or_update_repository(repo_dir, repo)
        log.info "--> Rukkit plugin repository"
        if File.exists? repo_dir
          update_repository repo_dir
        else
          clone_repository repo_dir, repo
        end
        update_dependencies repo_dir
      end

      def update_repository(repo_dir)
        log.info "----> Pull repository"
        Dir.chdir(repo_dir) do
          `git pull --rebase`.split("\n").each do |l|
            log.info "------> #{l}"
          end
        end
      end

      def clone_repository(repo_dir, repo)
        log.info "----> Clone repository"
        `git clone #{repo} #{repo_dir}`.split("\n").each do |l|
          log.info "------> #{l}"
        end
      end

      def update_dependencies(repo_dir)
        log.info "----> Update dependencies"

        # check timestamp
        if @@rukkit_java.jedis
          if Dir.exist? Rukkit::Util.bundler_gems_dir
            gemfile = "#{repo_dir}/Gemfile"
            begin
              local_modtime = File.mtime(gemfile).to_f
              last_modtime = @@rukkit_java.jedis.get 'last_modtime'

              log.config "local_modtime = #{local_modtime}"
              log.config "last_modtime = #{last_modtime}"

              if not last_modtime or local_modtime > last_modtime.to_f
                @@rukkit_java.jedis.set 'last_modtime', local_modtime.to_s
              else
                log.info "------> Skipped."
                return
              end
            rescue => e
              log.warning "------> Cannot get last modification time for #{gemfile}."
              log.warning "------> #{e}"
            end
          end
        end

        if Rukkit::Util.jruby_path
          jruby = "java -jar #{Rukkit::Util.jruby_path}"
          # For disable rbenv shims
          ENV['PATH'] = ENV['PATH'].split(":").reject{
            |path| path == "#{ENV['HOME']}/.rbenv/shims"
          }.join(":")

          `mkdir -p #{Rukkit::Util.gem_home}`
          ENV['GEM_HOME'] = Rukkit::Util.gem_home

          Dir.chdir(repo_dir) do
            if `#{jruby} -S gem list | grep bundler` == ''
              log.info "------> Install bundler gem"
              `#{jruby} -S gem install bundler`.split("\n").each do |l|
                log.info "--------> #{l}"
              end
            end
            log.info "------> Install rubygems"
            `#{jruby} -S #{Rukkit::Util.bundler_path} install --path #{Rukkit::Util.bundler_gems_dir}`.split("\n").each do |l|
              log.info "--------> #{l}"
            end
          end
        else
          log.info "------> JRuby is not found. Skip installing gems."
        end
      end

      def fire_event(event, *args)
        results = @@eventhandlers.select { |eventhandler|
          eventhandler.respond_to? event
        }.map { |eventhandler|
          # log.info "event: #{eventhandler}.#{event}"
          eventhandler.send event, *args
        }
        results ? results.flatten.compact.uniq : nil
      end
    end
  end

  module Loader
    extend self

    def on_command(sender, command, label, args)
      return unless %w[rukkit rkt].include?(label)
      args = args.to_a
      return if args.empty?

      case args.shift.to_sym
      when :reload
        Bukkit.plugin_manager.get_plugin('rukkit').reload_plugins
      when :update
        Bukkit.plugin_manager.get_plugin('rukkit').update_plugins
      when :eval
        # TODO: Safe eval
      when :update_self
        # TODO: Self update
      else
        Rukkit::Util.log.info('Invalid command.')
      end
    end
  end
end

Rukkit::Core.init
Rukkit::Core
