<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="xmlverbatim.xsl"/>
  <xsl:output method="html" indent="yes"/>
  <xsl:variable name="infinity" select="'&#8734;'"/>
  <xsl:variable name="nbsp" select="'&#xA0;'"/>
  <!-- //tb/1407 -->
  <!-- =========================== -->
  <xsl:template match="/osc_unit">
    <xsl:variable name="name" select="meta/name"/>
    <html>

      <head>
        <script type="text/javascript" src="res/jquery-1.11.1.min.js"/>
        <script type="text/javascript" src="res/ObjTree.js"/>
        <script type="text/javascript" src="res/xml_data.js"/>
        <link type="text/css" href="res/oscdoc.css" rel="stylesheet"/>
        <link type="text/css" href="res/xmlverbatim.css" rel="stylesheet"/>
        <title>
          <xsl:value-of select="concat($name,' OSC API')"/>
        </title>
      </head>

      <body onload="javascript:showHelp();">
        <div id="outterDiv" style="padding: 5px;">
          <table style="width:100%;">
            <tr>
              <td style="vertical-align:top;width:1px;">
                <img width="300px" height="0px" src="../lib/1pixel.png"/>

                <div class="inputDiv">
                  <h1 style="margin-bottom: 0;">
                    <xsl:value-of select="concat($name,' OSC API')"/>
                  </h1>
                  <a href="#" onfocus="javascript:showHelp();" style="outline: none;">Documentation</a>
                  <xsl:value-of select="concat($nbsp,$nbsp)"/>
                  <a href="#" onfocus="javascript:showMeta();" style="outline: none;">Metadata</a>
                  <form action="#" id="form1" style="margin-top: 10px;"><input type="button" id="btn1" onclick="javascript:showAll();" value="Show All"/><input type="button" id="btn2" onclick="javascript:clearInput();" value="Clear Input"/><p>Search for Message Pattern:</p>Direction: <select id="opt1" name="direction"><option value="3">in+out</option><option value="1">in</option><option value="2">out</option></select><br/><input class="focused" type="text" id="input1" size="10" autocomplete="off"/></form>
                </div>

                <div id="list" class="listDiv"/>

                <div>
                  <small>created with oscdoc</small>
                </div>
              </td>
              <td style="vertical-align:top;padding-left:0px">

                <div id="desc" class="outputDiv"/>
                <!-- legend -->

                <div>
                  <h2>Legend</h2>
                  <h3>Datatypes</h3>
                  <ul>
                    <li><strong>i</strong>: int32, signed 32 bit integer (4 bytes), -2147483648 - 2147483647</li>
                    <li><strong>h</strong>: int64 / long, signed 64 bit integer (8 bytes), -9223372036854775808 - 9223372036854775807</li>
<!-- 
http://stackoverflow.com/questions/2053843/min-and-max-value-of-data-type-in-c
http://steve.hollasch.net/cgindex/coding/ieeefloat.html
 -->
                    <li><strong>f</strong>: float, signed 32 bit float (4 bytes), -3.40282347E+38 - 3.40282347E+38 (smallest: 1.175494351E-38)</li>
                    <li><strong>d</strong>: double, signed 64 bit float (8 bytes), -1.797693E+308 - 1.797693E+308 (smallest: 2.225074E-308)</li>
                    <li><strong>s</strong>: string</li>
                    <li><strong>b</strong>: blob</li>
                    <li><strong>X</strong>: unknown / custom parameter type. arbitrary content</li>
                    <li><strong>_</strong>: last expressed param in typetag can occur 0 to n times</li>
                  </ul>
                  <h3>Directions</h3>
                  <ul>
                    <li><strong>IN</strong>: Message is sent by any source and received by the program / API that is being described</li>
                    <li><strong>OUT</strong>: Message is sent by the program / API that is being described to any OSC target</li>
                  </ul>
                  <h3>Ranges</h3>
                  <ul>
                    <li><strong><xsl:value-of select="$infinity"/></strong>: Infinity. The mininum or maximum possible value is limited only by the used data type</li>
                    <li><strong>[</strong>: For lower range bounds: Minimum value of range is inclusive</li>
                    <li><strong>]</strong>: For lower range bounds: Minimum value of range is exclusive</li>
                    <li><strong>]</strong>: For upper range bounds: Maximum value of range is inclusive</li>
                    <li><strong>[</strong>: For upper range bounds: Maximum value of range is exclusive</li>
                    <li><strong>Hints</strong>: Points of interest in range (not exclusively). Also when either -<xsl:value-of select="$infinity"/> or +<xsl:value-of select="$infinity"/> involved)</li>
                    <li><strong>Grid</strong>: Valid points in range. Values not in range are invalid.</li>
                  </ul>
                </div>
                <!-- end legend -->
              </td>
            </tr>
          </table>
        </div>
        <!-- end div outterDiv -->
        <script type="text/javascript" src="res/oscdoc.js"/>

        <div id="__help" class="hidden_content">
          <xsl:if test="doc">
            <xsl:copy-of select="doc"/>
          </xsl:if>
        </div>

        <div id="__meta" class="hidden_content">
          <xsl:apply-templates select="meta"/>
        </div>
        <!-- ================================================ -->
        <xsl:comment>DIVS</xsl:comment>
        <!-- end divs.out include -->
      </body>
    </html>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="meta">
    <h2>Metadata</h2>
    <h3>name</h3>
    <h4>
      <xsl:value-of select="name"/>
    </h4>
    <h3>uri</h3>
    <h4>
      <xsl:value-of select="uri"/>
    </h4>
    <h3>doc_origin</h3>
    <h4>
      <a href="{doc_origin}" target="_blank">
        <xsl:value-of select="doc_origin"/>
      </a>
    </h4>
    <xsl:apply-templates select="author"/>
    <xsl:apply-templates select="url"/>
    <xsl:apply-templates select="desc"/>
    <xsl:apply-templates select="custom"/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="meta/author">
    <xsl:if test="position()=1">
      <h3>authors</h3>
    </xsl:if>
    <h4>
      <xsl:apply-templates select="firstname"/>
      <xsl:apply-templates select="lastname"/>
      <xsl:apply-templates select="email"/>
    </h4>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="author/firstname">
    <xsl:value-of select="concat(.,$nbsp)"/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="author/lastname">
    <xsl:value-of select="concat(.,$nbsp)"/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="author/email">
    <xsl:value-of select="concat('(',.,')')"/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="meta/url">
    <xsl:if test="position()=1">
      <h3>urls</h3>
    </xsl:if>
    <h4>
      <a href="{.}" target="_blank">
        <xsl:value-of select="."/>
      </a>
    </h4>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="desc">
    <xsl:value-of select="."/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="meta/custom">
    <xsl:if test="position()=1">
      <h3>custom</h3>
    </xsl:if>
    <div class="xmlverb-default xmlDiv">
      <xsl:apply-templates select="." mode="xmlverb"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
