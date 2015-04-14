require "androidgen/version"

require 'erb'

module Androidgen
    module ErbTmpl
        def erb( src, dest, project )
            #puts "render #{src} to #{dest}"
            renderer = ERB.new( File.read(src) )
            FileUtils.mkdir_p File.dirname(dest) if !File.exist? File.dirname(dest)
            File.open( dest, "w" ) do |wr|
                #puts renderer.result(project.get_binding) 
                wr.write( renderer.result(project.get_binding) )
            end
        end
    end

    class SimpleTmpl 
        include ErbTmpl

        def initialize(tmpl_path, dest_path=nil)
            @tmpl_path = tmpl_path
            @dest_path = dest_path
            if @dest_path.nil?
                @dest_path = tmpl_path
            end
        end

        def generate(tmpl_base_path, generate_base_path, project)
            erb( tmpl_base_path + "/" + @tmpl_path, generate_base_path + "/" + @dest_path, project )
        end
    end

    class JavaTmpl
        include ErbTmpl

        def initialize(base_path, tmpl_path)
            @base_path = base_path
            @tmpl_path = tmpl_path
        end

        def generate(tmpl_base_path, generate_base_path, project)
            puts @tmpl_path
            erb( tmpl_base_path + "/" + @tmpl_path, 
                generate_base_path + "/" + @base_path + "/" + project.package_name.gsub(/\./, "/" ) + "/" + File.basename(@tmpl_path),
                project )
        end
    end

    class Project
        attr_accessor :package_name, :target_sdk_version, :minimal_sdk_version, :androidannotations_version, :codemodel_version, :android_maven_plugin_version, :maven_compiler_plugin_version, :android_version, :android_sdk_groupid, :androidannotations_groupid

        #todo:support-v4.version

        def initialize
            @android_sdk_groupid = "android"
            @android_version = "5.0.1_r2"
            @target_sdk_version=21
            @minimal_sdk_version=8
            @androidannotations_groupid="org.androidannotations"
            @androidannotations_version="3.2"
            @android_maven_plugin_version="3.8.2"
            @maven_compiler_plugin_version="3.3"
            @codemodel_version="2.4.1"
        end

        def androidannotations_repo_path
            @androidannotations_groupid.gsub( /\./, "/" )
        end

        def activity_name
            "MainActivity"
        end

        def artifact_id
            package_name.split('.').last
        end

        def app_name
            package_name.split('.').last
        end

        def project_name
            package_name.split('.').last
        end

        def get_binding
            binding
        end
    end

    class Generator
        @@template_files = []

        def self.simple_template(*args)
            args.each do |file_path|
                @@template_files << SimpleTmpl.new(file_path)
            end
        end

        def self.java_template(base_path, *args)
            #if args.is_a? String
                #args = [ args ]
            #end

            args.each do |file_path|
                @@template_files << JavaTmpl.new(base_path, file_path)
            end
        end

        def self.rename_template(hash_of_files)
            hash_of_files.each_pair do |src,dest| 
                @@template_files << SimpleTmpl.new(src,dest)
            end
        end

        rename_template(   "project"=>".project", 
                        "factorypath"=>".factorypath",
                        "settings/org.eclipse.jdt.core.prefs"=>".settings/org.eclipse.jdt.core.prefs", 
                        "settings/org.eclipse.jdt.apt.core.prefs"=>".settings/org.eclipse.jdt.apt.core.prefs" 
                       )

        java_template "src/main/java", "src/main/java/info/thinkmore/yass/MainActivity.java"

        simple_template(
            "project.properties",
            "project.properties",
            "src/test/java/REMOVE.ME",
            "pom.xml",
            "AndroidManifest.xml",
            "res/layout/activity_main.xml",
            "res/layout/fragment_sample.xml",
            "res/drawable-xhdpi/ic_action_search.png",
            "res/drawable-xhdpi/ic_launcher.png",
            "res/drawable-ldpi/ic_launcher.png",
            "res/drawable-hdpi/ic_action_search.png",
            "res/drawable-hdpi/ic_launcher.png",
            "res/values/strings.xml",
            "res/values/styles.xml",
            "res/values/arrays.xml",
            "res/drawable-mdpi/ic_action_search.png",
            "res/drawable-mdpi/ic_launcher.png",
            "res/menu/activity_main.xml",
            )

        def initialize(tmpl_base_path=nil)
            if tmpl_base_path.nil?
                @tmpl_base_path = File.dirname(__FILE__) + "/../res/android-mvn-tmpl"
            else
                @tmpl_base_path = tmpl_base_path
            end
        end

        def generate(path,project)
            # check project path
            raise "Path #{path} doesn't exist!" unless File.exist? path

            @@template_files.each do |tmpl|
                tmpl.generate( @tmpl_base_path, path, project )
            end
        end
    end
end
