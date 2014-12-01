package com.supermomonga.rukkit;

import com.google.common.base.CaseFormat;
import com.google.common.base.MoreObjects;
import com.google.common.base.Objects;

import org.bukkit.event.Event;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;

public class RukkitEvent {
  private final Class<?> eventClass;

  private final String javaEventName;

  private final String rubyEventName;

  public RukkitEvent(Class<?> eventClass) {
    checkNotNull(eventClass);
    checkArgument(Event.class.isAssignableFrom(eventClass));

    this.eventClass= eventClass;

    final String sName= eventClass.getSimpleName();
    this.javaEventName= sName.replaceFirst("Event$", "");
    this.rubyEventName= CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, this.javaEventName);
  }

  public Class<?> getEventClass() {
    return this.eventClass;
  }

  public String getJavaEventName() {
    return this.javaEventName;
  }

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
