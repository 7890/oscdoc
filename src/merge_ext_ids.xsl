<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- file with ids in idbase64 elements, same order as <msg> -->
  <xsl:param name="ids"/>
  <xsl:variable name="nl" select="'&#10;'"/>

<!-- ==================== -->
  <xsl:template match="/">
    <xsl:for-each select="//msg">

      <xsl:variable name="pos" select="position()"/>

      <xsl:variable name="idbase64">
        <xsl:copy-of select="document($ids)//idbase64[position()=$pos]"/>
      </xsl:variable>

      <xsl:element name="div">

        <xsl:attribute name="id">
          <xsl:value-of select="$idbase64"/>
        </xsl:attribute>
<!--
        <xsl:attribute name="class">hidden_content</xsl:attribute>
	do not use a class so it can be hidden while css not yet loaded
-->
        <xsl:attribute name="style">display: none;</xsl:attribute>

        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>

      </xsl:element>
    </xsl:for-each>
  </xsl:template>
<!-- ==================== -->
  <xsl:template match="msg/id">
    <!-- remove -->
  </xsl:template>
<!-- ==================== -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
