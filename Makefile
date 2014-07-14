PREFIX ?= /usr/local
INSTALLDIR = $(PREFIX)/bin
RESSOURCESDIR = $(INSTALLDIR)/oscdoc_res

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
	@echo "installing oscdoc, osctxt0"
	@echo "--------------------------"
	@echo ""
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make install' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make install"
	@echo ""

	cp $(SRC)/oscdoc.sh $(INSTALLDIR)/oscdoc
	cp $(SRC)/oschema2html.xsl $(INSTALLDIR)/
	cp $(SRC)/oscdocindex.xsl $(INSTALLDIR)/

	cp $(LIB)/xmlverbatim.xsl $(INSTALLDIR)/
	cp $(LIB)/base64encoder.xsl $(INSTALLDIR)/
	cp $(LIB)/base64decoder.xsl $(INSTALLDIR)/
	cp $(LIB)/datamap.xml $(INSTALLDIR)/

	mkdir -p $(RESSOURCESDIR)

	cp $(LIB)/jquery-1.11.1.min.js $(RESSOURCESDIR)/
	cp $(LIB)/ObjTree.js $(RESSOURCESDIR)/
	cp $(LIB)/1pixel.png $(RESSOURCESDIR)/
	cp $(CSS)/oscdoc.css $(RESSOURCESDIR)/
	cp $(CSS)/xmlverbatim.css $(RESSOURCESDIR)/
	cp $(SRC)/oscdoc.js $(RESSOURCESDIR)/

	cp $(SRC)/osctxt0.sh $(INSTALLDIR)/osctxt0
	cp $(SRC)/osctxt0.xsl $(INSTALLDIR)/

	@echo ""
	@echo "use: oscdoc test_data/unit.xml /tmp"
	@echo "use: osctxt0 test_data/unit.xml"
	@echo ""
	@echo "done."
	@echo ""

uninstall:

	@echo ""
	@echo "uninstalling oscdoc"
	@echo "-------------------"
	@echo ""
	@echo "INSTALLDIR: $(INSTALLDIR)"
	@echo ""
	@echo "'make uninstall' needs to be run with root privileges, i.e."
	@echo ""
	@echo "sudo make uninstall"
	@echo ""

	rm -f $(INSTALLDIR)/oscdoc
	rm -f $(INSTALLDIR)/oschema2html.xsl
	rm -f $(INSTALLDIR)/oscdocindex.xsl
	rm -f $(INSTALLDIR)/datamap.xml

	rm -f $(INSTALLDIR)/xmlverbatim.xsl
	rm -f $(INSTALLDIR)/base64encoder.xsl
	rm -f $(INSTALLDIR)/base64decoder.xsl

	rm -rf $(RESSOURCESDIR)

	rm -f $(INSTALLDIR)/osctxt0
	rm -f $(INSTALLDIR)/osctxt0.xsl

	@echo ""
	@echo "done."
	@echo ""
