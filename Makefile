PREFIX ?= /usr/local
bindir = $(PREFIX)/bin
XSLDIR = $(bindir)/oscdoc_xsl
RESOURCESDIR = $(bindir)/oscdoc_res
MANDIR = $(PREFIX)/man/man1

BUILDDIR = build

SRC = src
BLD = build
LIB = lib
CSS = css
DOC = doc

default: build

all: build manpage

build: 

	@echo ""
	@echo "oscdoc, building tree_dyna"
	@echo "--------------------------"
	@echo ""
	@echo ""

	mkdir -p $(BUILDDIR)
	cp $(LIB)/archives/tree-1.7.0_dyna.tgz $(BUILDDIR)
	cd $(BUILDDIR) && tar xfz tree-1.7.0_dyna.tgz && rm tree-1.7.0_dyna.tgz && cd tree-1.7.0_dyna && make

	@echo ""
	@echo "done."
	@echo ""

manpage: $(DOC)/oscdoc.man.asciidoc
	a2x --doctype manpage --format manpage $(DOC)/oscdoc.man.asciidoc
	gzip -9 -f $(DOC)/oscdoc.1

info:

	@echo ""
	@echo "oscdoc"
	@echo "------"
	@echo ""
	@echo "possible targets are:"
	@echo ""
	@echo "  info           (show make targets)"
	@echo "  build          (extract and build tree_dyna (see lib/archives/))"
	@echo "  install        (install oscdoc scripts, stylesheets, tree_dyna)"
	@echo "  uninstall      (uninstall ..)"
	@echo "  clean          (remove build)"
	@echo ""

install: 

	@echo ""
	@echo "installing oscdoc tools:"
	@echo "------------------------"
	@echo ""
	@echo "oscdoc, osctxt0, oscdoc_aspect_map, oscdoc_aspect_graph"
	@echo "tree_dyna, oscdoc_tree1"
	@echo ""
	@echo "DESTDIR: $(DESTDIR)"
	@echo "bindir: $(bindir)"
	@echo ""
	@echo "'make install' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	cd $(BUILDDIR)/tree-1.7.0_dyna && make install DESTDIR=$(DESTDIR) PREFIX=$(PREFIX)

	install -d $(DESTDIR)$(bindir)

	install -m755 $(SRC)/oscdoc.sh $(DESTDIR)$(bindir)/oscdoc
	install -m755 $(SRC)/oscdoc_common.sh $(DESTDIR)$(bindir)/oscdoc_common.sh
	install -m755 $(SRC)/osctxt0.sh $(DESTDIR)$(bindir)/osctxt0
	install -m755 $(SRC)/oscdoc_aspect_map.sh $(DESTDIR)$(bindir)/oscdoc_aspect_map
	install -m755 $(SRC)/oscdoc_aspect_graph.sh $(DESTDIR)$(bindir)/oscdoc_aspect_graph
	install -m755 $(SRC)/oscdoc_tree1.sh $(DESTDIR)$(bindir)/oscdoc_tree1

	install -d $(DESTDIR)$(XSLDIR)

	install -m644 $(SRC)/oschema2html.xsl $(DESTDIR)$(XSLDIR)/
	install -m644 $(SRC)/oscdocindex.xsl $(DESTDIR)$(XSLDIR)/
	install -m644 $(SRC)/osctxt0.xsl $(DESTDIR)$(XSLDIR)/
	install -m644 $(SRC)/rewrite_message_paths.xsl $(DESTDIR)$(XSLDIR)/
	install -m644 $(SRC)/merge_ext_ids.xsl $(DESTDIR)$(XSLDIR)/

	install -m644 $(LIB)/xmlverbatim.xsl $(DESTDIR)$(XSLDIR)/
