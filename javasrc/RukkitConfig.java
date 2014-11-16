package com.supermomonga.rukkit;

import java.util.List;
import java.util.ArrayList;
import org.bukkit.configuration.file.FileConfiguration;

public class RukkitConfig {
  private FileConfiguration config = getConfig();

  private String getConfigPath(String key) {
    return "rukkit.plugin_config." + key;
  }

  public String getStringList(String key) {
    List<String> config = config.getStringList(getConfigPath(key));
    if (config == null)
      return new ArrayList<String>();
    else
      return config;
  }

  public String getString(String key) {
    String config = config.getString(getConfigPath(key));
    if (config == null)
      return "";
    else
      return config;
  }

}

