<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="html"/>

    <xsl:template match="/">
        <html lang="en-GB" xml:lang="en-GB" xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                <title>ACoLi Parallel Bible corpus</title>
                <link rel="root" href="http://universaldependencies.org/"/>
                <!-- for JS -->
                <link rel="stylesheet"
                    href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css"/>
                <link rel="stylesheet" type="text/css"
                    href="http://universaldependencies.org/css/jquery-ui-redmond.css"/>
                <link rel="stylesheet" type="text/css"
                    href="http://universaldependencies.org/css/style.css"/>
                <link rel="stylesheet" type="text/css"
                    href="http://universaldependencies.org/css/style-vis.css"/>
                <link rel="stylesheet" type="text/css"
                    href="http://universaldependencies.org/css/hint.css"/>
                <script type="text/javascript" src="http://universaldependencies.org/lib/ext/head.load.min.js"/>
                <script type="text/javascript" src="http://universaldependencies.org/lib/ext/jquery.timeago.js"/>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/3.2.2/anchor.min.js"/>
                <script>document.addEventListener("DOMContentLoaded", function(event) {anchors.add();});</script>
                <!--     <link rel="shortcut icon" href="favicon.ico"/> -->


            </head>
            <body>
                <div id="main" class="center">

                    <!--div id="hp-header">
	
          <span class="header-text"><a href="http://universaldependencies.org/#language-">home</a></span>

          <span class="header-text"><a href="https://github.com/universaldependencies/docs/edit/pages-source/index.md" target="#">edit page</a></span>
          <span class="header-text"><a href="https://github.com/universaldependencies/docs/issues">issue tracker</a></span>
      </div>

      <hr/-->

                    <div id="content">
                        <noscript>
                            <div id="noscript"> It appears that you have Javascript disabled. Please
                                consider enabling Javascript for this page to see the
                                visualizations. </div>
                        </noscript>

                        <h1 id="parallel-bibles">ACoLi Parallel Corpus of Biblical Text</h1>

                        <p>
                            <small> This is the online documentation of the ACoLi Parallel Corpus of
                                Biblical Text (under development). <br/>
                            
                            The corpus has been compiled from 2012-2015, and we are currently in the process of clearing the legal status of different individual texts. Redistributable texts will be published here. For non-distributable, but accessible texts, download and converter scripts are provided.</small>
                        </p>
                        
                        <ul>
                            <li> languages: 
                                <xsl:value-of select="count(//vol[not(@lang=preceding-sibling::vol/@lang)])"/> total, 
                                <xsl:value-of select="count(//vol[contains(@availability,'free')][not(@lang=preceding-sibling::vol[1]/@lang)])"/> with free texts, 
                                <xsl:value-of select="count(//vol[contains(@availability,'local')][not(@lang=preceding-sibling::vol[1]/@lang)])"/> with locally reproducible texts
                            </li>
                            <li> texts: 
                                <xsl:value-of select="count(//vol)"/> total, 
                                <xsl:value-of select="count(//vol[contains(@availability,'free')])"/> free, 
                                <xsl:value-of select="count(//vol[contains(@availability,'local')])"/> locally reproducible 
                                (may include duplicates)
                            </li>
                        </ul>
                        
                        <h1 id="individual-texts">Individual Texts</h1>

                        <div id="accordion" class="jquery-ui-accordion">
                            <!-- doesn't work yet -->
                            <xsl:for-each select="//vol">
                                <div data-lc="{@file}">
                                    <!--span class="flagspan">
                                        <img class="flag" src="flags/svg/GR.svg"/>
                                    </span-->
                                    <span class="widespan">
                                        <xsl:value-of select="@iso"/>
                                    </span>
                                    <span class="doublewidespan">
                                        <xsl:if
                                            test="string-length(normalize-space(@lang))&gt;0">
                                            <xsl:value-of select="@lang"/>
                                        </xsl:if>
                                    </span>
                                    <span class="doublewidespan">
                                        <xsl:attribute name="style">
                                            <xsl:choose>
                                                <xsl:when test="contains(@availability,'free')">background-color: GreenYellow; text-align: center</xsl:when>
                                                <xsl:when test="contains(@availability,'local')">background-color: yellow; text-align: center</xsl:when>
                                                <xsl:otherwise>background-color: red; text-align: center</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:value-of select="@availability"/>
                                    </span>
                                    <span class="widespan">
                                        <xsl:if test="string-length(@tok)&gt;0">
                                            <span class="hint--top hint--info" data-hint="tokens">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="@tok"/>
                                                <xsl:text> tok </xsl:text>
                                            </span>
                                        </xsl:if>
                                    </span>
                                    <span class="doublewidespan">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:choose>
                                                    <xsl:when test="contains(@file,'/language-table.xml#')">
                                                        <xsl:value-of select="substring-before(@file,'language-table.xml#')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="@file"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <xsl:choose>
                                                <xsl:when test="string-length(normalize-space(@title))&gt;0">
                                                    <xsl:value-of select="@title"/>
                                                    <xsl:if test="string-length(normalize-space(@date))&gt;0">
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:value-of select="@date"/>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="contains(@file,'#')">
                                                    <xsl:value-of select="substring-after(@file,'#')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@file"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </span>
                                    <!--span class="widespan">
                                        <span class="tagspan">
                                            <span class="hint- -top hint- -info" data-hint="Lemmas">
                                                <img class="propertylogo" src="logos/L.svg"/>
                                            </span>
                                        </span>
                                        <span class="tagspan">
                                            <span class="hint- -top hint- -info" data-hint="Features">
                                                <img class="propertylogo" src="logos/F.svg"/>
                                            </span>
                                        </span>
                                        <span class="tagspan"/>
                                    </span>
                                    <span class="widespan">
                                        <span class="hint- -top hint- -info"
                                            data-hint="Partial documentation">
                                            <i class="fa fa-file-o"/>
                                        </span>
                                    </span>
                                    <span class="widespan">
                                        <span class="hint- -top hint- -info"
                                            data-hint="Automatic conversion">
                                            <i class="fa fa-cogs"/>
                                        </span>
                                    </span>
                                    <span class="widespan">
                                        <span class="hint- -top hint- -info"
                                            data-hint="Scheduled for release in UD version 2.0 (spring 2017)">
                                            <i class="fa fa-hourglass-end"/>
                                        </span>
                                    </span>
                                    <span class="widespan">
                                        <span class="hint- -top hint- -info"
                                            data-hint="CC BY-NC-SA 2.5">
                                            <img class="license" src="logos/by-nc-sa.svg"/>
                                        </span>
                                    </span>
                                    <span class="doublewidespan">
                                        <span class="hint- -top hint- -info" data-hint="fiction">
                                            <span class="genreicon">
                                                <i class="fa fa-book"/>
                                            </span>
                                        </span>
                                    </span-->
                                </div>
                                <div>
                                    <span class="tagspan"/>
                                </div>
                                <!--div>
                                    <ul>
                                        <li>
                                            <a href="grc/overview/introduction.html"
                                                >Introduction</a>
                                        </li>
                                        <li>
                                            <a href="grc/overview/tokenization.html"
                                                >Tokenization</a>
                                        </li>
                                        <li>Morphology <ul>
                                                <li><a href="grc/overview/morphology.html">General
                                                  principles</a></li>
                                                <li><a href="grc/pos/index.html">Ancient_Greek POS
                                                  tags</a> (<a href="grc/pos/all.html">single
                                                  document</a>)</li>
                                                <li><a href="grc/feat/index.html">Ancient_Greek
                                                  features</a> (<a href="grc/feat/all.html">single
                                                  document</a>)</li>
                                            </ul>
                                        </li>
                                        <li>Syntax <ul>
                                                <li><a href="grc/overview/syntax.html">General
                                                  principles</a></li>
                                                <li><a href="grc/overview/specific-syntax.html"
                                                  >Specific constructions</a></li>
                                                <li><a href="grc/dep/index.html">Ancient_Greek
                                                  relations</a> (<a href="grc/dep/all.html">single
                                                  document</a>)</li>
                                            </ul>
                                        </li>
                                    </ul>

                                </div-->
                            </xsl:for-each>



                        </div>

                        <!--p>
                            <small>Disclaimer: Our use of flags to symbolise languages is only
                                intended as a visual enhancement of the website and should not be
                                interpreted as a political statement in any way.</small>
                        </p-->

                    </div>


                    <!-- support for embedded visualizations -->
                    <script type="text/javascript">
                        var root = 'http://universaldependencies.org/';
                        // filled in by jekyll
                        head.js(
                        // External libraries
                        root + 'lib/ext/jquery.min.js',
                        root + 'lib/ext/jquery.svg.min.js',
                        root + 'lib/ext/jquery.svgdom.min.js',
                        root + 'lib/ext/jquery.timeago.js',
                        root + 'lib/ext/jquery-ui.min.js',
                        root + 'lib/ext/waypoints.min.js',
                        root + 'lib/ext/jquery.address.min.js',
                        
                        // brat helper modules
                        root + 'lib/brat/configuration.js',
                        root + 'lib/brat/util.js',
                        root + 'lib/brat/annotation_log.js',
                        root + 'lib/ext/webfont.js',
                        // brat modules
                        root + 'lib/brat/dispatcher.js',
                        root + 'lib/brat/url_monitor.js',
                        root + 'lib/brat/visualizer.js',
                        
                        // embedding configuration
                        root + 'lib/local/config.js',
                        // project-specific collection data
                        root + 'lib/local/collections.js',
                        
                        // NOTE: non-local libraries
                        'https://spyysalo.github.io/annodoc/lib/local/annodoc.js',
                        'https://spyysalo.github.io/conllu.js/conllu.js');
                        
                        var webFontURLs =[
                        //        root + 'static/fonts/Astloch-Bold.ttf',
                        root + 'static/fonts/PT_Sans-Caption-Web-Regular.ttf',
                        root + 'static/fonts/Liberation_Sans-Regular.ttf'];
                        
                        var setupAccordions = function () {
                            // preserve state in URL hash, following in part
                            // http://www.boduch.ca/2011/05/remembering-jquery-ui-accordion.html
                            var accordionChange = function (event, ui) {
                                var context = ui.newHeader? ui.newHeader.context: null;
                                if (context) {
                                    var languageCode = context.getAttribute('data-lc');
                                    if (languageCode !== null) {
                                        window.location.hash = languageCode;
                                    }
                                }
                            }
                            // jQuery UI "accordion" element initialization
                            $(".jquery-ui-accordion").accordion({
                                collapsible: true,
                                active: false,
                                change: accordionChange
                            });
                            if ($(".jquery-ui-accordion").length) {
                                var matches = window.location.hash.match(/^\#(.*)$/);
                                console.log(matches);
                                if (matches !== null) {
                                    var languageCode = matches[1];
                                    var tab = $('[data-lc="' + languageCode + '"]');
                                    // the following will only work after accordion is initialized
                                    var index = $('.jquery-ui-accordion div.ui-accordion-header').index(tab);
                                    if (index !== - 1) {
                                        $(".jquery-ui-accordion").accordion({
                                            active: index
                                        });
                                    }
                                }
                            }
                        };
                        
                        var setupTimeago = function () {
                            jQuery("time.timeago").timeago();
                        };
                        
                        var setupTabs = function () {
                            // standard jQuery UI "tabs" element initialization
                            $(".jquery-ui-tabs").tabs({
                                heightStyle: "auto"
                            });
                            
                            // use jQuery address to preserve tab state
                            // (see https://github.com/UniversalDependencies/docs/issues/65,
                            // http://stackoverflow.com/a/3330919)
                            if ($(".jquery-ui-tabs").length > 0) {
                                $.address.change(function (event) {
                                    $(".jquery-ui-tabs").tabs("select", window.location.hash)
                                });
                                $(".jquery-ui-tabs").bind("tabsselect", function (event, ui) {
                                    window.location.hash = ui.tab.hash;
                                });
                            }
                        };
                        
                        head.ready(function () {
                            // set up UI tabs on page
                            setupTabs();
                            setupAccordions();
                            setupTimeago();
                            
                            // mark current collection (filled in by Jekyll)
                            Collections.listing[ '_current'] = '';
                            
                            // perform all embedding and support functions
                            Annodoc.activate(Config.bratCollData, Collections.listing);
                        });</script>


                    <!--div id="footer">
	  <p class="footer-text">&copy; 2014 
	    <a href="http://universaldependencies.org/introduction.html#contributors" style="color:gray">Universal Dependencies contributors</a>. 
	    Site powered by <a href="http://spyysalo.github.io/annodoc" style="color:gray">Annodoc</a> and <a href="http://brat.nlplab.org/" style="color:gray">brat</a></p>.
      </div-->
                </div>
            </body>
        </html>

    </xsl:template>

</xsl:stylesheet>
