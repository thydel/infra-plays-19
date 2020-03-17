#!/usr/bin/make -f

MAKEFLAGS += -Rr 
MAKEFLAGS += --warn-undefined-variables
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:

.RECIPEPREFIX :=
.RECIPEPREFIX +=

.DEFAULT_GOAL := main

MIN_VERSION := 4.1
VERSION_ERROR :=  make $(MAKE_VERSION) < $(MIN_VERSION)
$(and $(or $(filter $(MIN_VERSION),$(firstword $(sort $(MAKE_VERSION) $(MIN_VERSION)))),$(error $(VERSION_ERROR))),)

self := $(lastword $(MAKEFILE_LIST))
$(self):;

groups := data/oxa/groups.js

tmp/nodes: jsonnet := local g = (import '$(groups)').by_groups;
tmp/nodes: jsonnet += std.setDiff(std.setInter(g.mysql, g.poweredon), g.impact)
tmp/nodes: $(groups) $(self); jsonnet -e "$(jsonnet)" | jq -r '.[] | . + ".admin2"' > $@

RUN ?= dash

main: main := ssh -n {} getent group dev | cut -d: -f4 | tr , '\n' | xargs -i_ echo ssh -n {} -l root adduser _ adm
main: tmp/nodes; @< $< xargs -i echo "$($@)" | $(RUN)
