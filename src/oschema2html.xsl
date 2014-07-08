<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- //tb/1407 -->
  <xsl:import href="xmlverbatim.xsl"/>
  <xsl:import href="base64encoder.xsl"/>
  <xsl:import href="base64decoder.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>

  <xsl:param name="call_timestamp"/>

  <xsl:variable name="oscdoc_version">140614.1</xsl:variable>
  <xsl:variable name="nl" select="'&#10;'"/>
  <xsl:variable name="nbsp" select="'&#xA0;'"/>
  <!-- <xsl:strip-space elements="*"/> -->
  <!-- =============================== -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="osc_unit">
    <xsl:element name="cdata">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="message_in | message_out">
    <xsl:element name="msg">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="id">

        <xsl:variable name="direction">
          <xsl:value-of select="substring-after(name(.),'_')"/>
        </xsl:variable>

        <xsl:variable name="id">
          <xsl:call-template name="convertToBase64">
            <xsl:with-param name="asciiString">
              <xsl:value-of select="concat(//meta/uri,';',@pattern,';',@typetag,';',$direction,';')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="translate($id,'+/=','-_.')"/>
      </xsl:attribute>

      <xsl:variable name="tt">
        <xsl:apply-templates select="@typetag"/>
      </xsl:variable>

      <xsl:variable name="dir">
        <xsl:choose>
          <xsl:when test="name()='message_in'">IN</xsl:when>
          <xsl:when test="name()='message_out'">OUT</xsl:when>
        </xsl:choose>
      </xsl:variable>

      <h2>Message Patttern</h2>
      <h3>
        <xsl:value-of select="concat(@pattern,' ',$tt)"/>
      </h3>

      <h2>Direction</h2>
      <xsl:element name="h3">
        <xsl:value-of select="$dir"/>
      </xsl:element>

      <xsl:apply-templates select="desc"/>

      <xsl:if test="custom">
        <h2>Custom</h2>
        <div class="xmlverb-default xmlDiv">
          <xsl:apply-templates select="custom" mode="xmlverb">
            <xsl:with-param name="indent-elements" select="true()"/>
          </xsl:apply-templates>
        </div>
      </xsl:if>

      <xsl:if test="condition">
        <h2>Condition</h2>
        <xsl:apply-templates select="condition"/>
      </xsl:if>

      <xsl:if test="target">
        <h2>Target</h2>
        <xsl:apply-templates select="target"/>
      </xsl:if>

      <xsl:if test="param_i | param_h | param_f | param_d | param_s | param_b | param_X | param__">
        <h2>Parameters</h2>
        <ul>
          <xsl:apply-templates select="param_i | param_h | param_f | param_d | param_s | param_b | param_X | param__"/>
        </ul>
      </xsl:if>

    </xsl:element>
    <!-- end msg -->
  </xsl:template>

  <!-- =============================== -->
  <xsl:template match="@typetag[.!='']">
    <xsl:value-of select="concat(' ',.)"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="condition">
    <h3>
      <xsl:value-of select="@type"/>
    </h3>
    <xsl:apply-templates select="custom"/>
    <xsl:apply-templates select="desc"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="target">
    <h3>
      <xsl:value-of select="@type"/>
      <xsl:if test="@proto">
        <xsl:value-of select="concat(' (',@proto,')')"/>
      </xsl:if>
    </h3>
    <xsl:apply-templates select="custom"/>
    <xsl:apply-templates select="desc"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="token">
    <tr>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="point">
    <tr>
      <td>
        <span class="value">
          <xsl:value-of select="@value"/>
        </span>
      </td>
      <td>
        <xsl:value-of select="@symbol"/>
      </td>
      <td>
        <xsl:value-of select="."/>
      </td>
    </tr>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="hints">
    <xsl:if test="point">
      <table class="mystyle">
        <tr>
          <td colspan="3">
            <strong>Hints</strong>
          </td>
        </tr>
        <xsl:apply-templates select="point"/>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="grid">
    <xsl:if test="point">
      <table class="mystyle">
        <tr>
          <td colspan="3">
            <strong>Grid</strong>
          </td>
        </tr>
        <xsl:apply-templates select="point"/>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_min_max[@lmin='[' and @lmax=']'] | param_i//range_min_max | param_h//range_min_max">
    <xsl:element name="h4">
      <xsl:value-of select="concat('Range []: ',@min,' _LTE_ value _LTE_ ',@max,' Default: ',@default)"/>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- =============================== -->
  <xsl:template match="range_min_max[@lmin='[' and @lmax='[']">
    <xsl:element name="h4">

