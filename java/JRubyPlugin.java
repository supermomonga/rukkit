package com.supermomonga.Rukkit;

import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
import org.bukkit.configuration.file.FileConfiguration;
import org.jruby.embed.ScriptingContainer;

public class JRubyPlugin extends JavaPlugin implements Listener {
  private ScriptingContainer jruby;
  private Object eh;
  private Object rubyTrue, rubyFalse, rubyNil;
  private FileConfiguration config;

  private void initializeJRuby() {
    jruby = new ScriptingContainer();
    jruby.setClassLoader(getClass().getClassLoader());
    jruby.setCompatVersion(org.jruby.CompatVersion.RUBY2_0);

    // Because of no compatibility with Java's one
    rubyTrue = jruby.runScriptlet("true");
    rubyFalse = jruby.runScriptlet("false");
    rubyNil = jruby.runScriptlet("nil");
  }

  private void loadConfig() {
    config = getConfig();
  }

  @Override
  public void onEnable() {
    initializeJRuby();
    loadConfig();
    getLogger().info("Rukkit enabled!");
  }

  @Override
  public void onDisable() {
    getLogger().info("Rukkit disabled!");
  }

  @Override
  public boolean onCommand( org.bukkit.command.CommandSender sender, org.bukkit.command.Command command, String label, String[] args ) {
    getLogger().info("Command passed!");
    return true;
  }

}
