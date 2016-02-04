SHELL := /bin/bash

# Dependency Versions
VERSION?=4.7
RELEASEVER?=1

# Bash data
SCRIPTPATH=$(shell pwd -P)
CORES=$(shell grep -c ^processor /proc/cpuinfo)
RELEASE=$(shell lsb_release --codename | cut -f2)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)
micro=$(shell echo $(VERSION) | cut -d. -f3)

build: clean libtasn

clean:
	rm -rf /tmp/libtasn1-$(VERSION).tar.xz
	rm -rf /tmp/libtasn1-$(VERSION)

libtasn:
	cd /tmp && \
	wget https://ftp.gnu.org/gnu/libtasn1/libtasn1-$(VERSION).tar.gz && \
	tar -xf libtasn1-$(VERSION).tar.gz && \
	cd libtasn1-$(VERSION) && \
	./configure \
		--prefix=/usr \
		--mandir=/usr/share/man/libtasn1-$(VERSION) \
		--infodir=/usr/share/info/libtasn1-$(VERSION) \
	    --docdir=/usr/share/doc/libtasn1-$(VERSION) && \
	make -j$(CORES) && \
	make install

package:
	cd /tmp/libtasn1-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$(RELEASEVER)"-"$(RELEASE)" \
	    -pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
	    -pkgname "libtasn1" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "libtasn1" \
	    -requires "" \
	    -conflicts "" \
	    -pakdir /tmp \
	    -y