#	install -m644 $(LIB)/base64encoder.xsl $(DESTDIR)$(bindir)/
#	install -m644 $(LIB)/base64decoder.xsl $(DESTDIR)$(bindir)/
#	install -m644 $(LIB)/datamap.xml $(DESTDIR)$(bindir)/

	install -d $(DESTDIR)$(RESOURCESDIR)

	install -m644 $(SRC)/oscdoc.js $(DESTDIR)$(RESOURCESDIR)/

	install -m644 $(CSS)/oscdoc.css $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(CSS)/xmlverbatim.css $(DESTDIR)$(RESOURCESDIR)/

	cp -r $(CSS)/dynatree $(DESTDIR)$(RESOURCESDIR)/

	install -m644 $(LIB)/jquery-1.11.1.min.js $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(LIB)/ObjTree.js $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(LIB)/1pixel.png $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(LIB)/draft.png $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(LIB)/jquery.dynatree.min.js $(DESTDIR)$(RESOURCESDIR)/
	install -m644 $(LIB)/jquery-ui.custom.min.js $(DESTDIR)$(RESOURCESDIR)/

	install -m644 $(DOC)/oscdoc.1.gz $(DESTDIR)$(MANDIR)/

	@echo ""
	@echo "use: oscdoc test_data/unit.xml /tmp"
	@echo "use: osctxt0 test_data/unit.xml"
	@echo ""
	@echo "done."
	@echo ""

uninstall:

	@echo ""
	@echo "uninstalling oscdoc tools"
	@echo "-------------------------"
	@echo ""
	@echo "DESTDIR: $(DESTDIR)"
	@echo "bindir: $(bindir)"
	@echo ""
	@echo "'make uninstall' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make uninstall"
	@echo ""

	cd $(BUILDDIR)/tree-1.7.0_dyna && make uninstall DESTDIR=$(DESTDIR) PREFIX=$(PREFIX)

	rm -f $(DESTDIR)$(bindir)/oscdoc
	rm -f $(DESTDIR)$(bindir)/oscdoc_common.sh
	rm -f $(DESTDIR)$(bindir)/osctxt0
	rm -f $(DESTDIR)$(bindir)/oscdoc_aspect_map
	rm -f $(DESTDIR)$(bindir)/oscdoc_aspect_graph
	rm -f $(DESTDIR)$(bindir)/oscdoc_tree1

	rm -f $(DESTDIR)$(XSLDIR)/oschema2html.xsl
	rm -f $(DESTDIR)$(XSLDIR)/oscdocindex.xsl
	rm -f $(DESTDIR)$(XSLDIR)/osctxt0.xsl
	rm -f $(DESTDIR)$(XSLDIR)/rewrite_message_paths.xsl
	rm -f $(DESTDIR)$(XSLDIR)/merge_ext_ids.xsl
	rm -f $(DESTDIR)$(XSLDIR)/xmlverbatim.xsl

	-rmdir $(DESTDIR)$(XSLDIR)

	rm -rf $(DESTDIR)$(RESOURCESDIR)/dynatree

	rm -f $(DESTDIR)$(RESOURCESDIR)/oscdoc.js

	rm -f $(DESTDIR)$(RESOURCESDIR)/oscdoc.css
	rm -f $(DESTDIR)$(RESOURCESDIR)/xmlverbatim.css

	rm -f $(DESTDIR)$(RESOURCESDIR)/jquery-1.11.1.min.js
	rm -f $(DESTDIR)$(RESOURCESDIR)/ObjTree.js
	rm -f $(DESTDIR)$(RESOURCESDIR)/1pixel.png
	rm -f $(DESTDIR)$(RESOURCESDIR)/draft.png
	rm -f $(DESTDIR)$(RESOURCESDIR)/jquery.dynatree.min.js
	rm -f $(DESTDIR)$(RESOURCESDIR)/jquery-ui.custom.min.js
	
	rm -f $(MANDIR)/oscdoc.1.gz

	-rmdir $(DESTDIR)$(RESOURCESDIR)

	-rmdir $(DESTDIR)$(bindir)

	@echo ""
	@echo "done."
	@echo ""

clean:
	rm -rf $(BUILDDIR)

.PHONY: all build clean install uninstall
