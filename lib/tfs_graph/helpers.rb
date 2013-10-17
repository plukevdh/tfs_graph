module TFSGraph
  module Helpers
    def branch_base(path)
      branch_path_to_name(path).split('-').first
    end

    # handles OData paths: $>RJR>Project>Path
    def branch_path_to_name(path)
      path_parts(path).last
    end

    # handles TFS server paths: $/RJR/Project/Path
    def server_path_to_odata_path(path)
      path.gsub "/", ">"
    end

    def branch_project(path)
      path_parts(path)[1]
    end

    def base_username(name)
      name.split(/\/|\\/).last
    end

    def scrub_changeset(version)
      version.gsub /\D/, "" unless version.nil?
    end

    private
    def path_parts(path)
      path.split(">")
    end

    def server_path_parts(path)
      path.split("/")
    end
  end
end