package com.supermomonga.rukkit;

import com.google.common.base.CaseFormat;
import com.google.common.base.MoreObjects;
import com.google.common.base.Objects;

import org.bukkit.event.Event;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;

/**
 * The Rukkit event.
 *
 * This has Bukkit's event class and Rukkit event name (for Java and Ruby).
 *
 * @author kamichidu
 */
public class RukkitEvent {
  /** Bukkit's event class which is related this Rukkit's event */
  private final Class<?> eventClass;

  /** The name of this event for Java side. */
  private final String javaEventName;

  /** The name of this event for Ruby side. */
  private final String rubyEventName;

  /**
   * Constructs {@link RukkitEvent} object by Bukkit's event class.
   *
   * @param eventClass Bukkit's event class
   * @throws NullPointerException When eventClass is null
   * @throws IllegalArgumentException When eventClass is not a subclass of {@link org.bukkit.event.Event}
   */
  public RukkitEvent(Class<?> eventClass) {
    checkNotNull(eventClass);
    checkArgument(Event.class.isAssignableFrom(eventClass));

    this.eventClass= eventClass;

    final String sName= eventClass.getSimpleName();
    this.javaEventName= sName.replaceFirst("Event$", "");
    this.rubyEventName= CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, this.javaEventName);
  }

  /**
   * Returns a class object which is subclass of {@link org.bukkit.event.Event}.
   * Never returns null value.
   *
   * @return The class object
   */
  public Class<?> getEventClass() {
    return this.eventClass;
  }

  /**
   * Returns an event name for Java.
   * Never returns null value.
   *
   * @return The event name
   */
  public String getJavaEventName() {
    return this.javaEventName;
  }

  /**
   * Returns an event name for Java.
   * Never returns null value.
   *
   * @return The event name
   */
  public String getRubyEventName() {
    return this.rubyEventName;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(this.eventClass);
  }

  @Override
  public String toString() {
    return MoreObjects.toStringHelper(this)
      .add("eventClass", this.eventClass)
      .add("javaEventName", this.javaEventName)
      .add("rubyEventName", this.rubyEventName)
      .toString()
    ;
  }
}
