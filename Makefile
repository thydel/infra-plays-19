MAKEFLAGS += -Rr
SHELL != which bash
.DEFAULT_GOAL := main
$(MAKEFILE_LIST):;

priv := clone data-ips inventories password-store
priv.dirs := $(priv:%=ext/%)
$(priv.dirs):; get-priv-repos.yml -e dir=$$(pwd)
priv: $(priv.dirs) $(priv)

ext/clone/.done: ext/clone; make -C $(@D) --no-print-directory
clone: ext/clone/.done

ext/inventories/.done: ext/inventories; make -C $(@D) --no-print-directory; rsync -av $</inventory .
inventories: ext/inventories/.done

ips.src := git@github.com:thydel/infra-ips.git
ips.name := ips
ips.version = master

pub := ips

git.config.items := user.email user.signingkey format.pretty

git.config = git -C $1 config --add $2 "$$(git config --get --local $2)";
git.config.all = $(foreach _, $2, $(call git.config, $1, $_))

git.clone  = git -C $(@D) clone $($*.src) -b $($*.version) $($*.name);
git.clone += $(strip $(call git.config.all, $@, $(git.config.items)))

ext/%:; $(git.clone)

pub: $(pub:%=ext/%) $(pub)

ext/ips/oxa: ext/data-ips; proot -w $(@D) ln -s ../$(<F)/$(@F)
ext/ips/.done: ext/ips ext/ips/oxa; make -C $(@D)
ips: ext/ips/.done

main: priv pub

.PHONY: top priv $(priv) pub $(pub) main
