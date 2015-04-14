require "androidgen/version"

require 'erb'

module Androidgen
    module ErbTmpl
        def erb( src, dest, project )
            puts "render #{src} to #{dest}"
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

    class Project
        attr_accessor :package_name, :activity_name, :target

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

        def self.rename_template(src,dest)
            @@template_files << SimpleTmpl.new(src,dest)
        end

        rename_template "project",".project"

        simple_template(
            "project.properties",
            "settings/org.eclipse.jdt.core.prefs",
            "settings/org.eclipse.jdt.apt.core.prefs",
            "project.properties",
            "src/test/java/REMOVE.ME",
            "src/main/java/info/thinkmore/yass/MainActivity.java",
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
