<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:till="http://www.sitzextase.de"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xdt="http://www.w3.org/2005/02/xpath-datatypes"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <!-- last addition not documented: funcDateHY2G, funcDateMY2G -->

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
        <desc>
            <p> XSL stylesheet for date conversions in XML. </p>
            <p> The stylesheet currenly supports conversions between four calendars using a
                calculation of the Julian Day: Gregorian, Julian, Ottoman fiscal (Mālī), and Hijrī
                calendars. Many of the calculations were adapted from John Walker's Calender
                Converter JavaScript functions (http://www.fourmilab.ch/documents/calendar/). </p>
            <p>The names of the templates reflect their function through a simple ontology: G =
                Gregorian, J = Julian and Rūmī, M = Mālī, H = Hijrī, JD = Julian day. A template
                called funcDateG2JD will thus compute the Julian day (JD) for a Gregorian (G) date
                as input string.</p>
            <p>Input and output are formatted as yyyy-mm-dd for the conversions between the four
                currently supported calendars.</p>
            <p>Templates for the conversion between calendars: funcDateG2JD, funcDateJD2G,
                funcDateJ2JD, funcDateJD2J, funcDateH2JD, funcDateJD2H, funcDateG2J, funcDateG2H,
                funcDateJ2G, funcDateJ2H, funcDateH2J, funcDateJ2H, funcDateG2M, funcDateJ2M, funcDateHY2G, funcDateMY2G.</p>
            <p>Templates for converting Date formats: funcDateMonthNameNumber,
                funcDateNormaliseInput, and funcDateFormatTei.</p>
            <p>The funcDateFormatTei template accepts the same input, but produces a tei:date node
                as output with the relevant @when or @when, @when-custom, @calendar, and
                @datingMethod attributes.</p>
            <p>The funcDateNormaliseInput template can be used to convert variously formatted input
                strings to the yyyy-mm-dd required by other templates. Possible input formats are
                the common English formats of 'dd(.) MNn(.) yyyy', 'MNn(.) dd(.), yyyy', i.e. '15
                Shaʿbān 1324' or 'Jan. 15, 2014'. The template requires an input string and a
                calendar-language combination as found in funcDateMonthNameNumber. </p>
            <p> Abbreviavtions in the funcDateMonthNameNumber try to cut the Month names to three
                letters, as is established practice for English. In case of Arabic letters whose
                transcription requires two Latin letters, month names can be longer than three
                Latin letters, i.e. Shub (for Shubāṭ), Tish (for Tishrīn), etc. </p>
            <p>Templates for incrementing dates between a start and stop date: funcDateIncrementAnnually, funcDateIncrementJD. Both produce a list of comma-separated values.</p>
            <p>funcDateBoa ingests the date strings found in the BOA online catalogue</p>
            <p>v1a: the tokenize() function to split up input strings was improved with the regex
                '([.,&quot;\-])' instead of just '-', which means, that the templates could deal
                with yyyy,mm,dd in put etc.</p>
            <p>v1a: new funcDateNormaliseInput template.</p>
            <p>v1a: new funcDateM2J</p>
            <p>v1b: corrected an error in funcDateG2JD which resulted in erroneous computation of Gregorian dates in funcDateJD2G that were off by one day for March-December in leap years.</p>
            <p>Added the function funcDateIncrementJD</p>
            <p>This software is licensed as: Distributed under a Creative Commons
                Attribution-ShareAlike 3.0 Unported License
                http://creativecommons.org/licenses/by-sa/3.0/ All rights reserved. Redistribution
                and use in source and binary forms, with or without modification, are permitted
                provided that the following conditions are met: * Redistributions of source code
                must retain the above copyright notice, this list of conditions and the following
                disclaimer. * Redistributions in binary form must reproduce the above copyright
                notice, this list of conditions and the following disclaimer in the documentation
                and/or other materials provided with the distribution. This software is provided by
                the copyright holders and contributors "as is" and any express or implied
                warranties, including, but not limited to, the implied warranties of merchantability
                and fitness for a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental, special,
                exemplary, or consequential damages (including, but not limited to, procurement of
                substitute goods or services; loss of use, data, or profits; or business
                interruption) however caused and on any theory of liability, whether in contract,
                strict liability, or tort (including negligence or otherwise) arising in any way out
                of the use of this software, even if advised of the possibility of such damage. </p>
            <p>Author: Till Grallert</p>
        </desc>
    </doc>

    <!-- v1b: Julian day was one too few! -->
    <!-- Julian day for Gregorian 0001-01-01 -->
    <xsl:variable name="vgJDGreg1" select="1721425.5"/>
    <!-- Julian day for Hijri 0001-01-01 -->
    <xsl:variable name="vgJDHijri1" select="1948439.5"/>

    <!-- This template determines whether Gregorian years are leap years. Returns y or n -->
    <xsl:template name="funcDateLeapG">
        <xsl:param name="pDateG"/>
        <xsl:param name="pYearG" select="number(tokenize($pDateG,'([.,&quot;\-])')[1])"/>
        <!-- determines wether the year is a leap year: can be divided by four, but in centesial years divided by 400 -->
        <xsl:value-of
            select="if(($pYearG mod 4)=0 and (not((($pYearG mod 100)=0) and (not(($pYearG mod 400)=0)))))  then('y') else('n')"
        />
    </xsl:template>

    <!-- This template converts Gregorian to Julian Day -->
    <xsl:template name="funcDateG2JD">
        <xsl:param name="pDateG"/>
        <xsl:param name="vYear" select="number(tokenize($pDateG,'([.,&quot;\-])')[1])"/>
        <xsl:param name="vMonth" select="number(tokenize($pDateG,'([.,&quot;\-])')[2])"/>
        <xsl:param name="vDay" select="number(tokenize($pDateG,'([.,&quot;\-])')[3])"/>

        <!-- vLeap indicates when a year is a leap year -->
        <!-- v1b: here was the error for all the havoc in leap years!  -->
        <xsl:variable name="vLeapG">
            <xsl:call-template name="funcDateLeapG">
                <xsl:with-param name="pDateG" select="concat($vYear,'-',$vMonth,'-',$vDay)"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- v1b: vgJDGreg1 had been one too few -->
        <xsl:variable name="vA" select="(((367 * $vMonth) -362) div 12)"/>
        <xsl:variable name="vB"
            select="(if($vMonth &lt;=2) then(0) else (if($vLeapG='y') then(-1) else(-2)))"/>
        <xsl:variable name="vDayCurrentYear" select="floor($vA + $vB + $vDay)"/>
        <xsl:variable name="vC" select="$vYear -1"/>
        <xsl:variable name="vJDCurrentYear"
            select="($vgJDGreg1 -1)
            +(365 * $vC)
            + floor($vC div 4)
            -floor($vC div 100)
            +floor($vC div 400)"/>
        <xsl:value-of select="$vJDCurrentYear + $vDayCurrentYear"/>

        <!-- <xsl:value-of
            select="($vJDGreg0 -1)
            +(365 * ($vYear -1))
            + floor(($vYear -1) div 4)
            -floor(($vYear -1) div 100)
            +floor(($vYear -1) div 400)
            +floor((((367 * $vMonth) -362) div 12)
            + (if($vMonth &lt;=2) then(0) else (if($vLeapG='n') then(-1) else(-2)))
            + $vDay)"/> -->

        <!-- function gregorian_to_jd(year, month, day)
        {
        return (GREGORIAN_EPOCH - 1) +
        (365 * (year - 1)) +
        Math.floor((year - 1) / 4) +
        (-Math.floor((year - 1) / 100)) +
        Math.floor((year - 1) / 400) +
        Math.floor((((367 * month) - 362) / 12) +
        ((month <= 2) ? 0 :
        (leap_gregorian(year) ? -1 : -2)
        ) +
        day);
        } -->
    </xsl:template>

    <!-- This template converts Julian Day to Gregorian -->
    <xsl:template name="funcDateJD2G">
        <xsl:param name="pJD"/>

        <xsl:variable name="vWjd" select="floor($pJD - 0.5) + 0.5"/>
        <xsl:variable name="vDepoch" select="$vWjd - $vgJDGreg1"/>
        <xsl:variable name="vQuadricent" select="floor($vDepoch div 146097)"/>
        <xsl:variable name="vDqc" select="$vDepoch mod 146097"/>
        <xsl:variable name="vCent" select="floor($vDqc div 36524)"/>
        <xsl:variable name="vDcent" select="$vDqc mod 36524"/>
        <xsl:variable name="vQuad" select="floor($vDcent div 1461)"/>
        <xsl:variable name="vDquad" select="$vDcent mod 1461"/>
        <xsl:variable name="vYindex" select="floor($vDquad div 365)"/>
        <!-- year is correctly calculated -->
        <xsl:variable name="vYearG"
            select="if(not(($vCent = 4) or ($vYindex =4))) then ((($vQuadricent * 400) + ($vCent * 100) + ($vQuad * 4) + $vYindex)+1) else(($vQuadricent * 400) + ($vCent * 100) + ($vQuad * 4) + $vYindex)"/>
        <xsl:variable name="vYearG2JD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="vYear" select="$vYearG"/>
                <xsl:with-param name="vMonth" select="1"/>
                <xsl:with-param name="vDay" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vYearday" select="$vWjd - $vYearG2JD"/>
        <!-- leap years are correctly indicated -->
        <xsl:variable name="vLeapG">
            <xsl:call-template name="funcDateLeapG">
                <xsl:with-param name="pYearG" select="$vYearG"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vMonthG2JD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="vYear" select="$vYearG"/>
                <xsl:with-param name="vMonth" select="3"/>
                <xsl:with-param name="vDay" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vLeapadj">
            <xsl:choose>
                <xsl:when test="$vWjd &lt; $vMonthG2JD">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$vLeapG='y'">
                        <xsl:value-of select="1"/>
                    </xsl:if>
                    <xsl:if test="$vLeapG='n'">
                        <xsl:value-of select="2"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vMonthG" select="floor(((($vYearday + $vLeapadj) * 12) + 373) div 367)"/>
        <xsl:variable name="vDayG2JD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="vYear" select="$vYearG"/>
                <xsl:with-param name="vMonth" select="$vMonthG"/>
                <xsl:with-param name="vDay" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- v1b: $vWjd - $vDayG2JD should be zero for the first of the month, yet, it was not for Mar-Dec in leap years, due to an error in funcDateG2JD -->
        <xsl:variable name="vDayG" select="($vWjd - $vDayG2JD) + 1"/>
        <!--<xsl:variable name="vDayG">
            <xsl:choose>
                <xsl:when test="$vLeapG = 'n'">
                    <xsl:value-of select="($vWjd - $vDayG2JD) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <!-\- days prior to 1 March -\->
                        <xsl:when test="$vMonthG &lt;= 2">
                            <xsl:value-of select="($vWjd - $vDayG2JD) + 1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="($vWjd - $vDayG2JD)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->

        <xsl:value-of
            select="concat($vYearG,'-',format-number($vMonthG,'00'),'-',format-number($vDayG,'00'))"
        />
        
        <!-- function jd_to_gregorian(jd) {
    var wjd, depoch, quadricent, dqc, cent, dcent, quad, dquad,
        yindex, dyindex, year, yearday, leapadj;
        
    wjd = Math.floor(jd - 0.5) + 0.5;
    depoch = wjd - GREGORIAN_EPOCH;
    quadricent = Math.floor(depoch / 146097);
    dqc = mod(depoch, 146097);
    cent = Math.floor(dqc / 36524);
    dcent = mod(dqc, 36524);
    quad = Math.floor(dcent / 1461);
    dquad = mod(dcent, 1461);
    yindex = Math.floor(dquad / 365);
    year = (quadricent * 400) + (cent * 100) + (quad * 4) + yindex;
    if (!((cent == 4) || (yindex == 4))) {
        year++;
    }
    yearday = wjd - gregorian_to_jd(year, 1, 1);
    leapadj = ((wjd < gregorian_to_jd(year, 3, 1)) ? 0
                                                  :
                  (leap_gregorian(year) ? 1 : 2)
              );
    month = Math.floor((((yearday + leapadj) * 12) + 373) / 367);
    day = (wjd - gregorian_to_jd(year, month, 1)) + 1;
    
    return new Array(year, month, day);
} -->
    </xsl:template>

    <!-- This template converts Hijrī to Julian Day -->
    <xsl:template name="funcDateH2JD">
        <xsl:param name="pDateH"/>
        <xsl:param name="vYear" select="number(tokenize($pDateH,'([.,&quot;\-])')[1])"/>
        <xsl:param name="vMonth" select="number(tokenize($pDateH,'([.,&quot;\-])')[2])"/>
        <xsl:param name="vDay" select="number(tokenize($pDateH,'([.,&quot;\-])')[3])"/>

        <xsl:value-of
            select="($vDay
            + ceiling(29.5 * ($vMonth -1))
            + ($vYear -1) * 354
            + floor((3 + (11 * $vYear)) div 30)
            + $vgJDHijri1 -1
            )"/>

        <!-- function islamic_to_jd(year, month, day)
        {
        return (day +
        Math.ceil(29.5 * (month - 1)) +
        (year - 1) * 354 +
        Math.floor((3 + (11 * year)) / 30) +
        ISLAMIC_EPOCH) - 1;
        } -->
    </xsl:template>

    <!-- This template converts Julian Day to Hijrī -->
    <xsl:template name="funcDateJD2H">
        <xsl:param name="pJD"/>

        <xsl:variable name="vJD" select="floor($pJD) + 0.5"/>
        <xsl:variable name="vYearH" select="floor(((30* ($vJD - $vgJDHijri1)) + 10646) div 10631)"/>
        <xsl:variable name="vMonthH2JD">
            <xsl:call-template name="funcDateH2JD">
                <xsl:with-param name="vYear" select="$vYearH"/>
                <xsl:with-param name="vMonth" select="1"/>
                <xsl:with-param name="vDay" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- v2b: this was incomplete
        <xsl:variable name="vMonthH" select="ceiling(($vJD - (29 + $vMonthH2JD)) div 29.5)+1"/>
        -->
        <xsl:variable name="vMonthH"
            select=" min((12,ceiling(($vJD - (29 + $vMonthH2JD)) div 29.5)+1))"/>
        <xsl:variable name="vDayH2JD">
            <xsl:call-template name="funcDateH2JD">
                <xsl:with-param name="vYear" select="$vYearH"/>
                <xsl:with-param name="vMonth" select="$vMonthH"/>
                <xsl:with-param name="vDay" select="1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDayH" select="($vJD - $vDayH2JD)+1"/>

        <xsl:value-of
            select="concat($vYearH,'-',format-number($vMonthH,'00'),'-',format-number($vDayH,'00'))"/>

        <!--  function jd_to_islamic(jd)
        {
        var year, month, day;
        
        jd = Math.floor(jd) + 0.5;
        year = Math.floor(((30 * (jd - ISLAMIC_EPOCH)) + 10646) / 10631);
        month = Math.min(12,
        Math.ceil((jd - (29 + islamic_to_jd(year, 1, 1))) / 29.5) + 1);
        day = (jd - islamic_to_jd(year, month, 1)) + 1;
        return new Array(year, month, day);
        } -->
    </xsl:template>

    <!-- This template converts Gregorian to Hijrī -->
    <xsl:template name="funcDateG2H">
        <xsl:param name="pDateG" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="pDateG" select="$pDateG"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateH">
            <xsl:call-template name="funcDateJD2H">
                <xsl:with-param name="pJD" select="$vJD"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateH"/>
    </xsl:template>
    
    <!-- this template converts Hijrī to Gregorian dates -->
    <xsl:template name="funcDateH2G">
        <xsl:param name="pDateH" select="'1434-6-12'"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateH2JD">
                <xsl:with-param name="pDateH" select="$pDateH"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateG">
            <xsl:call-template name="funcDateJD2G">
                <xsl:with-param name="pJD" select="$vJD"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateG"/>
    </xsl:template>
    
    <!-- this template converts Hijrī Years to Gregorian year ranges -->
    <xsl:template name="funcDateHY2G">
        <xsl:param name="pYearH" select="'1434'"/>
        <xsl:variable name="vDateH1"
            select="concat($pYearH,'-01-01')"/>
        <xsl:variable name="vDateG1">
            <xsl:call-template name="funcDateH2G">
                <xsl:with-param name="pDateH" select="$vDateH1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateH2"
            select="concat($pYearH,'-12-29')"/>
        <xsl:variable name="vDateG2">
            <xsl:call-template name="funcDateH2G">
                <xsl:with-param name="pDateH" select="$vDateH2"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="substring($vDateG1,1,4)"/>
        <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
        <xsl:if
            test="substring($vDateG1,1,4)!=substring($vDateG2,1,4)">
            <xsl:text>-</xsl:text>
            <xsl:choose>
                <!-- the range 1899-1900 must be accounted for -->
                <xsl:when test="substring($vDateG2,3,2)='00'">
                    <xsl:value-of select="substring($vDateG2,1,4)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($vDateG2,3,2)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- this template converts Gregorian to Mali dates (i.e. Julian, commencing on 1 Mar, minus 584 years from 13 March 1840 onwards)  -->
    <!-- this conversion employs a chain of conversions from Gregorian to Julian to Mālī -->
    <xsl:template name="funcDateG2M">
        <xsl:param name="pDateG"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="pDateG" select="$pDateG"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateJ">
            <xsl:call-template name="funcDateG2J">
                <xsl:with-param name="pDateG" select="$pDateG"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateM">
            <xsl:call-template name="funcDateJ2M">
                <xsl:with-param name="pDateJ" select="$vDateJ"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateM"/>
    </xsl:template>

    <!-- v2e -->
    <!-- convert Julian Day to Julian / Rūmī. Everything works correctly -->
    <xsl:template name="funcDateJD2J">
        <xsl:param name="pJD"/>
        <xsl:variable name="vZ" select="floor($pJD + 0.5)"/>
        <xsl:variable name="vB" select="$vZ + 1524"/>
        <xsl:variable name="vC" select="floor(($vB - 122.1) div 365.25)"/>
        <xsl:variable name="vD" select="floor(365.25 * $vC)"/>
        <xsl:variable name="vE" select="floor(($vB - $vD) div 30.6001)"/>
        <xsl:variable name="vMonth" select="floor(if($vE lt 14) then($vE - 1) else ($vE -13))"/>
        <xsl:variable name="vYear"
            select="floor(if($vMonth gt 2) then($vC - 4716) else($vC - 4715))"/>
        <xsl:variable name="vDay" select="($vB - $vD) - floor(30.6001 * $vE)"/>
        <xsl:value-of
            select="concat($vYear,'-',format-number($vMonth,'00'),'-',format-number($vDay,'00'))"/>

        <!-- function jd_to_julian(td) {
    var z, a, alpha, b, c, d, e, year, month, day;
    
    td += 0.5;
    z = Math.floor(td);
    
    a = z;
    b = a + 1524;
    c = Math.floor((b - 122.1) / 365.25);
    d = Math.floor(365.25 * c);
    e = Math.floor((b - d) / 30.6001);
    
    month = Math.floor((e < 14) ? (e - 1) : (e - 13));
    year = Math.floor((month > 2) ? (c - 4716) : (c - 4715));
    day = b - d - Math.floor(30.6001 * e);
    
    
    return new Array(year, month, day);
} -->
    </xsl:template>

    <!-- convert Julian / Rūmī to Julian Day -->
    <xsl:template name="funcDateJ2JD">
        <xsl:param name="pDateJ"/>
        <xsl:variable name="vYearJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[1])"/>
        <xsl:variable name="vMonthJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[2])"/>
        <xsl:variable name="vDayJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[3])"/>

        <xsl:variable name="vYearJ1" select="if($vMonthJ &lt;= 2) then($vYearJ -1) else($vYearJ)"/>
        <xsl:variable name="vMonthJ1"
            select="if($vMonthJ &lt;= 2) then($vMonthJ +12) else($vMonthJ)"/>
        <xsl:variable name="vJD"
            select="floor(365.25 * ($vYearJ1 + 4716)) + floor(30.6001 * ($vMonthJ1 + 1)) + $vDayJ - 1524.5"/>
        <xsl:value-of select="$vJD"/>

        <!-- function julian_to_jd(year, month, day)
{

    /* Adjust negative common era years to the zero-based notation we use.  */
    
    if (year < 1) {
        year++;
    }
    
    /* Algorithm as given in Meeus, Astronomical Algorithms, Chapter 7, page 61 */
    
    if (month <= 2) {
        year -=1;
        month += 12;
    }
    
    return ((Math.floor((365.25 * (year + 4716))) +
            Math.floor((30.6001 * (month + 1))) +
            day) - 1524.5);
} -->

    </xsl:template>

    <!-- convert Gregorian to Julian / Rūmī dates -->
    <xsl:template name="funcDateG2J">
        <xsl:param name="pDateG" select="'1900-01-01'"/>
        <!-- at the moment the julian day is wrong! Leap years are correctly computed -->
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateG2JD">
                <xsl:with-param name="pDateG" select="$pDateG"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateJ">
            <xsl:call-template name="funcDateJD2J">
                <xsl:with-param name="pJD" select="$vJD"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateJ"/>
    </xsl:template>

    <!-- convert Hijri to Julian / Rūmī dates -->
    <xsl:template name="funcDateH2J">
        <xsl:param name="pDateH" select="'1317-08-28'"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateH2JD">
                <xsl:with-param name="pDateH" select="$pDateH"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateJ">
            <xsl:call-template name="funcDateJD2J">
                <xsl:with-param name="pJD" select="$vJD"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateJ"/>
    </xsl:template>

    <!-- convert Julian / Rūmī to Hijrī dates -->
    <xsl:template name="funcDateJ2H">
        <xsl:param name="pDateJ" select="'1898-08-28'"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateJ2JD">
                <xsl:with-param name="pDateJ" select="$pDateJ"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateH">
            <xsl:call-template name="funcDateJD2H">
                <xsl:with-param name="pJD" select="$vJD"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateH"/>
    </xsl:template>

    <!-- convert Julian / Rūmī dates to Gregorian dates -->
    <xsl:template name="funcDateJ2G">
        <xsl:param name="pDateJ"/>
        <xsl:variable name="vJD">
            <xsl:call-template name="funcDateJ2JD">
                <xsl:with-param name="pDateJ" select="$pDateJ"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="funcDateJD2G">
            <xsl:with-param name="pJD" select="$vJD"/>
        </xsl:call-template>
    </xsl:template>

    <!-- convert Julian/ Rūmī dates to Mālī dates -->
    <xsl:template name="funcDateJ2M">
        <!-- Mālī is an old Julian calendar that begins on 1 March of the Julian year introduced in 1676. The year count was synchronised with the Hijri calendar until 1872 G -->
        <xsl:param name="pDateJ"/>
        <xsl:variable name="vYearJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[1])"/>
        <xsl:variable name="vMonthJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[2])"/>
        <xsl:variable name="vDayJ" select="number(tokenize($pDateJ,'([.,&quot;\-])')[3])"/>
        <!-- vMontM computes the months as staring with March -->
        <xsl:variable name="vMonthM"
            select="if($vMonthJ &lt;=2) then($vMonthJ +10) else($vMonthJ -2)"/>
        <!-- vYearOS computes old Julian years beginning on 1 March -->
        <xsl:variable name="vYearOS" select="if($vMonthJ &lt;=2) then($vYearJ -1) else($vYearJ)"/>
        <!-- Every 33 lunar years the Hjrī year completes within a single Mālī year. In this case a year was dropped from the Mālī counting ( 1121, 1154, 1188, 1222, and 1255). due to a printing error, Mālī and Hjrī years were not synchronised in on 1872-03-01 G to 1289 M and the synchronisation was dropped for ever. According to Deny 1921, the OE retrospectively established a new solar era with 1 Mārt 1256 (13 Mar 1840) -->
        <xsl:variable name="vYearM">
            <xsl:variable name="vDateH">
                <xsl:call-template name="funcDateJ2H">
                    <xsl:with-param name="pDateJ" select="$pDateJ"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="vYearH" select="number(tokenize($vDateH,'([.,&quot;\-])')[1])"/>
            <xsl:choose>
                <xsl:when test="$vYearH &lt;= 1255">
                    <xsl:choose>
                        <xsl:when test="$vYearH &lt;= 1222">
                            <xsl:choose>
                                <xsl:when test="$vYearH &lt;= 1188">
                                    <xsl:choose>
                                        <xsl:when test="$vYearH &lt;= 1154">
                                            <xsl:choose>
                                                <xsl:when test="$vYearH &lt;= 1121">
                                                  <xsl:value-of select="$vYearOS -589"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="$vYearOS -588"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$vYearOS -587"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$vYearOS -586"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$vYearOS -585"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!--<xsl:when test="$vYearJM &lt;= 1839">
                    <xsl:choose>
                        <xsl:when test="$vYearJM &lt;= 1806">
                            <!-\- as I am not computing any values prior to the 19th century, this condition is enough -\->
                            <xsl:value-of select="$vYearJM -586"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$vYearJM -585"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>-->
                <xsl:otherwise>
                    <xsl:value-of select="$vYearOS -584"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- this variable computes the Hijrī date for the 1 Mar of $vYearJ. As the lunar year is 354.37 solar days long, it is 11 to 12 days short than the solar year. If 1 Muḥ falls between 1 Mar J and 12 Mar J, the years should be synchronised. But computation is more complicated than empirically established differences between the calendars -->

        <!--<xsl:variable name="vYearM2">
            
            <!-\- Julian day for the 1 Mar of the current Mālī year ( -\->
            <xsl:variable name="vJDJ1March">
                <xsl:call-template name="funcDateJ2JD">
                    <xsl:with-param name="pDateJ" select="concat($vYearJ,'-03-01')"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!-\- calculate the Hijrī date for 1 Mar of current Mālī year -\->
            <xsl:variable name="vDateH1March">
                <xsl:call-template name="funcDateJD2H">
                    <xsl:with-param name="pJD" select="$vJDJ1March"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="vYearH1March" select="number(tokenize($vDateH1March,'([.,&quot;\-])')[1])"/>
            
            <!-\- Julian day for the 1 Muḥarram of the year beginning after 1 Mar of the current Mālī year. -\->
            <xsl:variable name="vJDH1Muharram">
                <xsl:call-template name="funcDateH2JD">
                    <xsl:with-param name="pDateH" select="concat($vYearH1March +1,'-01-01')"/>
                </xsl:call-template>
            </xsl:variable>
            <!-\- check whether the difference between the Julian days is less than 12 days -\->
            <xsl:choose>
                <xsl:when test="$vJDH1Muharram - $vJDJ1March &lt; 12">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$vYearH1March"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vYearM" select="if($vMonthJ &lt;=2) then($vYearM2 -1) else($vYearM2)"/>-->


        <!-- in 1917 Mālī was synchronised to the Gregorian calendar in two steps: 1333-01-01 M was established as 1917-03-01 and 1334-01-01 was synchronised to 1918-01-01. Yet, despite the alignement of numerical values, the month names, of course, remained untouched: 1334-01-01 was 1 Kan I 1334 and not 1 Mārt 1334 -->
        <!-- the current iteration is not correct for the first 13 days of 1333 / last 13 days of 1332 -->
        <xsl:choose>
            <xsl:when test="$vYearM &lt; 1333">
                <xsl:value-of
                    select="concat($vYearM,'-',format-number($vMonthM,'00'),'-',format-number($vDayJ,'00'))"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- function to convert Julian to Gregorian is needed here -->
                <xsl:variable name="vDateG">
                    <xsl:call-template name="funcDateJ2G">
                        <xsl:with-param name="pDateJ" select="$pDateJ"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$vYearJ &gt;= 1918">
                        <xsl:value-of
                            select="concat($vYearJ - 584,'-',format-number(number(tokenize($vDateG,'([.,&quot;\-])')[2]),'00'),'-',format-number(number(tokenize($vDateG,'([.,&quot;\-])')[3]),'00'))"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="concat($vYearM,'-',format-number(number(tokenize($vDateG,'([.,&quot;\-])')[2])-2,'00'),'-',format-number(number(tokenize($vDateG,'([.,&quot;\-])')[3]),'00'))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- convert Mālī dates to Julian/ Rūmī dates -->
    <xsl:template name="funcDateM2J">
        <!-- Mālī is an old Julian calendar that begins on 1 March of the Julian year introduced in 1676. The year count was synchronised with the Hijri calendar until 1872 G -->
        <xsl:param name="pDateM"/>
        <xsl:variable name="vYearM" select="number(tokenize($pDateM,'([.,&quot;\-])')[1])"/>
        <xsl:variable name="vMonthM" select="number(tokenize($pDateM,'([.,&quot;\-])')[2])"/>
        <xsl:variable name="vDayM" select="number(tokenize($pDateM,'([.,&quot;\-])')[3])"/>
        <!-- vMonthJ computes the months as staring with January -->
        <xsl:variable name="vMonthJ"
            select="if($vMonthM &lt;=10) then($vMonthM +2) else($vMonthM -10)"/>
        <!-- vYearNS computes Julian years beginning on 1 January -->
        <xsl:variable name="vYearNS" select="if($vMonthM &lt;=10) then($vYearM) else($vYearM +1)"/>
        <!-- Every 33 lunar years the Hjrī year completes within a single Mālī year. In this case a year was dropped from the Mālī counting ( 1121, 1154, 1188, 1222, and 1255). due to a printing error, Mālī and Hjrī years were not synchronised in on 1872-03-01 G to 1289 M and the synchronisation was dropped for ever. According to Deny 1921, the OE retrospectively established a new solar era with 1 Mārt 1256 (13 Mar 1840) -->
        <xsl:variable name="vYearJ">
           <!-- <xsl:variable name="vDateH">
                <xsl:call-template name="funcDateJ2H">
                    <xsl:with-param name="pDateJ" select="$pDateJ"/>
                </xsl:call-template>
            </xsl:variable>-->
            <!--<xsl:variable name="vYearH" select="number(tokenize($vDateH,'([.,&quot;\-])')[1])"/>-->
            <xsl:choose>
                <xsl:when test="$vYearM &lt;= 1255">
                    <xsl:choose>
                        <xsl:when test="$vYearM &lt;= 1222">
                            <xsl:choose>
                                <xsl:when test="$vYearM &lt;= 1188">
                                    <xsl:choose>
                                        <xsl:when test="$vYearM &lt;= 1154">
                                            <xsl:choose>
                                                <xsl:when test="$vYearM &lt;= 1121">
                                                    <xsl:value-of select="$vYearNS +589"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$vYearNS +588"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$vYearNS +587"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$vYearNS +586"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$vYearNS +585"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$vYearNS +584"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
        <!-- in 1917 Mālī was synchronised to the Gregorian calendar in two steps: 1333-01-01 M was established as 1917-03-01 and 1334-01-01 was synchronised to 1918-01-01. Yet, despite the alignement of numerical values, the month names, of course, remained untouched: 1334-01-01 was 1 Kan I 1334 and not 1 Mārt 1334 -->
        <!-- the current iteration is not correct for the first 13 days of 1333 / last 13 days of 1332 -->
        <xsl:choose>
            <xsl:when test="$vYearM &lt; 1333">
                <xsl:value-of
                    select="concat($vYearJ,'-',format-number($vMonthJ,'00'),'-',format-number($vDayM,'00'))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$vYearM &gt;= 1334">
                        <xsl:variable name="vDateJ">
                            <xsl:call-template name="funcDateG2J">
                                <xsl:with-param name="pDateG" select="concat($vYearJ,'-',$vMonthM,'-',$vDayM)"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of
                            select="concat($vYearM + 584,'-',format-number(number(tokenize($vDateJ,'([.,&quot;\-])')[2]),'00'),'-',format-number(number(tokenize($vDateJ,'([.,&quot;\-])')[3]),'00'))"
                        />
                    </xsl:when>
                    <!-- works correctly -->
                    <xsl:otherwise>
                        <xsl:variable name="vDateJ">
                            <xsl:call-template name="funcDateG2J">
                                <xsl:with-param name="pDateG" select="concat($vYearJ,'-',$vMonthM +2,'-',$vDayM)"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of
                            select="concat($vYearJ,'-',format-number(number(tokenize($vDateJ,'([.,&quot;\-])')[2]),'00'),'-',format-number(number(tokenize($vDateJ,'([.,&quot;\-])')[3]),'00'))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- convert Mālī to Gregorian -->
    <xsl:template name="funcDateM2G">
        <xsl:param name="pDateM"/>
        <xsl:variable name="vDateJ">
            <xsl:call-template name="funcDateM2J">
                <xsl:with-param name="pDateM" select="$pDateM"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateG">
            <xsl:call-template name="funcDateJ2G">
                <xsl:with-param name="pDateJ" select="$vDateJ"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateG"/>
    </xsl:template>
    <!-- this template converts Mali Years to Gregorian year ranges -->
    <xsl:template name="funcDateMY2G">
        <xsl:param name="pYearM" select="'1434'"/>
        <xsl:variable name="vDateM1"
            select="concat($pYearM,'-01-01')"/>
        <xsl:variable name="vDateG1">
            <xsl:call-template name="funcDateM2G">
                <xsl:with-param name="pDateM" select="$vDateM1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateM2"
            select="concat($pYearM,'-12-29')"/>
        <xsl:variable name="vDateG2">
            <xsl:call-template name="funcDateM2G">
                <xsl:with-param name="pDateM" select="$vDateM2"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="substring($vDateG1,1,4)"/>
        <xsl:if
            test="substring($vDateG1,1,4)!=substring($vDateG2,1,4)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring($vDateG2,3,2)"/>
        </xsl:if>
    </xsl:template>
    
    <!-- convert Mālī to Hjrī -->
    <xsl:template name="funcDateM2H">
        <xsl:param name="pDateM"/>
        <xsl:variable name="vDateJ">
            <xsl:call-template name="funcDateM2J">
                <xsl:with-param name="pDateM" select="$pDateM"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="vDateH">
            <xsl:call-template name="funcDateJ2H">
                <xsl:with-param name="pDateJ" select="$vDateJ"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$vDateH"/>
    </xsl:template>

    <!-- v2b: this template provides abbreviation for month names in International Journal of Middle East Studies (IJMES) transscription, Başbakanlik Osmanlu Arşivi (BOA) accronyms, and English abbreviations. As there is no functional difference between calendars, I made the choice of calendars implicit as based on the language selector -->
    <xsl:template name="funcDateMonthNameNumber">
        <xsl:param name="pDate"/>
        <xsl:param name="pMonth" select="number(tokenize($pDate,'([.,&quot;\-])')[2])"/>
        <!-- pMode has value 'name' or 'number' and toggles the output format -->
        <xsl:param name="pMode" select="'name'"/>
        <!-- pLang has value 'HIjmes','HIjmesFull', 'HBoa', 'GEn','JIjmes', 'MIjmes', 'GEnFull', 'GDeFull', 'GTrFull', 'MTrFull' -->
        <xsl:param name="pLang"/>
        <xsl:variable name="vNHIjmes"
            select="'Muḥ,Ṣaf,Rab I,Rab II,Jum I,Jum II,Raj,Shaʿ,Ram,Shaw,Dhu I,Dhu II'"/>
        <xsl:variable name="vNHIjmesFull"
            select="'Muḥarram,Ṣafār,Rabīʿ al-awwal,Rabīʿ al-thānī,Jumāda al-ulā,Jumāda al-tāniya,Rajab,Shaʿbān,Ramaḍān,Shawwāl,Dhū al-qaʿda,Dhū al-ḥijja'"/>
        <xsl:variable name="vNHBoa" select="'M ,S ,Ra,R ,Ca,C ,B ,Ş ,N ,L ,Za,Z '"/>
        <xsl:variable name="vNMBoa" select="'Ar,Ni,Ma,Ha,Te,Ağ,Ey,Tş,Tn,Ke,Ks, '"/>
        <xsl:variable name="vNGEn" select="'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'"/>
        <xsl:variable name="vNGEnFull" select="'January,February,March,April,May,June,July,August,September,October,November,December'"/>
        <xsl:variable name="vNGDeFull"
            select="'Januar,Februar,März,April,Mai,Juni,Juli,August,September,Oktober,November,Dezember'"/>
        <xsl:variable name="vNGTrFull"
            select="'Ocak,Şubat,Mart,Nisan,Mayıs,Haziran,Temmuz,Ağustos,Eylül,Ekim,Kasım,Aralık'"/>
        <xsl:variable name="vNJIjmes"
            select="'Kān II,Shub,Ādhār,Nīs,Ayyār,Ḥaz,Tam,Āb,Ayl,Tish I,Tish II,Kān I'"/>
        <xsl:variable name="vNJIjmesFull"
            select="'Kānūn al-thānī,Shubāṭ,Ādhār,Nīsān,Ayyār,Ḥazīrān,Tammūz,Āb,Aylūl,Tishrīn al-awwal,Tishrīn al-thānī,Kānūn al-awwal'"/>
        <xsl:variable name="vNMIjmes"
            select="'Mārt,Nīs,Māyis,Ḥaz,Tam,Agh,Ayl,Tish I,Tish II,Kān I,Kān II,Shub'"/>
        <xsl:variable name="vNMIjmesFull"
            select="'Mārt,Nīsān,Māyis,Ḥazīrān,Tammūz,Aghusṭūs,Aylūl,Tishrīn al-awwal,Tishrīn al-thānī,Kānūn al-awwal,Kānūn al-thānī,Shubāṭ'"/>
        <xsl:variable name="vNMTrFull"
            select="'Mart,Nisan,Mayıs,Haziran,Temmuz,Ağustos,Eylül,Ekim,Kasım,Aralık,Ocak,Şubat'"/>
        <xsl:variable name="vMonth">
            <xsl:if test="lower-case($pLang)='hijmes'">
                <xsl:for-each select="tokenize($vNHIjmes,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='hijmesfull'">
                <xsl:for-each select="tokenize($vNHIjmesFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='hboa'">
                <xsl:for-each select="tokenize($vNHBoa,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='mboa'">
                <xsl:for-each select="tokenize($vNMBoa,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='gen'">
                <xsl:for-each select="tokenize($vNGEn,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='genfull'">
                <xsl:for-each select="tokenize($vNGEnFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='gdefull'">
                <xsl:for-each select="tokenize($vNGDeFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='gtrfull'">
                <xsl:for-each select="tokenize($vNGTrFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='jijmes'">
                <xsl:for-each select="tokenize($vNJIjmes,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='jijmesfull'">
                <xsl:for-each select="tokenize($vNJIjmesFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='mijmes'">
                <xsl:for-each select="tokenize($vNMIjmes,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='mijmesfull'">
                <xsl:for-each select="tokenize($vNMIjmesFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($pLang)='mtrfull'">
                <xsl:for-each select="tokenize($vNMTrFull,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test="lower-case(.)=lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            
        </xsl:variable>

        <xsl:value-of select="$vMonth"/>
    </xsl:template>

    <!-- This template takes a date string as input and outputs a correctly formatted tei:date node with @when and @when-custom attributes depending on the calendar -->
    <xsl:template name="funcDateFormatTei">
        <xsl:param name="pDate"/>
        <!-- pCal selects the input calendar: 'G', 'J', 'M', or 'H' -->
        <xsl:param name="pCal"/>
        <!-- pOutput establishes whether the original input or a formatted date is produced as output / content of the tei:date node. Values are 'original' and 'formatted' -->
        <xsl:param name="pOutput" select="'original'"/>
        <xsl:param name="pWeekday" select="true()"/>
        <xsl:variable name="vDateTei1">
            <xsl:element name="tei:date">
            <!-- attributes -->
            <xsl:choose>
                <xsl:when test="$pCal='G'">
                    <xsl:attribute name="when" select="$pDate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$pCal='J'">
                            <xsl:variable name="vDateG">
                                <xsl:call-template name="funcDateJ2G">
                                    <xsl:with-param name="pDateJ" select="$pDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="when" select="$vDateG"/>
                            <xsl:attribute name="when-custom" select="$pDate"/>
                            <xsl:attribute name="calendar" select="'#cal_julian'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_julian'"/>
                        </xsl:when>
                        <xsl:when test="$pCal='M'">
                            <xsl:variable name="vDateG">
                                <xsl:call-template name="funcDateM2G">
                                    <xsl:with-param name="pDateM" select="$pDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="when" select="$vDateG"/> 
                            <xsl:attribute name="when-custom" select="$pDate"/>
                            <xsl:attribute name="calendar" select="'#cal_ottomanfiscal'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_ottomanfiscal'"/>
                        </xsl:when>
                        <xsl:when test="$pCal='H'">
                            <xsl:variable name="vDateG">
                                <xsl:call-template name="funcDateH2G">
                                    <xsl:with-param name="pDateH" select="$pDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="when" select="$vDateG"/>
                            <xsl:attribute name="when-custom" select="$pDate"/>
                            <xsl:attribute name="calendar" select="'#cal_islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#cal_islamic'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <!-- element content -->
            <xsl:choose>
                <xsl:when test="$pOutput='formatted'">
                    <xsl:choose>
                        <xsl:when test="$pCal='G'">
                            <xsl:value-of
                                select="format-number(number(tokenize($pDate,'([.,&quot;\-])')[3]),'0')"/>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pDate" select="$pDate"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                                <xsl:with-param name="pLang" select="'Gen'"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="tokenize($pDate,'([.,&quot;\-])')[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$pCal='J'">
                                    <xsl:value-of
                                        select="format-number(number(tokenize($pDate,'([.,&quot;\-])')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'JIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'([.,&quot;\-])')[1]"/>
                                </xsl:when>
                                <xsl:when test="$pCal='M'">
                                    <xsl:value-of
                                        select="format-number(number(tokenize($pDate,'([.,&quot;\-])')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'MIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'([.,&quot;\-])')[1]"/>
                                </xsl:when>
                                <xsl:when test="$pCal='H'">
                                    <xsl:value-of
                                        select="format-number(number(tokenize($pDate,'([.,&quot;\-])')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'HIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'([.,&quot;\-])')[1]"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        </xsl:variable>
        <xsl:variable name="vDateTei2">
            <xsl:for-each select="$vDateTei1/tei:date">
                <xsl:variable name="vWeekday">
                    <xsl:value-of select="format-date(@when,'[FNn]')"/>
                </xsl:variable>
                <xsl:copy>
                    <xsl:for-each select="@*">
                        <xsl:copy/>
                    </xsl:for-each>
                    <xsl:value-of select="."/>
                    <xsl:if test="$pWeekday=true()">
                        <xsl:value-of select="concat(', ',$vWeekday)"/>
                    </xsl:if>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:copy-of select="$vDateTei2"/>

        <!-- this part of the template can produce a calendarDesc element for the teiHeader -->
        <!--<xsl:choose>
            <xsl:when test="$pCal='G'"/>
            <xsl:otherwise>
                <xsl:element name="tei:calendarDesc">
                <xsl:choose>
                    <xsl:when test="$pCal='J'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">cal_julian</xsl:attribute>
                            <xsl:element name="tei:p">
                                <xsl:text>Reformed Julian calendar beginning the Year with 1 January. In the Ottoman context usually referred to as Rūmī.</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$pCal='M'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">cal_ottomanfiscal</xsl:attribute>
                            <xsl:element name="tei:p">
                                <xsl:text>Ottoman fiscal calendar: an Old Julian calendar beginning the Year with 1 March. The year count is synchronised to the Islamic Hijrī calendar. In the Ottoman context usually referred to as Mālī or Rūmī.</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$pCal='H'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">cal_islamic</xsl:attribute>
                            <xsl:element name="tei:p">
                                <xsl:text>Islamic Hijrī calendar beginning the Year with 1 Muḥarram.</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>

    <!-- This template normalises a date input string mixing digits and month names. The output is "yyyy-mm-dd" -->
    <xsl:template name="funcDateNormaliseInput">
        <xsl:param name="pDateString" select="'1000'"/>
        <!-- This parameter selects the calendar and language, i.e. 'HIjmes' -->
        <xsl:param name="pLang"/>
        <xsl:variable name="vDateNode">
            <!-- 1) match yyyy-mm-dd -->
            <xsl:analyze-string select="$pDateString" regex="\s*(\d{{4}})\-(\d{{2}})\-(\d{{2}})\s*">
                <xsl:matching-substring>
                    <xsl:element name="tss:date">
                        <xsl:attribute name="day"
                            select="format-number(number(regex-group(3)),'00')"/>
                        <xsl:attribute name="month" select="regex-group(2)"/>
                        <xsl:attribute name="year" select="regex-group(1)"/>
                    </xsl:element>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!-- 2) match dd MNn yyyy -->
                    <xsl:analyze-string select="$pDateString" regex="\s*(\d+)\s+(.*)\s+(\d{{4}})\s*">
                        <xsl:matching-substring>
                            <xsl:variable name="vMonth">
                                <xsl:call-template name="funcDateMonthNameNumber">
                                    <xsl:with-param name="pMode" select="'number'"/>
                                    <xsl:with-param name="pMonth"
                                        select="translate(regex-group(2),'.','')"/>
                                    <xsl:with-param name="pLang" select="$pLang"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:element name="tss:date">
                                <xsl:attribute name="day"
                                    select="format-number(number(regex-group(1)),'00')"/>
                                <xsl:attribute name="month"
                                    select="format-number(number($vMonth),'00')"/>
                                <xsl:attribute name="year" select="regex-group(3)"/>
                            </xsl:element>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <!-- 3) match MNn dd, yyyy -->
                            <xsl:analyze-string select="$pDateString"
                                regex="\s*(.*)\s+(\d+),\s+(\d{{4}})\s*">
                                <xsl:matching-substring>
                                    <xsl:variable name="vMonth">
                                        <xsl:call-template name="funcDateMonthNameNumber">
                                            <xsl:with-param name="pMode" select="'number'"/>
                                            <xsl:with-param name="pMonth"
                                                select="translate(regex-group(1),'.','')"/>
                                            <xsl:with-param name="pLang" select="$pLang"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:element name="tss:date">
                                        <xsl:attribute name="day"
                                            select="format-number(number(regex-group(2)),'00')"/>
                                        <xsl:attribute name="month"
                                            select="format-number(number($vMonth),'00')"/>
                                        <xsl:attribute name="year" select="regex-group(3)"/>
                                    </xsl:element>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of
            select="concat($vDateNode/tss:date/@year,'-',$vDateNode/tss:date/@month,'-',$vDateNode/tss:date/@day)"
        />
    </xsl:template>

    <!-- v1e -->
    
    <xsl:template name="funcDateIncrement">
        <!-- this param selects the date, format: 'yyyy-mm-dd' -->
        <xsl:param name="pDateStart"/>
        <!-- sets the end date -->
        <xsl:param name="pDateStop"/>
        <xsl:param name="pIncrementBy" select="1" as="xs:integer"/>
        <!-- select what to increment: 'y', 'm', or 'd' -->
        <xsl:param name="pIncrementWhat" select="'y'"/>
        
        <!-- this param selects the conversion calendars: 'H2G', 'G2H', 'G2J', 'J2G', 'H2J', 'J2H', and 'none' -->
        <xsl:param name="pCalendars"/>
        <xsl:variable name="vInputCal" select="substring($pCalendars,1,1)"/>
        
        <xsl:if test="xs:date($pDateStart) &lt;= xs:date($pDateStop)">
            <xsl:variable name="vDateTarget">
                <xsl:choose>
                    <xsl:when test="$pCalendars='G2H'">
                        <xsl:call-template name="funcDateG2H">
                            <xsl:with-param name="pDateG" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$pCalendars='H2G'">
                        <xsl:call-template name="funcDateH2G">
                            <xsl:with-param name="pDateH" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$pCalendars='G2J'">
                        <xsl:call-template name="funcDateG2J">
                            <xsl:with-param name="pDateG" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$pCalendars='J2G'">
                        <xsl:call-template name="funcDateJ2G">
                            <xsl:with-param name="pDateJ" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$pCalendars='H2J'">
                        <xsl:call-template name="funcDateH2J">
                            <xsl:with-param name="pDateH" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$pCalendars='J2H'">
                        <xsl:call-template name="funcDateJ2H">
                            <xsl:with-param name="pDateJ" select="$pDateStart"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pDateStart"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="vDateIncremented">
                <xsl:choose>
                    <xsl:when test="$pIncrementWhat = 'y'" >
                        <xsl:value-of select="xs:date($pDateStart) + xs:yearMonthDuration(concat('P',$pIncrementBy,'Y'))"/>
                    </xsl:when>
                    <xsl:when test="$pIncrementWhat = 'm'" >
                        <xsl:value-of select="xs:date($pDateStart) + xs:yearMonthDuration(concat('P0Y',$pIncrementBy,'M'))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <!--<xsl:value-of select="$pDateStart"/>
            <xsl:text> = </xsl:text>
            <xsl:value-of select="$vDateTarget"/>
            <xsl:text>,
            </xsl:text>-->
            <xsl:call-template name="funcDateFormatTei">
                <xsl:with-param name="pDate" select="$pDateStart"/>
                <xsl:with-param name="pCal" select="$vInputCal"/>
                <xsl:with-param name="pOutput" select="'formatted'"/>
                <xsl:with-param name="pWeekday" select="false()"/>
            </xsl:call-template>
            <xsl:call-template name="funcDateIncrement">
                <xsl:with-param name="pDateStart" select="$vDateIncremented"/>
                <xsl:with-param name="pDateStop" select="$pDateStop"/>
                <xsl:with-param name="pIncrementWhat" select="$pIncrementWhat"/>
                <xsl:with-param name="pIncrementBy" select="$pIncrementBy"/>
                <xsl:with-param name="pCalendars" select="$pCalendars"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- this template increments Julian days between two dates.
    The output is a set of comma-separarted values-->
    <xsl:template name="funcDateIncrementJD">
        <xsl:param name="pJDStart"/>
        <xsl:param name="pJDStop"/>
        <xsl:param name="pIntervalDays" select="1"/>
        <xsl:value-of select="$pJDStart"/>
        <xsl:if test="$pJDStart &lt; $pJDStop">
            <xsl:text>,
            </xsl:text>
            <xsl:call-template name="funcDateIncrementJD">
                <xsl:with-param name="pJDStart" select="$pJDStart + $pIntervalDays"/>
                <xsl:with-param name="pJDStop" select="$pJDStop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- this template is used to normalise and convert the date strings found in the BOA online catalogue -->
    <xsl:template name="funcDateBoa">
        <xsl:param name="pDateString"/>
        <xsl:choose>
            <xsl:when test="contains($pDateString,'Miladî')">
                <xsl:analyze-string select="$pDateString" regex="(\d+)/(\d+)/(\d{{4}})">
                    <xsl:matching-substring>
                        <xsl:variable name="vDateG">
                            <xsl:value-of select="concat(regex-group(3),'-',format-number(number(regex-group(2)),'00'),'-',format-number(number(regex-group(1)),'00'))"/>
                        </xsl:variable>
                        <xsl:value-of select="$vDateG"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="contains($pDateString,'Hicrî')">
                <xsl:analyze-string select="$pDateString" regex="(\d+)/(.{{2}})/(\d{{4}})">
                    <xsl:matching-substring>
                        <xsl:variable name="vMonthH">
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pMonth" select="regex-group(2)"/>
                                <xsl:with-param name="pMode" select="'number'"/>
                                <xsl:with-param name="pLang" select="'HBoa'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateH">
                            <xsl:value-of select="concat(regex-group(3),'-',format-number(number($vMonthH),'00'),'-',format-number(number(regex-group(1)),'00'))"/>
                        </xsl:variable>
                        <xsl:variable name="vDateG">
                            <xsl:call-template name="funcDateH2G">
                                <xsl:with-param name="pDateH" select="$vDateH"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="$vDateG"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <!-- Mālī, which they call Rūmī is marked by not being marked -->
                <xsl:analyze-string select="$pDateString" regex="(\d+)/(.{{2}})/(\d{{4}})">
                    <xsl:matching-substring>
                        <xsl:variable name="vMonthM">
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pMonth" select="regex-group(2)"/>
                                <xsl:with-param name="pMode" select="'number'"/>
                                <xsl:with-param name="pLang" select="'MBoa'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="vDateM">
                            <xsl:value-of select="concat(regex-group(3),'-',format-number(number($vMonthM),'00'),'-',format-number(number(regex-group(1)),'00'))"/>
                        </xsl:variable>
                        <xsl:variable name="vDateG">
                            <xsl:call-template name="funcDateM2G">
                                <xsl:with-param name="pDateM" select="$vDateM"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="$vDateG"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>
