#!/usr/bin/make -f

include header.mk 

# Get all ansible facts for our default node set in one json file

tmp/setup:; ansible g_default -om setup -t $@ > /dev/null
setup.json: tmp/setup; cat $</* | jq . > $@

# Get facts by node

jq 'map(to_entries|map((.value // {nil: null}) | keys))' by_nodes-users.json > 1.json

define by_node
  map(.ansible_facts)
| map({ (.ansible_hostname): getpath($1) })
| map(with_entries({ key, value: (if (.value | type == "object") then (.value | keys) else .value // [] end) }))
| add
endef

# Group nodes by fact

define by_fact
  map(.ansible_facts)
| map({ansible_hostname, ($1 | last): getpath($1)})
| group_by(getpath([$1 | last]))
| map({(.[0] | getpath([$1 | last]) | tostring): map(.ansible_hostname)})
| add
endef

# Make CSV from grouped facts

define table_by_fact
["$1", "nodes"],
([ keys | map(length) | sort | (last + 1) * "_", ""]),
(to_entries | .[] | [.key, (.value | join(", "))]) | @csv
endef

# Make CSV from ungrouped facts

define table_by_node
["nodes", "$1"],
(to_entries | .[] | [.key, (.value | join(", "))]) | @csv
endef

# The facts to group

by_facts := kernel lsb-description memtotal_mb

# The facts no to group

by_nodes := interfaces users

# Their paths

kernel := ansible_kernel
lsb-description := ansible_lsb description
memtotal_mb := ansible_memtotal_mb
interfaces := ansible_interfaces
users := ohai_etc passwd

# Make a jq path for a make list

space :=
space +=
comma := ,
path = $(subst $(space),$(comma),[$(strip $(foreach _, $($(strip $1)), "$_"))])

# Invoke jq by_fact

facts := $(by_facts:%=by_facts-%.json)
$(facts): by_facts-%.json : setup.json $(self); jq -s '$(call by_fact, $(call path, $*))' $< > $@
facts: $(facts)
.PHONY: facts

# Invoke jq by_node

nodes := $(by_nodes:%=by_nodes-%.json)
$(nodes): by_nodes-%.json : setup.json $(self); jq -s '$(call by_node, $(call path, $*))' $< > $@
nodes: $(nodes)
.PHONY: nodes

# Invoke jq table_by_fact

fact_tables := $(facts:%.json=%.md)
$(fact_tables): by_facts-%.md : by_facts-%.json $(self); jq -r '$(call table_by_fact, $*)' $< | csvtomd > $@
fact-tables: $(fact_tables)
.PHONY: fact-tables

# Invoke jq table_by_node

node_tables := $(nodes:%.json=%.md)
$(node_tables): by_nodes-%.md : by_nodes-%.json $(self); jq -r '$(call table_by_node, $*)' $< | csvtomd > $@
node-tables: $(node_tables)
.PHONY: node-tables

main: fact-tables node-tables
.PHONY: main

