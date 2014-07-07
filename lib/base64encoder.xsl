<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>
  <xsl:variable name="datamap" select="document('datamap.xml')"/>
  <!-- Test -->
  <!--
  <xsl:template match="/">
    <xsl:variable name="asciiString1" select="'Hello World!'"/>
    <xsl:variable name="asciiString2" select="'This is base64 encoding'"/>
    <xsl:variable name="asciiString3" select="'blue'"/>
    <xsl:call-template name="convertToBase64">
      <xsl:with-param name="asciiString" select="$asciiString1"/>
    </xsl:call-template>
    <xsl:text>&#xa;========================&#xa;</xsl:text>
    <xsl:call-template name="convertToBase64">
      <xsl:with-param name="asciiString" select="$asciiString2"/>
    </xsl:call-template>
    <xsl:text>&#xa;========================&#xa;</xsl:text>
    <xsl:call-template name="convertToBase64">
      <xsl:with-param name="asciiString" select="$asciiString3"/>
    </xsl:call-template>
    <xsl:text>&#xa;========================&#xa;</xsl:text>
  </xsl:template>
  -->
  <!-- Template to convert the Ascii string into base64 representation -->
  <xsl:template name="convertToBase64">
    <xsl:param name="asciiString"/>
    <xsl:variable name="output">
      <xsl:if test="string-length($asciiString) &gt;= 3">
        <xsl:variable name="binaryAsciiString">
          <xsl:call-template name="asciiStringToBinary">
            <xsl:with-param name="string" select="substring($asciiString, 1, 3)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="digit1">
          <xsl:call-template name="binaryToDecimal">
            <xsl:with-param name="binary" select="substring($binaryAsciiString, 1, 6)"/>
            <xsl:with-param name="sum" select="0"/>
            <xsl:with-param name="index" select="0"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="digit2">
          <xsl:call-template name="binaryToDecimal">
            <xsl:with-param name="binary" select="substring($binaryAsciiString, 7, 6)"/>
            <xsl:with-param name="sum" select="0"/>
            <xsl:with-param name="index" select="0"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="digit3">
          <xsl:call-template name="binaryToDecimal">
            <xsl:with-param name="binary" select="substring($binaryAsciiString, 13, 6)"/>
            <xsl:with-param name="sum" select="0"/>
            <xsl:with-param name="index" select="0"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="digit4">
          <xsl:call-template name="binaryToDecimal">
            <xsl:with-param name="binary" select="substring($binaryAsciiString, 19, 6)"/>
            <xsl:with-param name="sum" select="0"/>
            <xsl:with-param name="index" select="0"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit1]/base64"/>
        <xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit2]/base64"/>
        <xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit3]/base64"/>
        <xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit4]/base64"/>
        <xsl:call-template name="convertToBase64">
          <xsl:with-param name="asciiString" select="substring($asciiString, 4)"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="string-length($asciiString) = 2"><xsl:variable name="binaryAsciiString"><xsl:call-template name="asciiStringToBinary"><xsl:with-param name="string" select="$asciiString"/></xsl:call-template></xsl:variable><xsl:variable name="digit1"><xsl:call-template name="binaryToDecimal"><xsl:with-param name="binary" select="substring($binaryAsciiString, 1, 6)"/><xsl:with-param name="sum" select="0"/><xsl:with-param name="index" select="0"/></xsl:call-template></xsl:variable><xsl:variable name="digit2"><xsl:call-template name="binaryToDecimal"><xsl:with-param name="binary" select="substring($binaryAsciiString, 7, 6)"/><xsl:with-param name="sum" select="0"/><xsl:with-param name="index" select="0"/></xsl:call-template></xsl:variable><xsl:variable name="digit3"><xsl:call-template name="binaryToDecimal"><xsl:with-param name="binary" select="concat(substring($binaryAsciiString, 13), '00')"/><xsl:with-param name="sum" select="0"/><xsl:with-param name="index" select="0"/></xsl:call-template></xsl:variable><xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit1]/base64"/><xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit2]/base64"/><xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit3]/base64"/>=
          </xsl:if>
      <xsl:if test="string-length($asciiString) = 1"><xsl:variable name="binaryAsciiString"><xsl:call-template name="asciiStringToBinary"><xsl:with-param name="string" select="$asciiString"/></xsl:call-template></xsl:variable><xsl:variable name="digit1"><xsl:call-template name="binaryToDecimal"><xsl:with-param name="binary" select="substring($binaryAsciiString, 1, 6)"/><xsl:with-param name="sum" select="0"/><xsl:with-param name="index" select="0"/></xsl:call-template></xsl:variable><xsl:variable name="digit2"><xsl:call-template name="binaryToDecimal"><xsl:with-param name="binary" select="concat(substring($binaryAsciiString, 7),'0000')"/><xsl:with-param name="sum" select="0"/><xsl:with-param name="index" select="0"/></xsl:call-template></xsl:variable><xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit1]/base64"/><xsl:value-of select="$datamap/datamap/decimalbase64/char[value = $digit2]/base64"/>==
          </xsl:if>
    </xsl:variable>
    <xsl:value-of select="normalize-space($output)"/>
  </xsl:template>
  <!-- Template to convert a binary number to decimal representation; this template calls template pow -->
  <xsl:template name="binaryToDecimal">
    <xsl:param name="binary"/>
    <xsl:param name="sum"/>
    <xsl:param name="index"/>
    <xsl:if test="substring($binary,string-length($binary) - 1) != ''">
      <xsl:variable name="power">
        <xsl:call-template name="pow">
          <xsl:with-param name="m" select="2"/>
          <xsl:with-param name="n" select="$index"/>
          <xsl:with-param name="result" select="1"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="binaryToDecimal">
        <xsl:with-param name="binary" select="substring($binary, 1, string-length($binary) - 1)"/>
        <xsl:with-param name="sum" select="$sum + substring($binary,string-length($binary) ) * $power"/>
        <xsl:with-param name="index" select="$index + 1"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="substring($binary,string-length($binary) - 1) = ''">
      <xsl:value-of select="$sum"/>
    </xsl:if>
  </xsl:template>
  <!-- Template to calculate m to the power n -->
  <xsl:template name="pow">
    <xsl:param name="m"/>
    <xsl:param name="n"/>
    <xsl:param name="result"/>
    <xsl:if test="$n &gt;= 1">
      <xsl:call-template name="pow">
        <xsl:with-param name="m" select="$m"/>
        <xsl:with-param name="n" select="$n - 1"/>
        <xsl:with-param name="result" select="$result * $m"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$n = 0">
      <xsl:value-of select="$result"/>
    </xsl:if>
  </xsl:template>
  <!-- Template to convert an ascii string to binary representation; this template calls template decimalToBinary -->
  <xsl:template name="asciiStringToBinary">
    <xsl:param name="string"/>
    <xsl:if test="substring($string, 1, 1) != ''">
      <xsl:if test="$datamap/datamap/asciidecimal/char[ascii = substring($string, 1, 1)]/decimal &lt; 64">
        <xsl:text>00</xsl:text>
      </xsl:if>
      <xsl:if test="$datamap/datamap/asciidecimal/char[ascii = substring($string, 1, 1)]/decimal &gt;= 64">
        <xsl:text>0</xsl:text>
      </xsl:if>
      <xsl:call-template name="decimalToBinary">
        <xsl:with-param name="decimal" select="$datamap/datamap/asciidecimal/char[ascii = substring($string, 1, 1)]/decimal"/>
        <xsl:with-param name="prev" select="''"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="substring($string, 2) != ''">
      <xsl:call-template name="asciiStringToBinary">
        <xsl:with-param name="string" select="substring($string, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- Template to convert a decimal number to binary representation -->
  <xsl:template name="decimalToBinary">
    <xsl:param name="decimal"/>
    <xsl:param name="prev"/>
    <xsl:variable name="divresult" select="floor($decimal div 2)"/>
    <xsl:variable name="modresult" select="$decimal mod 2"/>
    <xsl:choose>
      <xsl:when test="$divresult &gt; 1">
        <xsl:call-template name="decimalToBinary">
          <xsl:with-param name="decimal" select="$divresult"/>
          <xsl:with-param name="prev" select="concat($modresult, $prev)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$divresult = 0">
        <xsl:value-of select="concat($modresult, $prev)"/>
      </xsl:when>
      <xsl:when test="$divresult = 1">
        <xsl:text>1</xsl:text>
        <xsl:value-of select="concat($modresult, $prev)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
