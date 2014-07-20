<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output omit-xml-declaration="yes" indent="no"/>

  <xsl:param name="path_prefix"/>
  <xsl:param name="xpath"/>
  <xsl:param name="doc_origin"/>
<!--
input is a file with /message_in and /message_out elements
rewrite pattern to absolute path using $path_prefix existing @pattern
-->

  <xsl:template match="/">
    <xsl:element name="messages">

      <xsl:attribute name="path_prefix">
        <xsl:value-of  select="$path_prefix"/>
      </xsl:attribute>

      <xsl:attribute name="xpath"> 
        <xsl:value-of select="$xpath"/>
      </xsl:attribute>

      <xsl:attribute name="doc_origin">
        <xsl:value-of select="$doc_origin"/>
      </xsl:attribute>

      <xsl:value-of select="'&#10;'"/>
      <xsl:apply-templates select="//*[starts-with(name(.),'message_')]"/>
      <xsl:value-of select="'&#10;'"/>
    </xsl:element>
  </xsl:template>

<!-- match all messages, rewrite pattern -->
  <xsl:template match="//*[starts-with(name(.),'message_')]">
    <xsl:copy>
       <xsl:attribute name="pattern">
         <xsl:value-of select="concat($path_prefix,@pattern)"/>
       </xsl:attribute>
       <xsl:apply-templates select="@*[not(name(.)='pattern')]|node()" />
    </xsl:copy>
  </xsl:template>

<!--default copy -->
  <xsl:template match="@*|node()">
     <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
     </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
