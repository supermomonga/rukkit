# encoding: utf-8

require 'java'
import 'org.bukkit.Bukkit'

->{
  repo = Rukkit::Util.plugin_repository
  repo_dir = Rukkit::Util.rukkit_dir + 'repository'

  if File.exists? repo_dir
    command = "cd #{repo_dir}; git pull --rebase"
    Rukkit::Util.logger.info "----> Pull"
    Rukkit::Util.logger.info "------> #{command}"
  else
    command = "git clone #{repo} #{repo_dir}"
    Rukkit::Util.logger.info "----> Cloning repository"
    Rukkit::Util.logger.info "------> #{command}"
  end
  system command

}.()
