#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/test_helper.rb"

require 'androidgen'

class TestAndroidgen < Test::Unit::TestCase
    include Androidgen

    TMP = File.dirname(__FILE__) + "/../tmp"

    def setup
       FileUtils.rm_rf TMP
       FileUtils.mkdir_p TMP
    end


    def teardown
    end

    def test_basic
        prj = Project.new
        prj.package_name = "com.info.testgen"
        Androidgen.generate_multiple_projects( TMP, prj )
    end
end
