package com.supermomonga.rukkit;

import com.google.common.base.Function;
import com.google.common.base.Throwables;
import com.google.common.collect.ImmutableSet;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
import org.bukkit.Server;
import org.bukkit.configuration.Configuration;
import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.server.PluginDisableEvent;
import org.bukkit.event.server.PluginEnableEvent;
import org.bukkit.plugin.java.JavaPlugin;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.transform;

public class JRubyPlugin extends JavaPlugin {
  /** A {@link Listener} implementation class object */
  private static final Class<Listener> eventHandlerClass;

  /** Recognized all Rukkit's events */
  private static final ImmutableSet<RukkitEvent> allEvents;

  static {
    try {
      // to suppress memory amount
      ClassPool.doPruning = true;

      ClassPool cp = ClassPool.getDefault();
      cp.insertClassPath(new ClassClassPath(JRubyPlugin.class));
      CtClass clazz = cp.makeClass(JRubyPlugin.class.getName() + "$DynamicEventHandler");

      // setup class template
      clazz.setModifiers(Modifier.PRIVATE);
      clazz.addInterface(cp.get(Listener.class.getName()));
      {
        CtField field = new CtField(cp.get(JRubyPlugin.class.getName()), "that", clazz);

        field.setModifiers(Modifier.PRIVATE | Modifier.FINAL);

        clazz.addField(field);
      }
      {
        CtConstructor ctor = new CtConstructor(new CtClass[]{cp.get(JRubyPlugin.class.getName())}, clazz);

        ctor.setBody("this.that = $1;");

        clazz.addConstructor(ctor);
      }

      allEvents = ImmutableSet.copyOf(listEvents());
      for(RukkitEvent event : filter(allEvents, JRubyPlugin::ableToAutoHandle)) {
        CtMethod method = new CtMethod(CtClass.voidType, "on" + event.getJavaEventName(), new CtClass[0], clazz);

        // set annotation
        {
          ConstPool constPool = clazz.getClassFile().getConstPool();
          AnnotationsAttribute attr = new AnnotationsAttribute(constPool, AnnotationsAttribute.visibleTag);

          attr.addAnnotation(new Annotation(EventHandler.class.getName(), constPool));

          method.getMethodInfo().addAttribute(attr);
        }
        method.setModifiers(Modifier.PUBLIC | Modifier.FINAL);
        method.addParameter(cp.get(event.getEventClass().getName()));
        // XXX: work around, failed to resolve overloading if body is "fireEvent(\"on_%s\", $1);"
        method.setBody(String.format("that.fireEvent(\"on_%s\", new Object[]{$1});", event.getRubyEventName()));

        clazz.addMethod(method);
      }

      // construct class object in memory
      @SuppressWarnings("unchecked")
      Class<Listener> madeClass = clazz.toClass(JRubyPlugin.class.getClassLoader(), JRubyPlugin.class.getProtectionDomain());
      eventHandlerClass = madeClass;
    }
    catch(Exception e) {
      throw new ExceptionInInitializerError(e);
    }
  }

  private static boolean ableToAutoHandle(RukkitEvent event) {
    if("PluginEnable".equals(event.getJavaEventName())) {
      return false;
    }
    if("PluginDisable".equals(event.getJavaEventName())) {
      return false;
    }
    return true;
  }

