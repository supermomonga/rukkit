package com.github.supermomonga.Rukkit;

import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
import org.bukkit.configuration.file.FileConfiguration;
import org.jruby.embed.ScriptingContainer;

public class JRubyPlugin extends JavaPlugin implements Listener {
  private ScriptingContainer jruby = new ScriptingContainer();
  private Object eh;
  private Object rubyTrue, rubyFalse, rubyNil;
  private FileConfiguration config;

  private void initializeRubyVariables() {
    rubyTrue = jruby.runScriptlet("true");
    rubyFalse = jruby.runScriptlet("false");
    rubyNil = jruby.runScriptlet("nil");
  }

  private void loadConfig() {
    config = getConfig();
  }

  @Override
  public void onEnable() {
    initializeRubyVariables();
    loadConfig();
    getLogger().info("Rukkit enabled!");
  }

  @Override
  public void onDisable() {
    getLogger().info("Rukkit disabled!");
  }

}
