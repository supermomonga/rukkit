package com.supermomonga.Rukkit;

import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
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
  private HashMap<String, Object> eventHandlers = new HashMap<String, Object>();
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

  private boolean isRubyMethodExists(Object eventHandler, String method) {
    if (jruby.callMethod(eventHandler, "respond_to?", method).equals(rubyTrue)) {
      return true;
    } else {
      getLogger().info("method doesn't exists: " + method);
      return false;
    }
  }

  private void callJRubyMethodIfExists(String method, Object arg1) {
    for (Object eventHandler : eventHandlers.values())
      if (isRubyMethodExists(eventHandler, method))
        jruby.callMethod(eventHandler, method, arg1);
  }

  private void callJRubyMethodIfExists(String method, Object arg1, Object arg2) {
    for (Object eventHandler : eventHandlers.values())
      if (isRubyMethodExists(eventHandler, method))
        jruby.callMethod(eventHandler, method, arg1, arg2);
  }

  private void callJRubyMethodIfExists(String method, Object arg1, Object arg2, Object arg3) {
    for (Object eventHandler : eventHandlers.values())
      if (isRubyMethodExists(eventHandler, method))
        jruby.callMethod(eventHandler, method, arg1, arg2, arg3);
  }

  private void callJRubyMethodIfExists(String method, Object arg1, Object arg2, Object arg3, Object arg4) {
    for (Object eventHandler : eventHandlers.values())
      if (isRubyMethodExists(eventHandler, method))
        jruby.callMethod(eventHandler, method, arg1, arg2, arg3, arg4);
  }


  private void loadConfig() {
    config = getConfig();
  }

  private Object loadJRubyScript(InputStream io, String path) {
    try {
      return jruby.runScriptlet(io, path);
    } finally {
      try {
        if (io != null) {
          io.close();
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  private void loadRukkitPlugin(String pluginDir, String plugin) {
    getLogger().info("Loading plugin: [" + plugin + "]");
    String pluginPath = pluginDir + plugin + ".rb";
    try {
      URL url = new URL(pluginPath);
      Object eventHandler = loadJRubyScript(
          url.openStream(),
          URLDecoder.decode(url.getPath().toString(), "UTF-8")
          );
      eventHandlers.put(plugin, eventHandler);
      getLogger().info("Plugin loaded: [" + plugin + "]");
    } catch (Exception e) {
      getLogger().info("Failed to load plugin: [" + plugin + "]");
      e.printStackTrace();
    }
  }

  private void loadRukkitPlugins(String pluginDir, List<String> plugins) {
    for (String plugin : plugins) {
      loadRukkitPlugin(pluginDir, plugin);
    }
  }

  private void loadCorePlugins() {
    List<String> plugins = new ArrayList<String>();
    plugins.add("util");
    /* plugins.add("web"); */

    // TODO: Builtin plugins should not be stored in user-defined-plugin dir,
    //       so I want to put them into jar.
    loadRukkitPlugins(
        config.getString("rukkit.plugin_dir"),
        plugins
        );
  }

  private void loadUserPlugins() {
    loadRukkitPlugins(
        config.getString("rukkit.plugin_dir"),
        config.getStringList("rukkit.plugins")
        );
  }

  private void applyEventHandler() {
    getServer().getPluginManager().registerEvents(this, this);
  }

  @Override
  public void onEnable() {
    initializeJRuby();
    loadConfig();

    loadCorePlugins();
    loadUserPlugins();
    getLogger().info("Rukkit enabled!");

    applyEventHandler();
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

  // EventHandler mappings
  // TODO: I want to generate all event handler mappings automatically,
  //       but it must be painful to parse JavaDoc...
  //       @ujm says that "use jruby repl and ruby reflection to list them up."
  @EventHandler
  public void onPlayerJoin(org.bukkit.event.player.PlayerJoinEvent event) {
    getLogger().info("eh: on_player_join");
    callJRubyMethodIfExists("on_player_join", event);
  }
  @EventHandler
  public void onPlayerQuit(org.bukkit.event.player.PlayerQuitEvent event) {
    getLogger().info("eh: on_player_quit");
    callJRubyMethodIfExists("on_player_quit", event);
  }

}