  /**
   * Returns all Rukkit's events.
   *
   * @return The Rukkit's events
   */
  private static Iterable<RukkitEvent> listEvents() {
    JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
    if(compiler == null) {
      throw new IllegalStateException();
    }

    JavaFileManager fileManager = compiler.getStandardFileManager(null, null, null);
    try {
      Set<RukkitEvent> events = new LinkedHashSet<>();

      Pattern pattern = Pattern.compile("\\((?<relpath>org/bukkit/event/(?:[^/]+/)*[^/]+?Event\\.class)\\)");
      Set<JavaFileObject.Kind> kinds = new HashSet<JavaFileObject.Kind>();
      {
        kinds.add(JavaFileObject.Kind.CLASS);
      }
      for(JavaFileObject file : fileManager.list(StandardLocation.CLASS_PATH, "org.bukkit.event", kinds, true)) {
        Matcher matcher = pattern.matcher(file.getName());

        if(matcher.find()) {
          String relpath = matcher.group("relpath");
          String canonName = relpath.replaceFirst("\\.class$", "").replace('/', '.');
          try {
            Class<?> eventClass = Class.forName(canonName);

            if(eventClass.getAnnotation(Deprecated.class) == null) {
              if(!eventClass.isInterface() && (eventClass.getModifiers() & java.lang.reflect.Modifier.ABSTRACT) != java.lang.reflect.Modifier.ABSTRACT) {
                events.add(new RukkitEvent(eventClass));
              }
            }
          }
          catch(ClassNotFoundException e) {
            throw new AssertionError(String.format("Cannot convert `%s' extracted from `%s' to correct class name.", relpath, file.getName()), e);
          }
        }
      }

      return events;
    }
    catch(IOException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * Creates an implementation for {@link Listener}.
   *
   * @return The implementation for {@link Listener}
   * @throws RuntimeException When there are any exceptions or errors
   */
  private static Listener newDynamicEventHandler(JRubyPlugin that) {
    try {
      Constructor<?> ctor = eventHandlerClass.getConstructor(JRubyPlugin.class);
      return (Listener)ctor.newInstance(that);
    }
    catch(NoSuchMethodException | IllegalAccessException | InstantiationException e) {
      throw new AssertionError(e);
    }
    catch(InvocationTargetException e) {
      throw new RuntimeException(e.getCause());
    }
  }

  private final AtomicReference<RubyEnvironment> jruby = new AtomicReference<>();

  private final AtomicReference<FileConfiguration> config = new AtomicReference<>();

  public void reloadPlugins() {
    reloadPlugins(false);
  }

  public void updatePlugins() {
    reloadPlugins(true);
  }

  private void reloadPlugins(final boolean refreshDependencies) {
    getLogger().info("--> Initialize a ruby environment.");

    final ExecutorService service= Executors.newCachedThreadPool();
    final Callable<Boolean> initializer = () -> {
      try {
        final RubyEnvironment newEnv = new RubyEnvironment(this);

        newEnv.initialize();

        newEnv.loadCoreScripts();

        if(refreshDependencies) {
          newEnv.callMethod(
            newEnv.getCoreModule(),
            "clone_or_update_repository",
            newEnv.getRepositoryDir().toString(),
            getConfig().getString("rukkit.repository")
          );
        }

        final Server server = Bukkit.getServer();
        synchronized(server) {
          server.resetRecipes();

          // calling reloadConfig() in this context, it depends on #getConfig() impl.
          reloadConfig();
          config.set(super.getConfig());

          newEnv.loadUserScripts();

          newEnv.loadUserPlugins();

          // switch
          final RubyEnvironment oldEnv = jruby.get();
          if(oldEnv != null) {
            fireEvent(oldEnv, "on_plugin_disable", new PluginDisableEvent(this));
            oldEnv.terminate();
          }
          if(jruby.compareAndSet(oldEnv, newEnv)) {
            fireEvent(newEnv, "on_plugin_enable", new PluginEnableEvent(this));
            getLogger().info("--> Updated.");
            return true;
          }
          else {
            getLogger().warning("--> Other update task has done, skipped.");
            return false;
          }
        }
      }
      catch(Exception e)
      {
        getLogger().warning("--> Failed to update rukkit.");
        getLogger().warning(Throwables.getStackTraceAsString(e));
        return false;
      }
      finally {
        service.shutdownNow();
      }
    };

    // first time
    if(jruby.get() == null) {
      try {
        // sync
        getLogger().info("--> Start to update rukkit plugins.");
        final boolean updated = service.submit(initializer).get();
        // this is at first, will get a ton of errors if failed to load plugins.
        if(!updated) {
          throw new RuntimeException("Couldnot initialize ruby environment.");
        }
      }
      catch(InterruptedException e)
      {
        getLogger().info("--> Canceled.");
      }
      catch(ExecutionException e)
      {
        // initialzier throws no exception
        throw new AssertionError(e);
      }
    }
    else {
      // async
      getLogger().info("--> Schedule to update rukkit plugins.");
      Bukkit.broadcastMessage("[Rukkit] Schedule to update.");

      service.execute(() -> {
        final boolean updated;
        try {
          updated = initializer.call();
        }
        catch(Exception e) {
          // initialzier throws no exception
          throw new AssertionError(e);
        }

        if(updated) {
          Bukkit.getScheduler().scheduleSyncDelayedTask(this, () -> {
            Bukkit.broadcastMessage("[Rukkit] Updated");
          }, 0);
        }
        else {
          Bukkit.getScheduler().scheduleSyncDelayedTask(this, () -> {
            Bukkit.broadcastMessage("[Rukkit] Skipped");
          }, 0);
        }
      });
    }
    service.shutdown();
  }

  // XXX: work around, javassist cannot handle enclosing private method
  Object fireEvent(String method, Object...args) {
    final RubyEnvironment env = jruby.get();
    checkState(env != null);

    return fireEvent(env, method, args);
  }

  private Object fireEvent(RubyEnvironment env, String method, Object...args) {
    List<Object> rubyArgs = new ArrayList<>(1 + args.length);

    rubyArgs.add(method);
    for(Object arg : args) {
      rubyArgs.add(arg);
    }

    return env.callMethod(env.getCoreModule(), "fire_event", rubyArgs.toArray());
  }

  private void applyEventHandler() {
    getServer().getPluginManager().registerEvents(newDynamicEventHandler(this), this);
  }

  @Override
  public void onEnable() {
    Configuration config = getConfig();

    updatePlugins();

    getLogger().info("--> Save all event names to file.");
    try {
      if(config.contains("rukkit.event_filename")) {
        writeEvents(new File(config.getString("rukkit.event_filename")).toPath(), allEvents);
        getLogger().info("--> Saved.");
      }
      else {
        getLogger().info("--> No filename, skipped.");
      }
    }
    catch(Exception e) {
      getLogger().warning("--> Failed to save event names to file:");
      getLogger().warning(Throwables.getStackTraceAsString(e));
    }

    getLogger().info("Rukkit enabled!");

    applyEventHandler();
  }

  @Override
  public void onDisable() {
    fireEvent("on_plugin_disable", new PluginDisableEvent(this));
    getLogger().info("Rukkit disabled!");
  }

  @Override
  public boolean onCommand(org.bukkit.command.CommandSender sender, org.bukkit.command.Command command, String label, String[] args) {
    fireEvent("on_command", sender, command, label, args);
    return true;
  }

  @Override
  public List<String> onTabComplete(org.bukkit.command.CommandSender sender, org.bukkit.command.Command command, String alias, String[] args) {
    Object ret = fireEvent("on_tab_complete", sender, command, alias, args);
    if(ret instanceof List) {
      @SuppressWarnings("unchecked")
      List<String> raw = (List<String>)ret;
      List<String> result = Collections.checkedList(new ArrayList<>(raw.size()), String.class);
      result.addAll(raw);
      return result;
    }
    else {
      return Collections.emptyList();
    }
  }

  @Override
  public FileConfiguration getConfig() {
    if(config.get() == null) {
      config.compareAndSet(null, super.getConfig());
    }

    final FileConfiguration ret = config.get();
    checkState(ret != null);

    return ret;
  }

  private void writeEvents(Path path, Iterable<? extends RukkitEvent> events) throws IOException {
    checkNotNull(path);
    checkNotNull(events);
    checkArgument(!path.toFile().exists() || path.toFile().canWrite());

    Iterable<String> lines = transform(events, new Function<RukkitEvent, String>(){
      @Override
      public String apply(RukkitEvent input) {
        return input.getRubyEventName();
      }
    });
    Files.write(path, lines, Charset.forName("UTF-8"), StandardOpenOption.WRITE, StandardOpenOption.CREATE);
  }
}
