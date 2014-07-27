PREFIX ?= /usr/local
INSTALLDIR = $(PREFIX)/bin
RESOURCESDIR = $(INSTALLDIR)/oscdoc_res
XSLDIR = $(INSTALLDIR)/oscdoc_xsl

BUILDDIR = build

SRC = src
BLD = build
LIB = lib
CSS = css

#TEST = test_data

default: build

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
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make install' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	cp $(SRC)/oscdoc.sh $(INSTALLDIR)/oscdoc
	cp $(SRC)/oscdoc_common.sh $(INSTALLDIR)/oscdoc_common.sh

	mkdir -p $(XSLDIR)

	cp $(SRC)/oschema2html.xsl $(XSLDIR)/
	cp $(SRC)/oscdocindex.xsl $(XSLDIR)/

	cp $(LIB)/xmlverbatim.xsl $(XSLDIR)/
#	cp $(LIB)/base64encoder.xsl $(INSTALLDIR)/
#	cp $(LIB)/base64decoder.xsl $(INSTALLDIR)/
#	cp $(LIB)/datamap.xml $(INSTALLDIR)/

	mkdir -p $(RESOURCESDIR)

	cp $(LIB)/jquery-1.11.1.min.js $(RESOURCESDIR)/
	cp $(LIB)/ObjTree.js $(RESOURCESDIR)/
	cp $(LIB)/1pixel.png $(RESOURCESDIR)/
	cp $(LIB)/draft.png $(RESOURCESDIR)/
	cp $(LIB)/jquery.dynatree.min.js $(RESOURCESDIR)/
	cp $(LIB)/jquery-ui.custom.min.js $(RESOURCESDIR)/

	cp $(CSS)/oscdoc.css $(RESOURCESDIR)/
	cp $(CSS)/xmlverbatim.css $(RESOURCESDIR)/
	cp -r $(CSS)/dynatree $(RESOURCESDIR)/

	cp $(SRC)/oscdoc.js $(RESOURCESDIR)/

	cp $(SRC)/osctxt0.sh $(INSTALLDIR)/osctxt0
	cp $(SRC)/osctxt0.xsl $(XSLDIR)/

	cp $(SRC)/oscdoc_aspect_map.sh $(INSTALLDIR)/oscdoc_aspect_map
	cp $(SRC)/oscdoc_aspect_graph.sh $(INSTALLDIR)/oscdoc_aspect_graph

	cp $(SRC)/rewrite_message_paths.xsl $(XSLDIR)/

	cp $(SRC)/merge_ext_ids.xsl $(XSLDIR)/

	cd $(BUILDDIR)/tree-1.7.0_dyna && make install

	cp $(SRC)/oscdoc_tree1.sh $(INSTALLDIR)/oscdoc_tree1

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
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make uninstall' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make uninstall"
	@echo ""

	rm -f $(INSTALLDIR)/oscdoc
	rm -f $(INSTALLDIR)/oscdoc_common.sh

#legacy uninstall
	rm -f $(INSTALLDIR)/oschema2html.xsl
	rm -f $(INSTALLDIR)/oscdocindex.xsl
	rm -f $(INSTALLDIR)/datamap.xml

	rm -f $(INSTALLDIR)/xmlverbatim.xsl
	rm -f $(INSTALLDIR)/base64encoder.xsl
	rm -f $(INSTALLDIR)/base64decoder.xsl
#--

	rm -rf $(RESOURCESDIR)
	rm -rf $(XSLDIR)

	rm -f $(INSTALLDIR)/osctxt0

#legacy uninstall
	rm -f $(INSTALLDIR)/osctxt0.xsl
#--

	rm -f $(INSTALLDIR)/oscdoc_aspect_map
	rm -f $(INSTALLDIR)/oscdoc_aspect_graph

#legacy uninstall
	rm -f $(INSTALLDIR)/rewrite_message_paths.xsl
	rm -f $(INSTALLDIR)/merge_ext_ids.xsl
#--

	cd $(BUILDDIR)/tree-1.7.0_dyna && make uninstall

	rm -f $(INSTALLDIR)/oscdoc_tree1

	@echo ""
	@echo "done."
	@echo ""

clean:
	rm -rf $(BUILDDIR)

