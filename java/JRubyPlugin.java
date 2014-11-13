package com.supermomonga.Rukkit;

import java.util.List;
import java.net.URL;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
import org.bukkit.configuration.file.FileConfiguration;
import org.jruby.embed.ScriptingContainer;

public class JRubyPlugin extends JavaPlugin implements Listener {
  private ScriptingContainer jruby;
  private Object eventHandler;
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

  private Object loadJRubyScript(InputStream io, String path) {
    try {
      return jruby.runScriptlet(io, path);
    } finally {
      try {
        if(io != null) {
          io.close();
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  private void loadBukkitPlugin(String pluginDir, String plugin) {
    getLogger().info("Loading plugin: [" + plugin + "]");
    String pluginPath = pluginDir + plugin + ".rb";
    try {
      URL url = new URL(pluginPath);
      eventHandler = loadJRubyScript(
          url.openStream(),
          URLDecoder.decode(url.getPath().toString(), "UTF-8")
          );
      getLogger().info("Plugin loaded: [" + plugin + "]");
    } catch (Exception e) {
      getLogger().info("Failed to load plugin: [" + plugin + "]");
      e.printStackTrace();
    }
  }

  private void loadRukkitPlugins(String pluginDir, List<String> plugins) {
    for (String plugin : plugins) {
      loadBukkitPlugin(pluginDir, plugin);
    }
  }

  @Override
  public void onEnable() {
    initializeJRuby();
    loadConfig();

    loadRukkitPlugins(config.getString("rukkit.plugin_dir"), config.getStringList("rukkit.plugins"));
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
