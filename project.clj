(defproject rukkit "1.0.0-SNAPSHOT"
  :description "Awesome super benri cool plugin"
  :dependencies [[com.supermomonga/craftbukkit "1.7.9-R0.2"]
                 [org.jruby/jruby-complete "1.7.16.1"]]
  :license {:name "MIT License"
            :url "http://opensource.org/licenses/MIT"}
  :repositories [["craftbukkit" "file:craftbukkit"]]
  :javac-options ["-d" "classes/" "-Xlint:deprecation"]
  :java-source-paths ["java"])
