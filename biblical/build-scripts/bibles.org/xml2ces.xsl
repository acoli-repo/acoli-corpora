<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" doctype-system="cesDoc.dtd" indent="yes" encoding="UTF-8"/>

    <xsl:template match="div[count(.//seg[1])=0]"/>

    <xsl:template match="div[@type='book']">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name()!='id'">
                    <xsl:copy/>
                </xsl:if>
            </xsl:for-each>
                <xsl:attribute name="id">
                    <xsl:call-template name="get-book-id"/>
                </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@type='chapter']">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:if test="name()!='id'">
                    <xsl:copy/>
                </xsl:if>
            </xsl:for-each>
                <xsl:attribute name="id">
                    <xsl:call-template name="get-book-id"/>
                    <xsl:text>.</xsl:text>
                    <xsl:call-template name="get-chapter"/>
                </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="seg[@type='verse']">
        <xsl:variable name="id" select="@id"/>
        <xsl:choose>
            <xsl:when test="string-length($id)&gt;0">
                <xsl:copy>
                    <xsl:for-each select="@*">
                        <xsl:if test="name()!='id'">
                            <xsl:copy/>
                        </xsl:if>
                    </xsl:for-each>
                        <xsl:attribute name="id">
                            <xsl:call-template name="get-book-id"/>
                            <xsl:text>.</xsl:text>
                            <xsl:call-template name="get-chapter"/>
                            <xsl:text>.</xsl:text>
                            <xsl:call-template name="get-verse"/>
                        </xsl:attribute>
                    <xsl:apply-templates/>
                    <!-- include text of following segs without ids --> 
                    <xsl:for-each select="./following-sibling::seg[@type='verse' and string-length(@id)=0]">
                        <xsl:if test="./preceding-sibling::seg[@type='verse' and string-length(@id)&gt;0][1]/@id=$id">
                            <xsl:apply-templates/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="count(./preceding-sibling::seg[@type='verse' and string-length(@id&gt;0)][1])=0">
                <!-- only when not mergeable with a preceding verse seg with id -->
                <xsl:copy>
                    <xsl:for-each select="@*">
                        <xsl:copy/>
                    </xsl:for-each>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise/> <!-- then merged with preceding verse seg --> 
        </xsl:choose>
    </xsl:template>

<xsl:template match="text()">
    <xsl:if test="string-length(normalize-space(.))&gt;0">
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="/|*|comment()">
    <xsl:copy>
        <xsl:for-each select="@*">
            <xsl:copy/>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:copy>
</xsl:template>

<xsl:template name="get-verse">
    <xsl:choose>
        <xsl:when test="@id=''">
            <xsl:for-each select=".//seg[@id!=''][1]">
                <xsl:call-template name="get-verse"/>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring-after(substring-after(@id,'.'),'.')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="get-chapter">
    <xsl:choose>
        <xsl:when test="name()='div' or @id=''">
            <xsl:for-each select=".//seg[@id!=''][1]">
                <xsl:call-template name="get-chapter"/>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring-before(substring-after(@id,'.'),'.')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- conversion to Resnik-conformant ids -->
