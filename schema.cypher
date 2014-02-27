CREATE CONSTRAINT ON (p:project) ASSERT p.name IS UNIQUE;
CREATE CONSTRAINT ON (b:branch) ASSERT b.original_path IS UNIQUE;
CREATE CONSTRAINT ON (c:changeset) ASSERT c.id IS UNIQUE;

CREATE INDEX ON :project(name);
CREATE INDEX ON :branch(path);
CREATE INDEX ON :changeset(id);