(defproject rukkit "1.0.0-SNAPSHOT"
  :description "Awesome super benri cool plugin"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.spigotmc/spigot-api "1.10-R0.1-SNAPSHOT"]
                 [org.spigotmc/spigot "1.10"]
                 [org.jruby/jruby-complete "9.1.2.0"]
                 [org.javassist/javassist "3.18.2-GA"]
                 [redis.clients/jedis "2.6.0"]
                 [com.google.guava/guava "18.0"]]
  :license {:name "MIT License"
            :url "http://opensource.org/licenses/MIT"}
  :repositories {"org.bukkit"
                 "http://repo.bukkit.org/content/groups/public/"
                 "spigot-repo"
                 "https://hub.spigotmc.org/nexus/content/repositories/snapshots/"
                 "localrepo"
                 "file://localrepo"}
  :javac-target "1.8"
  :javac-source "1.8"
  :javac-options ["-d" "classes/" "-Xlint:all"]
  :java-source-paths ["javasrc"])
