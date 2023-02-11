DIST ?= fc32
VERSION := $(file <version)
REL := $(file <rel)
SHORTCOMMIT := $(shell echo $(COMMIT) | cut -b 1-7)

FEDORA_SOURCES := https://src.fedoraproject.org/rpms/plymouth/raw/f$(subst fc,,$(DIST))/f/sources
SRC_FILE := plymouth-$(VERSION).tar.bz2

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

SRC_URL ?= https://gitlab.freedesktop.org/plymouth/plymouth/-/archive/$(VERSION)/plymouth-$(VERSION).tar.bz2
UNTRUSTED_SUFF := .UNTRUSTED

ifeq ($(FETCH_CMD),)
$(error "You can not run this Makefile without having FETCH_CMD defined")
endif

SHELL := /bin/bash

#keyring := plymouth-trustedkeys.gpg
#keyring-file := $(if $(GNUPGHOME), $(GNUPGHOME)/, $(HOME)/.gnupg/)$(keyring)
#keyring-import := gpg -q --no-auto-check-trustdb --no-default-keyring --import
#
#$(keyring-file): $(wildcard *-key.asc)
#	@rm -f $(keyring-file) && $(keyring-import) --keyring $(keyring) $^
#
#$(SRC_FILE).asc:
#	$(FETCH_CMD) $@ $(DISTFILES_MIRROR).asc
#
#%: %.asc $(keyring-file)
#	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(DISTFILES_MIRROR)
#	@gpgv --keyring $(keyring) $< $@$(UNTRUSTED_SUFF) 2>/dev/null || \
#		{ echo "Wrong signature on $@$(UNTRUSTED_SUFF)!"; exit 1; }
#	@mv $@$(UNTRUSTED_SUFF) $@

%: %.sha512
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(SRC_URL)
	@sha512sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

.PHONY: get-sources
get-sources: $(SRC_FILE)

.PHONY: verify-sources
verify-sources:
	@true

.PHONY: clean
clean:
	rm -rf debian/changelog.*
	rm -rf pkgs

# This target is generating content locally from upstream project
# 'sources' file. Sanitization is done but it is encouraged to perform
# update of component in non-sensitive environnements to prevent
# any possible local destructions due to shell rendering
.PHONY: update-sources
update-sources:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/generate-hashes-from-sources $(FEDORA_SOURCES)
