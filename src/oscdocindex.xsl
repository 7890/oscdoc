<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="xmlverbatim.xsl"/>
  <xsl:output method="html" indent="yes"/>

  <xsl:param name="aspects_graph_tl" select="''"/>
  <xsl:param name="aspects_graph_svg" select="''"/>
  <xsl:param name="show_tree" select="'0'"/>
  <xsl:param name="messages_digest" select="''"/>

<!--
  <xsl:variable name="infinity" select="'&#8734;'"/>
-->
  <xsl:variable name="infinity" select="'&amp;infin;'"/>
<!--
  <xsl:variable name="nbsp" select="'&#xA0;'"/>
-->
  <xsl:variable name="nbsp" select="'&amp;nbsp;'"/>

  <!-- //tb/1407 -->
  <!-- =========================== -->
  <xsl:template match="/osc_unit">
    <xsl:variable name="name" select="meta/name"/>
    <html>
      <head>
        <script type="text/javascript" src="res/jquery-1.11.1.min.js"/>
        <script type="text/javascript" src="res/ObjTree.js"/>
        <script type="text/javascript" src="res/xml_data.js"/>

        <xsl:if test="$show_tree='1'">
         <script type="text/javascript" src="res/jquery-ui.custom.min.js"/>
         <script type="text/javascript" src="res/jquery.dynatree.min.js"/>
         <link type="text/css" href="res/dynatree/ui.dynatree.css" rel="stylesheet"/>
        </xsl:if>

        <link type="text/css" href="res/oscdoc.css" rel="stylesheet"/>
        <link type="text/css" href="res/xmlverbatim.css" rel="stylesheet"/>

        <title>
          <xsl:value-of select="concat($name,' OSC API')"/>
        </title>
      </head>

      <body onload="javascript:showMeta();showAll();">
        <div id="outterDiv" style="padding: 5px;">
          <table style="width:100%;">
            <tr>
              <td style="vertical-align:top;width:1px;">
                <div class="inputDiv">
                  <h1 style="margin-bottom: 0;">
                    <xsl:value-of select="concat($name,' OSC API')"/>
                  </h1>

                  <a href="#" onclick= "javascript:showMeta();" onfocus="javascript:showMeta();" style="outline: none;">Metadata</a>
                  <xsl:value-of select="' '"/>
                  <a href="#" onclick="javascript:showHelp();" onfocus="javascript:showHelp();" style="outline: none;">Documentation</a>

                 <xsl:if test="$messages_digest != ''">
                   <xsl:value-of select="' '"/>
                   <a href="{$messages_digest}" target="_blank">Messages Digest</a>
                 </xsl:if>

<form action="#" id="form1" style="margin-top: 10px;">

<xsl:if test="$show_tree='1'">
 <input type="button" id="btn_tree_expand_top" onclick="javascript:treeExpandAll();" value="Expand All"></input>
 <input type="button" id="btn_tree_collapse_top" onclick="javascript:treeCollapseAll();" value="Collapse All"></input>

 <div id="tree"> </div>

 <input type="button" id="btn_tree_expand_bottom" onclick="javascript:treeExpandAll();" value="Expand All"></input>
 <input type="button" id="btn_tree_collapse_bottom" onclick="javascript:treeCollapseAll();" value="Collapse All"></input>
 <input type="button" id="btn_sync_tree" onclick="javascript:syncTree();" value="Sync Tree"></input>
 <br/><br/>
</xsl:if>

<input type="button" id="btn_clear_input" onclick="javascript:clearInput();" value="Clear Input"></input>
<input type="button" id="btn_reset_form" onclick="javascript:resetForm();" value="Reset"></input>
<input type="button" id="btn_toggle_legend" onclick="javascript:toggleLegend();" value="Toggle Legend"></input>
<br/>

<input type="button" id="btn_show_all" onclick="javascript:showAll();" value="List All"></input>
<input type="button" id="btn_recall_last_selected" onclick="javascript:recallLastSelected();" value="Put"></input>
<input type="button" id="btn_recude_last_selected" onclick="javascript:reduceLastSelected();" value="Reduce"></input>
<input type="button" id="btn_use_leaf_last_selected" onclick="javascript:useLeafLastSelected();" value="Leaf"></input>

