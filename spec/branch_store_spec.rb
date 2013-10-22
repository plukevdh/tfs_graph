require 'spec_helper'
require 'branch/branch_store'

# Integration spec, hits TFS (stores with VCR)
describe BranchStore do
  context "tfs requests", :vcr => { cassette_name: "branches" } do
    context "can fetch and normalize branch data" do
      When(:results) { BranchStore.fetch("RJR") }
      Then { results.count.should eq 100 }
      And { results.first[:name].should eq("RJRLibraries") }
    end

    context "can select branches" do
      When(:results) { BranchStore.fetch_by_branch("RJR", "Camel") }
      Then { results.count.should eq 28 }
      And { results.all? {|b| b[:root] == "Camel" }.should be_true }
    end
  end
end