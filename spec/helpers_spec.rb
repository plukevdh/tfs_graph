require 'spec_helper'
require 'tfs_graph/helpers'

class DemoClass; include TFSGraph::Helpers; end

describe TFSGraph::Helpers do
  Given(:demo) { DemoClass.new }
  Given(:archived_path) { "$>RJR>_Branches>FAQ>RJRLibraries-FAQ" }
  Given(:normal_path) { "$>RJR>Grizzly" }

  context "can parse name of branch" do
    When(:archived_result) { demo.branch_path_to_name(archived_path) }
    Then { archived_result.should eq("RJRLibraries-FAQ") }

    When(:normal_result) { demo.branch_path_to_name(normal_path) }
    Then { normal_result.should eq("Grizzly") }
  end

  context "can parse down base name from a path" do
    When(:archived_result) { demo.branch_base(archived_path) }
    Then { archived_result.should eq("RJRLibraries") }

    When(:normal_result) { demo.branch_base(normal_path) }
    Then { normal_result.should eq("Grizzly") }
  end

  context "can parse base username from tfs" do
    When(:fwd) { demo.base_username("BFGCOM/tmoe") }
    Then { fwd.should eq("tmoe") }

    When(:bck) { demo.base_username("BFGCOM\\tmoe") }
    Then { bck.should eq("tmoe") }
  end

  context "can scrub out letters from changeset version" do
    When(:version_1) { demo.scrub_changeset("C1234") }
    Then { version_1.should eq("1234") }

    When(:version_2) { demo.scrub_changeset("1234") }
    Then { version_2.should eq("1234") }

    context "does nothing if no changeset given" do
      When(:version) { demo.scrub_changeset(nil) }
      Then { version.should_not have_failed }
      And { version.should == nil }
    end
  end
end