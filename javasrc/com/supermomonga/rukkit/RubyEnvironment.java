package com.supermomonga.rukkit;

import com.google.common.base.Function;
import com.google.common.base.Throwables;
import com.google.common.collect.ImmutableSet;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.BinaryOperator;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javassist.ClassClassPath;
import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtConstructor;
import javassist.CtField;
import javassist.CtMethod;
import javassist.Modifier;
import javassist.bytecode.AnnotationsAttribute;
import javassist.bytecode.ConstPool;
import javassist.bytecode.annotation.Annotation;

import javax.tools.JavaCompiler;
import javax.tools.JavaFileManager;
import javax.tools.JavaFileObject;
import javax.tools.StandardLocation;
import javax.tools.ToolProvider;

import org.bukkit.Bukkit;
import org.bukkit.configuration.Configuration;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.plugin.java.JavaPlugin;
import org.jruby.embed.ScriptingContainer;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Iterables.transform;

class RubyEnvironment {
  private final JavaPlugin plugin;

  private ScriptingContainer jruby;

  private Object rukkitCore;

  private Object rukkitUtil;

  public RubyEnvironment(JavaPlugin plugin) {
    checkNotNull(plugin);

    this.plugin = plugin;
  }

  public void initialize() {
    jruby = newRubyEnv();
  }

  public void terminate() {
    if(jruby != null) {
      jruby.terminate();
    }
  }

  public void loadCoreScripts() {
    rukkitUtil = loadRukkitBundledScript("util");
    rukkitCore = loadRukkitBundledScript("core");
  }

  public void loadUserScripts() {
    Path dirpath = getRepositoryDir().resolve("scripts");
    @SuppressWarnings("unchecked")
    List<String> scripts = (List<String>)plugin.getConfig().getList("rukkit.scripts", Collections.emptyList());

    for(String script : scripts) {
      Path scriptPath = dirpath.resolve(script + ".rb");
      plugin.getLogger().info("----> Load " + script);
      if(scriptPath.toFile().canRead()) {
        plugin.getLogger().info("----> Load " + scriptPath);
        try {
          evalRuby(readAll(scriptPath));
        }
        catch(IOException e) {
          plugin.getLogger().severe(Throwables.getStackTraceAsString(e));
        }
        catch(Exception e) {
          plugin.getLogger().warning(Throwables.getStackTraceAsString(e));
        }
      }
      else {
        plugin.getLogger().info("----> Cannot find " + scriptPath + ", skipped.");
      }
    }
  }

  public void loadUserPlugins() {
    Path dirpath = getRepositoryDir();

    callMethod(getCoreModule(), "load_plugins", dirpath.toString());
    /* Path dirpath = getRepositoryDir().resolve("plugins"); */
    /* @SuppressWarnings("unchecked") */
    /* List<String> pluginNames = (List<String>)plugin.getConfig().getList("rukkit.plugins", Collections.emptyList()); */
    /*  */
    /* for(String pluginName : pluginNames) { */
    /*   Path pluginPath = dirPath.resolve(pluginName + ".rb"); */
    /*   plugin.getLogger().info("----> Load " + pluginName); */
    /*   if(pluginPath.toFile().canRead()) { */
    /*     plugin.getLogger().info("----> Load " + pluginPath); */
    /*     try { */
    /*       evalRuby(readAll(pluginPath)); */
    /*     } */
    /*     catch(IOException e) { */
    /*       plugin.getLogger().severe(Throwables.getStackTraceAsString(e)); */
    /*     } */
    /*     catch(Exception e) { */
    /*       plugin.getLogger().warning(Throwables.getStackTraceAsString(e)); */
    /*     } */
    /*   } */
    /*   else { */
    /*     plugin.getLogger().info("----> Cannot find " + pluginPath + ", skipped."); */
    /*   } */
    /* } */
  }

  public Object callMethod(Object rubyInstance, String methodName, Object... args) {
    return jruby.callMethod(rubyInstance, methodName, args);
  }

  public Object getCoreModule() {
    return rukkitCore;
  }

  Path getRukkitDir() {
    Path jarpath = Paths.get(getClass().getProtectionDomain().getCodeSource().getLocation().getPath());
    plugin.getLogger().config("jarpath=" + jarpath);

    return jarpath.resolveSibling("rukkit");
  }

  Path getRepositoryDir() {
    return getRukkitDir().resolve("repository");
  }

  private ScriptingContainer newRubyEnv() {
    ScriptingContainer container = new ScriptingContainer();

    container.setClassLoader(getClass().getClassLoader());
    container.setCompatVersion(org.jruby.CompatVersion.RUBY2_0);

    return container;
  }

  private Object evalRuby(String script) {
    return jruby.runScriptlet(script);
  }

  private Object loadRukkitBundledScript(String script) {
    plugin.getLogger().info("----> " + script);

    try(InputStream in = openResource("scripts/" + script + ".rb")) {
      Object obj = evalRuby(readAll(in));
      plugin.getLogger().info("----> done.");
      return obj;
    } catch (Exception e) {
      plugin.getLogger().info("----> failed.");
      plugin.getLogger().warning(Throwables.getStackTraceAsString(e));
      return evalRuby("nil");
    }
  }

  private String readAll(InputStream in) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(in));

    return reader.lines().collect(Collectors.joining("\n"));
  }

  private String readAll(Path path) throws IOException {
    try(InputStream in = Files.newInputStream(path)) {
      return readAll(in);
    }
  }

  private InputStream openResource(String resourceName) throws IOException {
    InputStream resource = getClass().getClassLoader().getResourceAsStream(resourceName);

    if(resource == null) {
      throw new IOException("No such resource `" + resourceName + "'.");
    }

    return resource;
  }
}