<xsl:template name="get-book-id">
    <xsl:variable name="prefix" select="substring-before(@id,'.')"/>
    <xsl:choose>
        <xsl:when test="name()!='seg' or @id=''">
            <xsl:variable name="tmp">
                <xsl:for-each select=".//seg[@id!=''][1]">
                    <xsl:call-template name="get-book-id"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test=" string-length($tmp)&lt;6">
                    <xsl:value-of select="$tmp"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($tmp,1,5)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <!-- OT -->
        <xsl:when test="$prefix='Gen'">b.GEN</xsl:when>
        <xsl:when test="$prefix='Exod'">b.EXO</xsl:when>
        <xsl:when test="$prefix='Lev'">b.LEV</xsl:when>
        <xsl:when test="$prefix='Num'">b.NUM</xsl:when>
        <xsl:when test="$prefix='Deut'">b.DEU</xsl:when>
        <xsl:when test="$prefix='Josh'">b.JOS</xsl:when>
        <xsl:when test="$prefix='Judg'">b.JDG</xsl:when>
        <xsl:when test="$prefix='Ruth'">b.RUT</xsl:when>
        <xsl:when test="$prefix='1Sam'">b.1SA</xsl:when>
        <xsl:when test="$prefix='2Sam'">b.2SA</xsl:when>
        <xsl:when test="$prefix='1Kgs'">b.1KI</xsl:when>
        <xsl:when test="$prefix='2Kgs'">b.2KI</xsl:when>
        <xsl:when test="$prefix='1Chr'">b.1CH</xsl:when>
        <xsl:when test="$prefix='2Chr'">b.2CH</xsl:when>
        <xsl:when test="$prefix='Ezra'">b.EZR</xsl:when>
        <xsl:when test="$prefix='Neh'">b.NEH</xsl:when>
        <xsl:when test="$prefix='Esth'">b.EST</xsl:when>
        <xsl:when test="$prefix='Job'">b.JOB</xsl:when>
        <xsl:when test="$prefix='Ps'">b.PSA</xsl:when>
        <xsl:when test="$prefix='Prov'">b.PRO</xsl:when>
        <xsl:when test="$prefix='Eccl'">b.ECC</xsl:when>
        <xsl:when test="$prefix='Song'">b.SON</xsl:when>
        <xsl:when test="$prefix='Isa'">b.ISA</xsl:when>
        <xsl:when test="$prefix='Jer'">b.JER</xsl:when>
        <xsl:when test="$prefix='Lam'">b.LAM</xsl:when>
        <xsl:when test="$prefix='Ezek'">b.EZE</xsl:when>
        <xsl:when test="$prefix='Dan'">b.DAN</xsl:when>
        <xsl:when test="$prefix='Hos'">b.HOS</xsl:when>
        <xsl:when test="$prefix='Joel'">b.JOE</xsl:when>
        <xsl:when test="$prefix='Amos'">b.AMO</xsl:when>
        <xsl:when test="$prefix='Obad'">b.OMA</xsl:when>
        <xsl:when test="$prefix='Jonah'">b.JON</xsl:when>
        <xsl:when test="$prefix='Mic'">b.MIC</xsl:when>
        <xsl:when test="$prefix='Nah'">b.NAH</xsl:when>
        <xsl:when test="$prefix='Hab'">b.HAB</xsl:when>
        <xsl:when test="$prefix='Zeph'">b.ZEP</xsl:when>
        <xsl:when test="$prefix='Hag'">b.HAG</xsl:when>
        <xsl:when test="$prefix='Zech'">b.ZEC</xsl:when>
        <xsl:when test="$prefix='Mal'">b.MAL</xsl:when>
        
        <!-- NT -->
        <xsl:when test="$prefix='Matt'">b.MAT</xsl:when>
        <xsl:when test="$prefix='Mark'">b.MAR</xsl:when>
        <xsl:when test="$prefix='Luke'">b.LUK</xsl:when>
        <xsl:when test="$prefix='John'">b.JOH</xsl:when>
        <xsl:when test="$prefix='Acts'">b.ACT</xsl:when>
        <xsl:when test="$prefix='Rom'">b.ROM</xsl:when>
        <xsl:when test="$prefix='1Cor'">b.1CO</xsl:when>
        <xsl:when test="$prefix='2Cor'">b.2CO</xsl:when>
        <xsl:when test="$prefix='Gal'">b.GAL</xsl:when>
        <xsl:when test="$prefix='Eph'">b.EPH</xsl:when>
        <xsl:when test="$prefix='Phil'">b.PHI</xsl:when>
        <xsl:when test="$prefix='Col'">b.COL</xsl:when>
        <xsl:when test="$prefix='1Thess'">b.1TH</xsl:when>
        <xsl:when test="$prefix='2Thess'">b.2TH</xsl:when>
        <xsl:when test="$prefix='1Tim'">b.1TI</xsl:when>
        <xsl:when test="$prefix='2Tim'">b.2TI</xsl:when>
        <xsl:when test="$prefix='Titus'">b.TIT</xsl:when>
        <xsl:when test="$prefix='Phlm'">b.PHM</xsl:when>
        <xsl:when test="$prefix='Heb'">b.HEB</xsl:when>
        <xsl:when test="$prefix='Jas'">b.JAM</xsl:when>
        <xsl:when test="$prefix='1Pet'">b.1PE</xsl:when>
        <xsl:when test="$prefix='2Pet'">b.2PE</xsl:when>
        <xsl:when test="$prefix='1John'">b.1JO</xsl:when>
        <xsl:when test="$prefix='2John'">b.2JO</xsl:when>
        <xsl:when test="$prefix='3John'">b.3JO</xsl:when>
        <xsl:when test="$prefix='Jude'">b.JUD</xsl:when>
        <xsl:when test="$prefix='Rev'">b.REV</xsl:when>
        
        <!-- Apocrypha -->
        <xsl:when test="$prefix='Tob'">a.TOB</xsl:when>
        <xsl:when test="$prefix='Jdt'">a.JUD</xsl:when>
        <xsl:when test="$prefix='AddEsth'">a.EST</xsl:when>
        <xsl:when test="$prefix='Wis'">a.SOL</xsl:when>
        <xsl:when test="$prefix='Sir'">a.ECC</xsl:when>
        <xsl:when test="$prefix='Bar'">a.BAR</xsl:when>
        <xsl:when test="$prefix='PrAzar'">a.AZA</xsl:when>
        <xsl:when test="$prefix='Sus'">a.SUS</xsl:when>
        <xsl:when test="$prefix='Bel'">a.BEL</xsl:when>
        <xsl:when test="$prefix='1Macc'">a.1MC</xsl:when>
        <xsl:when test="$prefix='2Macc'">a.2MC</xsl:when>
        <xsl:when test="$prefix='3Macc'">a.3MC</xsl:when>
        <xsl:when test="$prefix='4Macc'">a.4MC</xsl:when>
        <xsl:when test="$prefix='1Esd'">a.1ES</xsl:when>
        <xsl:when test="$prefix='2Esd'">a.2ES</xsl:when>
        <xsl:when test="$prefix='PrMan'">a.MAN</xsl:when>
            <!-- 
                not identified yet
                    a.JER	73A	bib1jer	Epistle of Jeremiah
                    a.151	84A		Psalm 151
                    a.PSL	85A		Psalm of Solomon
                    a.ODE	86A		Odes
                    b.LAO = "Epistle_to_the_Laodiceans" (Vulgata Sacra), "a short compilation of verses from other Pauline epistles, principally Philippians
            --> 
        
        <xsl:otherwise>
            <xsl:message>warning: unknown bookid <xsl:value-of select="@prefix"/></xsl:message>
            <xsl:value-of select="$prefix"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