<p>Search for Message Pattern</p>
Typetag: <input class="focused" size="6" id="input0"></input>
<br/>
Direction: <select id="opt1" name="direction">
<option value="3">in+out</option>
<option value="1">in</option>
<option value="2">out</option></select> Refs: <select id="opt2" name="ref">
<option value="1">yes</option>
<option value="0">no</option>
<option value="2">only</option></select><br/>
<textarea class="focused" rows="1" cols="32" id="input1"/>
</form>

                </div>

                <div id="list" class="listDiv"/>

                <div>
                  <small>created with <a href="https://github.com/7890/oscdoc" target="_blank">oscdoc</a></small>
                </div>
              </td>
              <td style="vertical-align:top;padding-left:0px">


                <div id="desc" class="outputDiv"/>

                <!-- legend -->

                <div id="legend" class="legendDiv"/>

                <div id="legend_hidden" class="hidden_content">
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
                    <li><strong>s</strong>: string (limited in length)</li>
                    <li><strong>b</strong>: blob, arbitrary byte sequence (limited in length)</li>
                    <li><strong>t</strong>: timetag, seconds since Jan 1st 1900 in the UTC timezone + fractions expressed as 1/2^32nds of a second</li>
                    <li><strong>c</strong>: char, unsigned 8-bit char, decimal 0-255</li>
                    <li><strong>T</strong>: Symbol representing True</li>
                    <li><strong>F</strong>: Symbol representing False</li>
                    <li><strong>N</strong>: Symbol representing Nil</li>
                    <li><strong>I</strong>: Symbol representing Infinitum</li>
                    <li><strong>X</strong>: unknown / custom parameter type. arbitrary content</li>
                    <li><strong>_</strong>: last expressed param in typetag can occur 0 to n times</li>
                    <li><strong>*</strong>: anything (also: handled by reusable aspect)</li>
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

        <div id="help__" style="display: none;">
          <xsl:if test="doc">
            <xsl:copy-of select="doc/*"/>
          </xsl:if>
        </div>

        <div id="meta__" style="display: none;">
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
    <h3>Name</h3>
    <h4>
      <xsl:value-of select="name"/>
    </h4>
    <h3>URI (Unique Namespace for this Unit)</h3>
    <h4>
<span class="value">
      <xsl:value-of select="uri"/>
</span>
    </h4>
    <h3>Document Origin (oschmea Instance)</h3>
    <h4>
      <a href="{doc_origin}" target="_blank">
        <xsl:value-of select="doc_origin"/>
      </a>
    </h4>
    <xsl:apply-templates select="author"/>
    <xsl:apply-templates select="url"/>

    <xsl:apply-templates select="version"/>
    <xsl:apply-templates select="default_settings/conf"/>

    <xsl:call-template name="meta_aspects"/>
    <xsl:apply-templates select="desc"/>
    <xsl:apply-templates select="custom"/>
  </xsl:template>
  <!-- =========================== -->
  <xsl:template match="meta/author">
    <xsl:if test="position()=1">
      <h3>Authors</h3>
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
      <h3>URLs</h3>
    </xsl:if>
    <h4>
      <xsl:if test="@title">
      <xsl:value-of select="concat(@title,': ')"/>
      </xsl:if>

      <a href="{.}" target="_blank">
        <xsl:value-of select="."/>
      </a>
    </h4>
  </xsl:template>

  <!-- =========================== -->
  <xsl:template match="meta/version">
    <xsl:if test="position()=1">
      <h3>Versions</h3>
    </xsl:if>
    <h4>
      <xsl:value-of select="concat(@type,': ')"/>
        <span class="value">
          <xsl:value-of select="."/>
        </span>
    </h4>
  </xsl:template>

  <!-- =========================== -->
  <xsl:template match="meta/default_settings/conf">
    <xsl:if test="position()=1">
      <h3>Default Settings</h3>
    </xsl:if>
    <h4>
     <xsl:if test="@cmd_option">
      <xsl:value-of select="concat(@type,': ')"/>
        <span class="value">
          <xsl:value-of select="."/>
        </span>
      <xsl:value-of select="concat(' (cmd_option: &amp;apos;',@cmd_option,'&amp;apos;)')"/>
     </xsl:if>
  
    <xsl:if test="not(@cmd_option)">
      <xsl:value-of select="concat(@type,': ')"/>
        <span class="value">
          <xsl:value-of select="."/>
        </span>
     </xsl:if>
    </h4>
  </xsl:template>
  <!-- =============================== -->
  <xsl:template match="desc[.!='']">
    <xsl:if test="position()=1 ">
      <h2>Description</h2>
    </xsl:if>
    <ul>
       <li class="double">
         <xsl:value-of select="normalize-space(.)"/>
       </li>
    </ul>
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
  <!-- =========================== -->
  <xsl:template name="meta_aspects">
    <xsl:if test="$aspects_graph_tl != '' and $aspects_graph_svg != ''">
      <h3>Aspects Graph</h3>
         <a href="{$aspects_graph_svg}" target="_blank">
            <img src="{$aspects_graph_tl}" alt="Aspect Graph Image"/>
         </a>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
