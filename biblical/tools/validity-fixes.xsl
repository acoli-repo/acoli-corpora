<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<!-- ad hoc repairs for bibles from bibles.org, yields valid CES XML but may require manual checking afterwards
    - insert seg with @type="unknown" for free text in div
    - point to "global" cesDoc.dtd
    - remove empty div elements
-->
    
    <xsl:output method="xml" indent="yes" doctype-system="../../cesDoc.dtd"/>
    
    <xsl:template match="/|*|comment()">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:copy/>
           </xsl:for-each>
            <xsl:apply-templates/>
       </xsl:copy>
   </xsl:template>

    <!-- bibles.org: remove empty div elements -->
    <xsl:template match="div[count(*)=0][count(text()[string-length(normalize-space(string(.)))&gt;0])=0]"/>

    <!-- bibles.org: declare free CDATA content in <div> as <seg type="unknown"> -->
    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="name(..)='div' and normalize-space(string(.))!=''">
                <seg type="unknown">
                    <xsl:copy/>
               </seg>
           </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
           </xsl:otherwise>
       </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