<!-- !!! -->
</xsl:element>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- =============================== -->
  <xsl:template match="range_min_max[@lmin=']' and @lmax=']']">
    <xsl:element name="h4">
      <xsl:value-of select="concat('Range ]]: ',@min,' _LT_ value _LTE_ ',@max,' Default: ',@default)"/>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_min_max[@lmin=']' and @lmax='[']">
    <xsl:element name="h4">
      <xsl:value-of select="concat('Range ][: ',@min,' _LT_ value _LT_ ',@max,' Default: ',@default)"/>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template name="format_range">
    <xsl:param name="descriptor"/>
    <xsl:param name="min"/>
    <xsl:param name="comp1"/>
    <xsl:param name="symbol"/>
    <xsl:param name="comp2"/>
    <xsl:param name="max"/>
    <xsl:param name="symbol"/>
    <xsl:param name="default"/>

    <xsl:element name="h4">
      <xsl:value-of select="concat('Range ',$descriptor,':',$nbsp,$nbsp,$nbsp)"/>
      <span class="value">
        <xsl:value-of select="$min"/>
      </span>
      <xsl:value-of select="concat($nbsp,$comp1,$nbsp,$symbol,$nbsp,$comp2,$nbsp)"/>
      <span class="value">
        <xsl:value-of select="$max"/>
      </span>
      <xsl:value-of select="concat($nbsp,$nbsp,$nbsp,'Default:',$nbsp)"/>
      <span class="value">
        <xsl:value-of select="$default"/>
      </span>
    </xsl:element>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_min_inf[@lmin='['] | param_i//range_min_inf | param_h//range_min_inf">
    <xsl:call-template name="format_range">
      <xsl:with-param name="descriptor" select="concat('[..._INF_','')"/>
      <xsl:with-param name="min" select="@min"/>
      <xsl:with-param name="comp1" select="concat('_LTE_','')"/>
      <xsl:with-param name="symbol" select="../@symbol"/>
      <xsl:with-param name="comp2" select="concat('_LT_','')"/>
      <xsl:with-param name="max" select="concat('_INF_','')"/>
      <xsl:with-param name="default" select="@default"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_min_inf[@lmin=']']">
    <xsl:call-template name="format_range">
      <xsl:with-param name="descriptor" select="concat(']..._INF_','')"/>
      <xsl:with-param name="min" select="@min"/>
      <xsl:with-param name="comp1" select="concat('_LT_','')"/>
      <xsl:with-param name="symbol" select="../@symbol"/>
      <xsl:with-param name="comp2" select="concat('_LT_','')"/>
      <xsl:with-param name="max" select="concat('_INF_','')"/>
      <xsl:with-param name="default" select="@default"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_inf_max[@lmax=']'] | param_i//range_inf_max | param_h//range_inf_max">
    <xsl:call-template name="format_range">
      <xsl:with-param name="descriptor" select="concat('_INF_...]','')"/>
      <xsl:with-param name="min" select="concat('-_INF_','')"/>
      <xsl:with-param name="comp1" select="concat('_LT_','')"/>
      <xsl:with-param name="symbol" select="../@symbol"/>
      <xsl:with-param name="comp2" select="concat('_LTE_','')"/>
      <xsl:with-param name="max" select="@max"/>
      <xsl:with-param name="default" select="@default"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_inf_max[@lmax='[']">
    <xsl:call-template name="format_range">
      <xsl:with-param name="descriptor" select="concat('_INF_...[','')"/>
      <xsl:with-param name="min" select="concat('-_INF_','')"/>
      <xsl:with-param name="comp1" select="concat('_LT_','')"/>
      <xsl:with-param name="symbol" select="../@symbol"/>
      <xsl:with-param name="comp2" select="concat('_LT_','')"/>
      <xsl:with-param name="max" select="@max"/>
      <xsl:with-param name="default" select="@default"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="range_inf_inf">
    <xsl:call-template name="format_range">
      <xsl:with-param name="descriptor" select="concat('_INF_..._INF_','')"/>
      <xsl:with-param name="min" select="concat('-_INF_','')"/>
      <xsl:with-param name="comp1" select="concat('_LT_','')"/>
      <xsl:with-param name="symbol" select="../@symbol"/>
      <xsl:with-param name="comp2" select="concat('_LT_','')"/>
      <xsl:with-param name="max" select="concat('_INF_','')"/>
      <xsl:with-param name="default" select="@default"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_s/whitelist">
    <xsl:if test="token">
      <table class="mystyle">
        <tr>
          <td>
            <strong>Whitelist</strong>
          </td>
        </tr>
        <xsl:apply-templates select="token"/>
      </table>
    </xsl:if>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template name="get_typetag_from_node_name">
    <xsl:choose>
      <xsl:when test="name()='param_i'">i</xsl:when>
      <xsl:when test="name()='param_h'">h</xsl:when>
      <xsl:when test="name()='param_f'">f</xsl:when>
      <xsl:when test="name()='param_d'">d</xsl:when>
      <xsl:when test="name()='param_s'">s</xsl:when>
      <xsl:when test="name()='param_b'">b</xsl:when>
      <xsl:when test="name()='param_X'">X</xsl:when>
      <xsl:when test="name()='param__'">_</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- =============================== -->  
  <xsl:template match="@units">
    <xsl:value-of select="concat(' (',.,')')"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_i | param_h | param_f | param_d | param_s | param_b | param_X | param__">

    <xsl:variable name="type">
      <xsl:call-template name="get_typetag_from_node_name"/>
    </xsl:variable>

    <xsl:element name="h3">
      <xsl:value-of select="concat(position(),') ',$type,': ',@symbol,' ')"/>
      <xsl:apply-templates select="@units"/>
    </xsl:element>

    <xsl:apply-templates select="desc"/>

    <xsl:if test="custom">
      <div class="xmlverb-default xmlDiv">
        <xsl:apply-templates select="custom" mode="xmlverb">
          <xsl:with-param name="indent-elements" select="true()"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>

    <xsl:apply-templates select="range_min_max | range_min_inf | range_inf_max | range_inf_inf"/>
  </xsl:template>
  <!-- =============================== 
