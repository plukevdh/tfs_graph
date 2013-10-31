# TFSGraph

This is a nice little library to tie together TFS data (using the TFS OData API via ruby_tfs) Related, a super-lightweight faux-graph DB implementation built on top of Redis.

To initially map your TFS data, you can run the GraphPopulator.

```ruby
include TFSGraph

GraphPopulator.populate_all
```

This will scrape and dump all of the TFS data into Redis and build the initial set of relationships. From there, you can traverse the data starting from the projects and digging in deeper. The *Store (ProjectStore/BranchStore) classes can help make the initial queries against this.

```ruby
# Get all the branch objects
projects = ProjectStore.all_cached

# Get all the branches for a project
branches = projects.branches

# Gett all the changesets from the branches
changesets = branches.map do |branch|
  branch.changesets
end

# Get all the changesets that have merged with this changeset
changesets.first.merges

# Or get all the changesets that this one has merged into
changesets.first.merged


# Get all the "master" branches
projects.roots
```

There are plenty more relationships to traverse an each object type (Project/Branch/Changeset) has its own set of properties.

- Project
  - name

- Branch
  - original_path
  - path
  - project
  - name
  - root
  - created
  - type
  - archived

- Changeset
  - comment
  - committer
  - created
  - id
  - branch_path
  - tags
  - parent
  - merge_parent

Changesets are also enumerable. So you can do things like

```ruby
child = changeset.next
child.next # keep `next`ing until StopIteration is raised


# loops also work with this:

loop do
  child = changeset.next
  # do somethign with child

  changeset = child
end
```

This is not a subclass of the enumerator class, so it won't behave the same as other enumerable classes.


## Requirements

You will need Redis installed. You can configure like so:

```ruby
TFSGraph.config do |c|
  c.tfs = {
    username: "me",
    password: "lame",
    endpoint: "https://my-odata-endpoint/Collection"
  },
  c.redis = "localhost:6379/Namespace"
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'tfs_graph'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tfs_graph


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
