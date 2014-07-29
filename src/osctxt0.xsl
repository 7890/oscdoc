<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
  <xsl:output method="text" encoding="UTF-8"/>
  <!--//tb/131111/140715-->
  <xsl:param name="show_meta">0</xsl:param>

  <xsl:variable name="nl" select="'&#10;'"/>
  <xsl:variable name="ind" select="'   '"/>
  <xsl:strip-space elements="*"/>
  <!-- =============================== -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="osc_unit">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="meta">
    <xsl:if test="$show_meta=1">
      <xsl:value-of select="concat('name ',name,$nl)"/>
      <xsl:value-of select="concat('uri ',uri,$nl)"/>
      <xsl:value-of select="concat('doc_origin ',doc_origin,$nl)"/>
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="meta/url">
    <xsl:if test="$show_meta=1">
      <xsl:value-of select="concat('url ',.,$nl)"/>
    </xsl:if>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="message_in | message_out">
    <xsl:variable name="dir" select="substring-after(name(.),'_')"/>
    <xsl:value-of select="concat($dir,' ',@pattern,' ',@typetag)"/>
    <xsl:if test="desc">
      <xsl:value-of select="concat(' ',desc[1])"/>
    </xsl:if>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="@typetag[.!='']">
    <xsl:value-of select="concat(' ',.)"/>
  </xsl:template>
  <!-- override implicit rule 
http://lenzconsulting.com/how-xslt-works/
-->
  <xsl:template match="text() | @*">
</xsl:template>
</xsl:stylesheet>
