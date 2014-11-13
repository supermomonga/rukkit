(defproject rukkit "1.0.0-SNAPSHOT"
  :description "Awesome super benri cool plugin"
  :dependencies [[org.bukkit/bukkit "1.7.10-R0.1-SNAPSHOT"]
                 [org.jruby/jruby-complete "1.7.16.1"]]
  :license {:name "MIT License"
            :url "http://opensource.org/licenses/MIT"}
  :repositories {"org.bukkit"
                 "http://repo.bukkit.org/service/local/repositories/snapshots/content/"}
  :javac-options ["-d" "classes/" "-Xlint:deprecation"]
  :java-source-paths ["java"])
