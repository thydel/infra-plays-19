. := $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included))

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

self := $(lastword $(filter-out header.mk, $(MAKEFILE_LIST)))
$(self):;
