PREFIX ?= /usr/local
INSTALLDIR = $(PREFIX)/bin
RESSOURCESDIR = $(INSTALLDIR)/oscdoc_res
XSLDIR = $(INSTALLDIR)/oscdoc_xsl

SRC = src
BLD = build
LIB = lib
CSS = css
#TEST = test_data

default: info

info:

	@echo ""
	@echo "oscdoc"
	@echo "------"
	@echo ""
	@echo "possible targets are:"
	@echo ""
	@echo "  install"
	@echo ""
	@echo "  uninstall"
	@echo ""

install: 

	@echo ""
	@echo "installing oscdoc tools:"
	@echo "------------------------"
	@echo ""
	@echo "oscdoc, osctxt0, oscdoc_aspect_map, oscdoc_aspect_graph"
	@echo ""
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make install' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	cp $(SRC)/oscdoc.sh $(INSTALLDIR)/oscdoc

	mkdir -p $(XSLDIR)

	cp $(SRC)/oschema2html.xsl $(XSLDIR)/
	cp $(SRC)/oscdocindex.xsl $(XSLDIR)/

	cp $(LIB)/xmlverbatim.xsl $(XSLDIR)/
#	cp $(LIB)/base64encoder.xsl $(INSTALLDIR)/
#	cp $(LIB)/base64decoder.xsl $(INSTALLDIR)/
#	cp $(LIB)/datamap.xml $(INSTALLDIR)/

	mkdir -p $(RESSOURCESDIR)

	cp $(LIB)/jquery-1.11.1.min.js $(RESSOURCESDIR)/
	cp $(LIB)/ObjTree.js $(RESSOURCESDIR)/
	cp $(LIB)/1pixel.png $(RESSOURCESDIR)/
	cp $(LIB)/draft.png $(RESSOURCESDIR)/
	cp $(CSS)/oscdoc.css $(RESSOURCESDIR)/
	cp $(CSS)/xmlverbatim.css $(RESSOURCESDIR)/
	cp $(SRC)/oscdoc.js $(RESSOURCESDIR)/

	cp $(SRC)/osctxt0.sh $(INSTALLDIR)/osctxt0
	cp $(SRC)/osctxt0.xsl $(XSLDIR)/

	cp $(SRC)/oscdoc_aspect_map.sh $(INSTALLDIR)/oscdoc_aspect_map
	cp $(SRC)/oscdoc_aspect_graph.sh $(INSTALLDIR)/oscdoc_aspect_graph
	cp $(SRC)/rewrite_message_paths.xsl $(XSLDIR)/
	cp $(SRC)/merge_ext_ids.xsl $(XSLDIR)/

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

#legacy uninstall
	rm -f $(INSTALLDIR)/oschema2html.xsl
	rm -f $(INSTALLDIR)/oscdocindex.xsl
	rm -f $(INSTALLDIR)/datamap.xml

	rm -f $(INSTALLDIR)/xmlverbatim.xsl
	rm -f $(INSTALLDIR)/base64encoder.xsl
	rm -f $(INSTALLDIR)/base64decoder.xsl
#--

	rm -rf $(RESSOURCESDIR)
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

	@echo ""
	@echo "done."
	@echo ""
