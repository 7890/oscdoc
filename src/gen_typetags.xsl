<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
  <!--http://stackoverflow.com/questions/9548104/add-attribute-to-tag-with-xslt-->
  <!-- this template is applied by default to all nodes and attributes -->
  <xsl:template match="@*|node()">
    <!-- just copy all my attributes and child nodes, except if there's a better template for some of them -->
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- this template is applied to message nodes that doesn't have a typetag attribute -->
  <xsl:template match="//*[starts-with(name(.),'message_')]/@typetag">
    <!-- copy me and my attributes and my subnodes, applying templates as necessary, and add a typetag attribute  -->
    <xsl:attribute name="typetag">
      <xsl:call-template name="generate_typetag">
        <xsl:with-param name="path" select=".."/>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="generate_typetag">
    <!-- path to message_ -->
    <xsl:param name="path" value="."/>
    <xsl:for-each select="$path//*[starts-with(name(.),'param_')]">
      <xsl:value-of select="substring-after(name(.),'_')"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
