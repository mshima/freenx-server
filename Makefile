.PHONY: all install clean nxenv_install suid_install

SHELL = /bin/bash

SUBDIRS=nxredir nxviewer-passwd nxserver-helper nxserver-suid nx-session-launcher
PROGRAMS=nxacl.sample nxacl.app nxcheckload.sample nxcups-gethost nxdesktop_helper nxdialog nxkeygen nxloadconfig nxnode nxnode-login nxprint nxserver nxserver-helper/nxserver-helper nxsetup nxviewer_helper nxviewer-passwd/nxpasswd/nxpasswd nx-session-launcher/nx-session-launcher nx-session-launcher/nx-session-launcher-suid nxserver-usermode nxserver-suid/nxserver-suid
PATH_BIN=/usr/lib/nx/

all:
	cd nxviewer-passwd && xmkmf && make Makefiles && make depend
	source ./nxloadconfig &&\
	export PATH_BIN PATH_LIB CUPS_BACKEND NX_VERSION NX_ETC_DIR &&\
	for i in $(SUBDIRS) ; \
	do\
		echo "making" all "in $$i..."; \
	        $(MAKE) -C $$i all || exit 1;\
	done

suid_install:
	chown nx:root $(DESTDIR)/$$PATH_BIN/nxserver-suid
	chmod 4755 $(DESTDIR)/$$PATH_BIN/nxserver-suid

nxenv_install:
	install -m755 -d $(DESTDIR)/$$PATH_BIN/
	install -m755 -d $(DESTDIR)/$$PATH_LIB/freenx-server/
	install -m755 -d $(DESTDIR)/$$NX_ETC_DIR/
	install -m755 -d $(DESTDIR)/$$CUPS_BACKEND/
	for i in $(PROGRAMS) ;\
	do\
	        install -m755 $$i $(DESTDIR)/$$PATH_BIN/ || exit 1;\
	done
	install -m644 node.conf.sample $(DESTDIR)/$$NX_ETC_DIR/node.conf
	install -m755 nxshadowacl.sample $(DESTDIR)/$$NX_ETC_DIR/nxshadowacl
	install -m755 nxacl.sample $(DESTDIR)/$$NX_ETC_DIR/nxacl
	install -m755 nxcheckload.sample $(DESTDIR)/$$NX_ETC_DIR/nxcheckload
	$(MAKE) -C nxredir install
	# uncomment the following line to make
	# nxserver-suid suid nx
	#$(MAKE) suid_install

clean:
	for i in $(SUBDIRS) ; \
	do\
		echo "making" clean "in $$i..."; \
		if test -e "$$i/Makefile"; \
		then $(MAKE) -C $$i clean || exit 1;\
		else echo ignoring $$i;\
		fi;\
	done
	rm -f nxviewer-passwd/Makefile.back
	rm -f nxviewer-passwd/Makefile
	rm -f nxviewer-passwd/nxpasswd/Makefile
	rm -f nxviewer-passwd/libvncauth/Makefile

install:
	source ./nxloadconfig &&\
	export PATH_BIN PATH_LIB CUPS_BACKEND NX_VERSION NX_ETC_DIR &&\
	$(MAKE) nxenv_install

debian-tarball:
	mkdir freenx-server
	cp -r * freenx-server || echo 0
	sed "s/NX_VERSION=3.2.0-74-SVN/NX_VERSION=3.2.0-74-TEAMBZR`bzr revno`/" nxloadconfig > freenx-server/nxloadconfig
	rm -rf freenx-server/.bzr*
	rm -rf freenx-server/freenx-server
	[ -d ".bzr" ] && tar -czf ../freenx-server_0.7.3+teambzr`bzr revno`.orig.tar.gz freenx-server
	rm -rf freenx-server

git-debian-tarball:
	git archive HEAD | gzip > ../freenx-server_0.7.3.zgit.`date +%y%m%d.%H%M`.`git rev-list -n1 --abbrev-commit HEAD`.orig.tar.gz

git-tarball:
	git archive HEAD | gzip > ../freenx-server_`git rev-list -n1 --abbrev-commit HEAD`.tar.gz

