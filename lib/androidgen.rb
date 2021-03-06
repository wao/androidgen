require "androidgen/version"

require 'erb'

module Androidgen
    module ErbTmpl
        def erb( src, dest, project )
            #puts "render #{src} to #{dest}"
            FileUtils.mkdir_p File.dirname(dest) if !File.exist? File.dirname(dest)
            File.open( dest, "w" ) do |wr|
                #puts renderer.result(project.get_binding) 
                wr.write( render(src, project) )
            end
        end

        def render(src, project)
            renderer = ERB.new( File.read(src) )
            renderer.result(project.get_binding)
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

        def initialize(base_path, tmpl_path, is_test=false)
            @base_path = base_path
            @tmpl_path = tmpl_path
            @is_test = is_test
        end

        def package_name(project)
            if @is_test
                #puts "istest"
                #puts @tmpl_path
                project.package_name + ".test"
            else
                project.package_name
            end
        end

        def generate(tmpl_base_path, generate_base_path, project)
            erb( tmpl_base_path + "/" + @tmpl_path, 
                generate_base_path + "/" + @base_path + "/" + package_name(project).gsub(/\./, "/" ) + "/" + File.basename(@tmpl_path),
                project )
            #puts ">>>>>"
        end
    end

    class Project
        attr_reader :package_name, :target_sdk_version, :minimal_sdk_version, :androidannotations_version, :codemodel_version, :android_maven_plugin_version, :maven_compiler_plugin_version, :android_version, :android_sdk_groupid, :androidannotations_groupid, :group_id, :artifact_id
        attr_accessor :support_multiple_projects

        #todo:support-v4.version

        def initialize(pname)
            names = pname.split(".")
            @artifact_id = names.pop
            @group_id = names.join(".")
            @package_name =  (names + @artifact_id.split("-")).join(".")

            @android_sdk_groupid = "android"
            @android_version = "5.0.1_r2"
            @target_sdk_version=21
            #@android_version = "4.4.2_r4"
            #@target_sdk_version=19
            #@android_version = "4.3.1_r3"
            #@target_sdk_version=18
            @minimal_sdk_version=8
            @androidannotations_groupid="org.androidannotations"
            @androidannotations_version="3.2"
            @android_maven_plugin_version="3.8.2"
            @maven_compiler_plugin_version="3.3"
            @codemodel_version="2.4.1"
            @support_multiple_projects = false
        end

        def androidannotations_repo_path
            @androidannotations_groupid.gsub( /\./, "/" )
        end

        def activity_name
            "MainActivity"
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

    class BaseGenerator
        def self.template_files
            @template_files ||= []
        end


        def self.simple_template(*args)
            args.each do |file_path|
                template_files << SimpleTmpl.new(file_path)
            end
        end

        def self.java_source_template(base_path, is_test, args)
            args.each do |file_path|
                template_files << JavaTmpl.new(base_path, file_path, is_test)
            end
        end

        def self.java_template(base_path, *args)
            java_source_template(base_path,false,args)
        end

        def self.java_test_template(base_path, *args)
            java_source_template(base_path,true,args)
        end

        def self.rename_template(hash_of_files)
            hash_of_files.each_pair do |src,dest| 
                template_files << SimpleTmpl.new(src,dest)
            end
        end

        def self.tmpl_base_path(value=nil)
            if value.nil?
                @tmpl_base_path 
            else
                @tmpl_base_path = value
            end
        end

        def generate(path,project)
            # check project path
            raise "Path #{path} doesn't exist!" unless File.exist? path

            self.class.template_files.each do |tmpl|
                tmpl.generate( self.class.tmpl_base_path, path, project )
            end
        end
    end

    class AndroidProjectGenerator < BaseGenerator
        rename_template(   "project"=>".project", 
                        "settings/org.eclipse.jdt.core.prefs"=>".settings/org.eclipse.jdt.core.prefs", 
                        "settings/org.eclipse.jdt.apt.core.prefs"=>".settings/org.eclipse.jdt.apt.core.prefs" 
                       )

        java_template "src/main/java", "src/main/java/info/thinkmore/yass/MainActivity.java"
        java_template "src/test/java", "src/test/java/MainActivityTest.java"

        simple_template(
            "proguard.cfg",
            "project.properties",
            "project.properties",
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

        tmpl_base_path File.dirname(__FILE__) + "/../res/android-mvn-tmpl"
    end

    class MavenParentProjectGenerator < BaseGenerator
        tmpl_base_path File.dirname(__FILE__) + "/../res/android-parent-tmpl"

        rename_template( { "settings/org.eclipse.m2e.core.prefs"=>".settings/org.eclipse.m2e.core.prefs",
            "gitignore"=>".gitignore",
            "project"=>".project"
        } )

        simple_template "TWLfile"
    end

    class AndroidTestProjectGenerator < BaseGenerator
        tmpl_base_path File.dirname(__FILE__) + "/../res/android-test-tmpl"
        rename_template( {
            "settings/org.eclipse.m2e.core.prefs"=>".settings/org.eclipse.m2e.core.prefs",
            "settings/org.eclipse.jdt.core.prefs"=>".settings/org.eclipse.jdt.core.prefs",
            "project"=>".project" 
        })

        simple_template(
            "proguard.cfg",
            "project.properties",
            "AndroidManifest.xml",
            "res/layout/main.xml",
            "res/drawable-ldpi/icon.png",
            "res/drawable-hdpi/icon.png",
            "res/values/strings.xml",
            "res/drawable-mdpi/icon.png",
        )

        java_test_template( 
           "src/main/java", 
           "src/main/java/atest/atest/test/AllTests.java",
           "src/main/java/atest/atest/test/MainActivityTest.java"
      )
    end

    def self.generate_project( target_path, project )
        project.support_multiple_projects = false
        FileUtils.mkdir_p target_path if !File.exist? target_path
        Androidgen::Generator.new.generate( target_path, @project )
    end

    def self.generate_multiple_projects( target_path, project )
        project.support_multiple_projects = true 
        FileUtils.mkdir_p target_path if !File.exist? target_path
        MavenParentProjectGenerator.new.generate(target_path,project)

        android_path = target_path + "/" + project.artifact_id
        FileUtils.mkdir_p android_path if !File.exists? android_path
        AndroidProjectGenerator.new.generate(android_path,project)
        
        android_test_path = target_path + "/" + project.artifact_id + "-it"
        FileUtils.mkdir_p android_test_path if !File.exist? android_test_path
        AndroidTestProjectGenerator.new.generate(android_test_path,project)
    end
end