string, blob
needs removal of $nl $ind -> make html
-->
  <xsl:template match="param_s/@min_length">
    <h4>
      <xsl:value-of select="concat('Minimum Length: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_s/@max_length">
    <h4>
      <xsl:value-of select="concat('Maximum Length: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_s/@regex">
    <h4>
      <xsl:value-of select="concat('Regular Expression Filter: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_s/@default">
    <h4>
      <xsl:value-of select="concat('Default: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_s">
    <h3>
      <xsl:value-of select="concat(position(),') s: ',@symbol)"/>
    </h3>
    <!--    <xsl:apply-templates select="@units"/>-->
    <xsl:apply-templates select="desc"/>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="whitelist"/>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_b/@min_size">
    <h4>
      <xsl:value-of select="concat('Minimum Size: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_b/@max_size">
    <h4>
      <xsl:value-of select="concat('Maximum Size: ',.)"/>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="param_b">
    <h3>
      <xsl:value-of select="concat(position(),') b: ',@symbol)"/>
      <xsl:apply-templates select="@units"/>
    </h3>
    <xsl:apply-templates select="desc"/>
    <xsl:apply-templates select="@*[not(name(.)='units')]"/>
  </xsl:template>
  <!-- =============================== -->
  <!--
  <xsl:template match="param_X">
    <xsl:value-of select="concat($ind,position(),') X: ',@symbol)"/>
    <xsl:apply-templates select="@units"/>
    <xsl:value-of select="concat($nl,$nl)"/>


    <xsl:apply-templates select="desc"/>
    <xsl:apply-templates select="@*[not(name(.)='units')]"/>
  </xsl:template>
-->
  <!-- =============================== -->
  <xsl:template match="desc[.!='']">

    <xsl:if test="position()=1 and (name(..)= 'message_in' or name(..)='message_out')">
      <h2>Description</h2>
    </xsl:if>

    <ul>
      <xsl:choose>
        <xsl:when test="name(..)= 'message_in' or name(..)='message_out' or name(..)='condition' or name(..)='target'">
          <li>
            <xsl:value-of select="normalize-space(.)"/>
          </li>
        </xsl:when>
        <xsl:otherwise>
          <li class="double">
            <xsl:value-of select="normalize-space(.)"/>
          </li>
        </xsl:otherwise>
      </xsl:choose>
    </ul>
  </xsl:template>
  <!-- override implicit rule http://lenzconsulting.com/how-xslt-works/ -->
  <xsl:template match="text() | @*"/>
</xsl:stylesheet>
