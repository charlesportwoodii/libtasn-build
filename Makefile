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

fpm_debian:
	echo "Packaging libtasn1 for Debian"

	cd /tmp/libtasn1-$(VERSION) && make install DESTDIR=/tmp/libtasn1-$(VERSION)-install

	fpm -s dir \
		-t deb \
		-n libtasn1 \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/libtasn1-$(VERSION)-install \
		-p libtasn1_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libtasn1-build \
		--description "libtasn1" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libtasn1 for RPM"

	cd /tmp/libtasn1-$(VERSION) && make install DESTDIR=/tmp/libtasn1-$(VERSION)-install

	fpm -s dir \
		-t rpm \
		-n libtasn1 \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/libtasn1-$(VERSION)-install \
		-p libtasn1_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libtasn1-build \
		--description "libtasn1" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip