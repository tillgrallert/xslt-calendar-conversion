<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xdt="http://www.w3.org/2005/02/xpath-datatypes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- last addition not documented: f_date-HY2G, f_date-MY2G -->
    <xd:doc scope="stylesheet" type="stylesheet">
        <xd:desc>
            <xd:p>XSL stylesheet for date conversions in XML. </xd:p>
            <xd:p>The stylesheet currenly supports conversions between four calendars using a
                calculation of the Julian Day: Gregorian, Julian, Ottoman fiscal (Mālī), and Hijrī
                calendars. Many of the calculations were adapted from John Walker's Calender
                Converter JavaScript functions (http://www.fourmilab.ch/documents/calendar/). </xd:p>
            <xd:p>The names of the templates reflect their function through a simple ontology: G =
                Gregorian, J = Julian and Rūmī, M = Mālī, H = Hijrī, JD = Julian day. A template
                called f_date-convert-gregorian-to-julian-day will thus compute the Julian day (JD) for a Gregorian (G) date
                as input string.</xd:p>
            <xd:p>Input and output are formatted as yyyy-mm-dd for the conversions between the four
                currently supported calendars.</xd:p>
            <xd:p>Templates for the conversion between calendars: f_date-convert-gregorian-to-julian-day, f_date-convert-julian-day-to-gregorian,
                f_date-convert-julian-to-julian-day, f_date-convert-julian-day-to-julian, f_date-convert-islamic-to-julian-day, f_date-convert-julian-day-to-islamic, f_date-convert-gregorian-to-julian, f_date-convert-gregorian-to-islamic,
                f_date-convert-julian-to-gregorian, f_date-convert-julian-to-islamic, f_date-convert-islamic-to-julian, f_date-convert-julian-to-islamic, f_date-convert-gregorian-to-ottoman-fiscal, f_date-convert-julian-to-ottoman-fiscal, f_date-HY2G, f_date-MY2G.</xd:p>
            <xd:p>Templates for converting Date formats: f_date-MonthNameNumber,
                f_date-NormaliseInput, and f_date-format-iso-string-to-tei.</xd:p>
            <xd:p>The f_date-format-iso-string-to-tei template accepts the same input, but produces a tei:date node
                as output with the relevant @when or @when, @when-custom, @calendar, and
                @datingMethod attributes.</xd:p>
            <xd:p>The f_date-NormaliseInput template can be used to convert variously formatted input
                strings to the yyyy-mm-dd required by other templates. Possible input formats are
                the common English formats of 'dd(.) MNn(.) yyyy', 'MNn(.) dd(.), yyyy', i.e. '15
                Shaʿbān 1324' or 'Jan. 15, 2014'. The template requires an input string and a
                calendar-language combination as found in f_date-MonthNameNumber. </xd:p>
            <xd:p>Abbreviavtions in the f_date-MonthNameNumber try to cut the Month names to three
                letters, as is established practice for English. In case of Arabic letters whose
                transcription requires two Latin letters, month names can be longer than three
                Latin letters, i.e. Shub (for Shubāṭ), Tish (for Tishrīn), etc. </xd:p>
            <xd:p>Templates for incrementing dates between a start and stop date: f_date-incrementAnnually, f_date-incrementJD. Both produce a list of comma-separated values.</xd:p>
            <xd:p>f_date-Boa ingests the date strings found in the BOA online catalogue</xd:p>
            <xd:p>v1a: the tokenize() function to split up input strings was improved with the regex
                '([.,&quot;\-])' instead of just '-', which means, that the templates could deal
                with yyyy,mm,dd in put etc.</xd:p>
            <xd:p>v1a: new f_date-NormaliseInput template.</xd:p>
            <xd:p>v1a: new f_date-convert-ottoman-fiscal-to-julian</xd:p>
            <xd:p>v1b: corrected an error in f_date-convert-gregorian-to-julian-day which resulted in erroneous computation of Gregorian dates in f_date-convert-julian-day-to-gregorian that were off by one day for March-December in leap years.</xd:p>
            <xd:p>Added the function f_date-incrementJD</xd:p>
            <xd:p>This software is licensed as: Distributed under a Creative Commons
                Attribution-ShareAlike 3.0 Unported License
                http://creativecommons.org/licenses/by-sa/3.0/ All rights reserved. Redistribution
                and use in source and binary forms, with or without modification, are permitted
                provided that the following conditions are met: * Redistributions of source code
                must retain the above copyright notice, this list of conditions and the following
                disclaimer. * Redistributions in binary form must reproduce the above copyright
                notice, this list of conditions and the following disclaimer in the documentation
                and/or other materials provided with the distribution. This software is provided by
                the copyright holders and contributors &quot;as is&quot; and any express or implied
                warranties, including, but not limited to, the implied warranties of merchantability
                and fitness for a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental, special,
                exemplary, or consequential damages (including, but not limited to, procurement of
                substitute goods or services; loss of use, data, or profits; or business
                interruption) however caused and on any theory of liability, whether in contract,
                strict liability, or tort (including negligence or otherwise) arising in any way out
                of the use of this software, even if advised of the possibility of such damage. </xd:p>
            <xd:p>Author: Till Grallert</xd:p>
        </xd:desc>
    </xd:doc>
    <!-- v1b: Julian day was one too few! -->
    <!-- Julian day for Gregorian 0001-01-01 -->
    <xsl:param name="p_julian-day-for-gregorian-base" select="1721425.5"/>
    <!-- Julian day for Hijri 0001-01-01 -->
    <xsl:param name="p_julian-day-for-islamic-base" select="1948439.5"/>
    
    <xd:doc>
        <xd:desc>This function determines whether Gregorian years are leap years. Returns 'true()' or 'false()'.</xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-is-gregorian-leap-year">
        <xsl:param name="p_gregorian-date"/>
        <xsl:variable name="v_gregorian-year"
            select="number(tokenize($p_gregorian-date, '([.,&quot;\-])')[1])"/>
        <!-- determines wether the year is a leap year: can be divided by four, but in centesial years divided by 400 -->
        <xsl:value-of
            select="
                if (($v_gregorian-year mod 4) = 0 and (not((($v_gregorian-year mod 100) = 0) and (not(($v_gregorian-year mod 400) = 0))))) then
                    (true())
                else
                    (false())"
        />
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Gregorian to Julian Day </xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-gregorian-to-julian-day">
        <xsl:param name="p_gregorian-date"/>
        <xsl:variable name="v_gregorian-year"
            select="number(tokenize($p_gregorian-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_gregorian-month"
            select="number(tokenize($p_gregorian-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_day-gregorian"
            select="number(tokenize($p_gregorian-date, '([.,&quot;\-])')[3])"/>
        <!-- vLeap indicates when a year is a leap year -->
        <!-- v1b: here was the error for all the havoc in leap years!  -->
        <xsl:variable name="v_is-gregorian-leap-year" select="oape:date-is-gregorian-leap-year($p_gregorian-date)"/>
        <!-- v1b: p_julian-day-for-gregorian-base had been one too few -->
        <xsl:variable name="vA" select="(((367 * $v_gregorian-month) - 362) div 12)"/>
        <xsl:variable name="vB"
            select="
                (if ($v_gregorian-month &lt;= 2) then
                    (0)
                else
                    (if ($v_is-gregorian-leap-year = true()) then
                        (-1)
                    else
                        (-2)))"/>
        <xsl:variable name="v_day-of-gregorian-year" select="floor($vA + $vB + $v_day-gregorian)"/>
        <xsl:variable name="vC" select="$v_gregorian-year - 1"/>
        <xsl:variable name="v_julian-day-of-gregorian-year"
            select="($p_julian-day-for-gregorian-base - 1) + (365 * $vC) + floor($vC div 4) - floor($vC div 100) + floor($vC div 400)"/>
        <xsl:value-of select="$v_julian-day-of-gregorian-year + $v_day-of-gregorian-year"/>
        <!-- <xsl:value-of
            select="($v_julian-day-of-inputGreg0 -1)
            +(365 * ($v_gregorian-year -1))
            + floor(($v_gregorian-year -1) div 4)
            -floor(($v_gregorian-year -1) div 100)
            +floor(($v_gregorian-year -1) div 400)
            +floor((((367 * $v_gregorian-month) -362) div 12)
            + (if($v_gregorian-month &lt;=2) then(0) else (if($v_is-gregorian-leap-year='n') then(-1) else(-2)))
            + $vDay)"/>-->
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
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc> This function converts Julian day to Gregorian date.</xd:desc>
        <xd:param name="p_julian-day"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-day-to-gregorian">
        <xsl:param name="p_julian-day"/>
        <xsl:variable name="vWjd" select="floor($p_julian-day - 0.5) + 0.5"/>
        <xsl:variable name="vDepoch" select="$vWjd - $p_julian-day-for-gregorian-base"/>
        <xsl:variable name="vQuadricent" select="floor($vDepoch div 146097)"/>
        <xsl:variable name="vDqc" select="$vDepoch mod 146097"/>
        <xsl:variable name="vCent" select="floor($vDqc div 36524)"/>
        <xsl:variable name="vDcent" select="$vDqc mod 36524"/>
        <xsl:variable name="vQuad" select="floor($vDcent div 1461)"/>
        <xsl:variable name="vDquad" select="$vDcent mod 1461"/>
        <xsl:variable name="vYindex" select="floor($vDquad div 365)"/>
        <!-- year is correctly calculated -->
        <xsl:variable name="v_gregorian-year"
            select="
                if (not(($vCent = 4) or ($vYindex = 4))) then
                    ((($vQuadricent * 400) + ($vCent * 100) + ($vQuad * 4) + $vYindex) + 1)
                else
                    (($vQuadricent * 400) + ($vCent * 100) + ($vQuad * 4) + $vYindex)"/>
        <xsl:variable name="v_julian-day-of-gregorian-year" select="oape:date-convert-gregorian-to-julian-day(concat($v_gregorian-year, '-01-01'))"/>
        <xsl:variable name="vYearday" select="$vWjd - $v_julian-day-of-gregorian-year"/>
        <!-- leap years are correctly indicated -->
        <xsl:variable name="v_is-gregorian-leap-year" select="oape:date-is-gregorian-leap-year(concat($v_gregorian-year, '-01-01'))"/>
        <xsl:variable name="v_julian-day-of-gregorian-month" select="oape:date-convert-gregorian-to-julian-day(concat($v_gregorian-year, '-03-01'))"/>
        <xsl:variable name="v_leap-year-adjustment">
            <xsl:choose>
                <xsl:when test="$vWjd &lt; $v_julian-day-of-gregorian-month">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$v_is-gregorian-leap-year = true()">
                        <xsl:value-of select="1"/>
                    </xsl:if>
                    <xsl:if test="$v_is-gregorian-leap-year = false()">
                        <xsl:value-of select="2"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_gregorian-month"
            select="floor(((($vYearday + $v_leap-year-adjustment) * 12) + 373) div 367)"/>
        <xsl:variable name="v_julian-day-of-gregorian-day" select="oape:date-convert-gregorian-to-julian-day(concat($v_gregorian-year, '-', $v_gregorian-month, '-01'))"/>
        <!-- v1b: $vWjd - $v_julian-day-of-gregorian-day should be zero for the first of the month, yet, it was not for Mar-Dec in leap years, due to an error in f_date-convert-gregorian-to-julian-day -->
        <xsl:variable name="v_gregorian-day" select="($vWjd - $v_julian-day-of-gregorian-day) + 1"/>
        <!--<xsl:variable name="v_gregorian-day"><xsl:choose><xsl:when test="$v_is-gregorian-leap-year = 'n'"><xsl:value-of select="($vWjd - $v_julian-day-of-gregorian-day) + 1"/></xsl:when><xsl:otherwise><xsl:choose><!-\- days prior to 1 March -\-><xsl:when test="$v_gregorian-month &lt;= 2"><xsl:value-of select="($vWjd - $v_julian-day-of-gregorian-day) + 1"/></xsl:when><xsl:otherwise><xsl:value-of select="($vWjd - $v_julian-day-of-gregorian-day)"/></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:variable>-->
        <xsl:value-of
            select="concat(format-number($v_gregorian-year, '0000'), '-', format-number($v_gregorian-month, '00'), '-', format-number($v_gregorian-day, '00'))"/>
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
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Hijrī to Julian Day </xd:desc>
        <xd:param name="p_islamic-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-islamic-to-julian-day">
        <xsl:param name="p_islamic-date"/>
        <xsl:variable name="v_islamic-year"
            select="number(tokenize($p_islamic-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_islamic-month"
            select="number(tokenize($p_islamic-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_islamic-day"
            select="number(tokenize($p_islamic-date, '([.,&quot;\-])')[3])"/>
        <xsl:value-of
            select="($v_islamic-day + ceiling(29.5 * ($v_islamic-month - 1)) + ($v_islamic-year - 1) * 354 + floor((3 + (11 * $v_islamic-year)) div 30) + $p_julian-day-for-islamic-base - 1)"/>
        <!-- function islamic_to_jd(year, month, day)
        {
        return (day +
        Math.ceil(29.5 * (month - 1)) +
        (year - 1) * 354 +
        Math.floor((3 + (11 * year)) / 30) +
        ISLAMIC_EPOCH) - 1;
        } -->
    </xsl:function>
    
    <xd:doc>
        <xd:desc> This function converts Julian Day to Hijrī </xd:desc>
        <xd:param name="p_julian-day"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-day-to-islamic">
        <xsl:param name="p_julian-day"/>
        <xsl:variable name="v_julian-day" select="floor($p_julian-day) + 0.5"/>
        <xsl:variable name="v_islamic-year"
            select="floor(((30 * ($v_julian-day - $p_julian-day-for-islamic-base)) + 10646) div 10631)"/>
        <xsl:variable name="v_julian-day-of-islamic-month" select="oape:date-convert-islamic-to-julian-day(concat($v_islamic-year, '-01-01'))"/>
        <xsl:variable name="v_islamic-month"
            select="min((12, ceiling(($v_julian-day - (29 + $v_julian-day-of-islamic-month)) div 29.5) + 1))"/>
        <xsl:variable name="v_julian-day-of-islamic-day" select="oape:date-convert-islamic-to-julian-day(concat($v_islamic-year, '-', $v_islamic-month, '-01'))"/>
        <xsl:variable name="v_islamic-day"
            select="($v_julian-day - $v_julian-day-of-islamic-day) + 1"/>
        <xsl:value-of
            select="concat(format-number($v_islamic-year, '0000'), '-', format-number($v_islamic-month, '00'), '-', format-number($v_islamic-day, '00'))"/>
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
    </xsl:function>
    
    <xd:doc>
        <xd:desc> this template converts Hijrī Years to Gregorian year ranges </xd:desc>
        <xd:param name="pYearH"/>
    </xd:doc>
    <xsl:template name="f_date-HY2G">
        <xsl:param name="pYearH" select="'1434'"/>
        <xsl:variable name="v_islamic-date1" select="concat($pYearH, '-01-01')"/>
        <xsl:variable name="v_gregorian-date1" select="oape:date-convert-islamic-to-gregorian($v_islamic-date1)">
            <!--<xsl:call-template name="f_date-convert-islamic-to-gregorian">
                <xsl:with-param name="p_islamic-date" select="$v_islamic-date1"/>
            </xsl:call-template>-->
        </xsl:variable>
        <xsl:variable name="v_islamic-date2" select="concat($pYearH, '-12-29')"/>
        <xsl:variable name="v_gregorian-date2" select="oape:date-convert-islamic-to-gregorian($v_islamic-date2)">
            <!--<xsl:call-template name="f_date-convert-islamic-to-gregorian">
                <xsl:with-param name="p_islamic-date" select="$v_islamic-date2"/>
            </xsl:call-template>-->
        </xsl:variable>
        <xsl:value-of select="substring($v_gregorian-date1, 1, 4)"/>
        <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
        <xsl:if test="substring($v_gregorian-date1, 1, 4) != substring($v_gregorian-date2, 1, 4)">
            <xsl:text>-</xsl:text>
            <xsl:choose>
                <!-- the range 1899-1900 must be accounted for -->
                <xsl:when test="substring($v_gregorian-date2, 3, 2) = '00'">
                    <xsl:value-of select="substring($v_gregorian-date2, 1, 4)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($v_gregorian-date2, 3, 2)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!-- this template converts Gregorian to Mali dates (i.e. Julian, commencing on 1 Mar, minus 584 years from 13 March 1840 onwards)  -->
    
    <xd:doc>
        <xd:desc>This function converts Gregorian to Ottoman fiscal / Mālī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-gregorian-to-ottoman-fiscal">
        <xsl:param name="p_gregorian-date"/>
        <!--<xsl:variable name="v_julian-day-of-input">
            <xsl:call-template name="f_date-convert-gregorian-to-julian-day">
                <xsl:with-param name="p_gregorian-date" select="$p_gregorian-date"/>
            </xsl:call-template>
        </xsl:variable>-->
        <!--<xsl:variable name="v_julian-date" select="oape:date-convert-gregorian-to-julian($p_gregorian-date)">
           <!-\- <xsl:call-template name="f_date-convert-gregorian-to-julian">
                <xsl:with-param name="p_gregorian-date" select="$p_gregorian-date"/>
            </xsl:call-template>-\->
        </xsl:variable>
        <xsl:variable name="v_ottoman-fiscal-date" select="oape:date-convert-julian-to-ottoman-fiscal($v_julian-date)">
            <!-\-<xsl:call-template name="f_date-convert-julian-to-ottoman-fiscal">
                <xsl:with-param name="p_julian-date" select="$v_julian-date"/>
            </xsl:call-template>
-\->        </xsl:variable>-->
        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-gregorian-to-julian($p_gregorian-date))"/>
    </xsl:function>
    <!-- v2e -->
    
    <xd:doc>
        <xd:desc> This function converts Julian Day to Julian / Rūmī. Everything works correctly </xd:desc>
        <xd:param name="p_julian-day"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-day-to-julian">
        <xsl:param name="p_julian-day"/>
        <xsl:variable name="vZ" select="floor($p_julian-day + 0.5)"/>
        <xsl:variable name="vB" select="$vZ + 1524"/>
        <xsl:variable name="vC" select="floor(($vB - 122.1) div 365.25)"/>
        <xsl:variable name="vD" select="floor(365.25 * $vC)"/>
        <xsl:variable name="vE" select="floor(($vB - $vD) div 30.6001)"/>
        <xsl:variable name="v_julian-month"
            select="
                floor(if ($vE lt 14) then
                    ($vE - 1)
                else
                    ($vE - 13))"/>
        <xsl:variable name="v_julian-year"
            select="
                floor(if ($v_julian-month gt 2) then
                    ($vC - 4716)
                else
                    ($vC - 4715))"/>
        <xsl:variable name="v_julian-day" select="($vB - $vD) - floor(30.6001 * $vE)"/>
        <xsl:value-of
            select="concat(format-number($v_julian-year, '0000'), '-', format-number($v_julian-month, '00'), '-', format-number($v_julian-day, '00'))"/>
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
    year = Math.floor((month >2) ? (c - 4716) : (c - 4715));
    day = b - d - Math.floor(30.6001 * e);
    
    
    return new Array(year, month, day);
} -->
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Julian / Rūmī dates to Julian Day </xd:desc>
        <xd:param name="p_julian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-to-julian-day">
        <xsl:param name="p_julian-date"/>
        <xsl:variable name="v_julian-year"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_julian-month"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_julian-day"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[3])"/>
        <xsl:variable name="v_julian-year-adjustment"
            select="
                if ($v_julian-month &lt;= 2) then
                    ($v_julian-year - 1)
                else
                    ($v_julian-year)"/>
        <xsl:variable name="v_julian-month-adjustment"
            select="
                if ($v_julian-month &lt;= 2) then
                    ($v_julian-month + 12)
                else
                    ($v_julian-month)"/>
        <xsl:variable name="v_julian-day-of-input"
            select="floor(365.25 * ($v_julian-year-adjustment + 4716)) + floor(30.6001 * ($v_julian-month-adjustment + 1)) + $v_julian-day - 1524.5"/>
        <xsl:value-of select="$v_julian-day-of-input"/>
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
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Gregorian to Hijrī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-gregorian-to-islamic">
        <xsl:param name="p_gregorian-date"/>
        <!--<xsl:call-template name="f_date-convert-julian-day-to-islamic">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-gregorian-to-julian-day">
                    <xsl:with-param name="p_gregorian-date" select="$p_gregorian-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-islamic(oape:date-convert-gregorian-to-julian-day($p_gregorian-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Hijrī to Gregorian dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_islamic-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-islamic-to-gregorian">
        <xsl:param name="p_islamic-date"/>
        <!--<xsl:call-template name="f_date-convert-julian-day-to-gregorian">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-islamic-to-julian-day">
                    <xsl:with-param name="p_islamic-date" select="$p_islamic-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian(oape:date-convert-islamic-to-julian-day($p_islamic-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Gregorian to Julian / Rūmī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-gregorian-to-julian">
        <xsl:param name="p_gregorian-date"/>
        <!-- at the moment the julian day is wrong! Leap years are correctly computed -->
        <!--<xsl:call-template name="f_date-convert-julian-day-to-julian">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-gregorian-to-julian-day">
                    <xsl:with-param name="p_gregorian-date" select="$p_gregorian-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-julian(oape:date-convert-gregorian-to-julian-day($p_gregorian-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Islamic Hijri to Julian / Rūmī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_islamic-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-islamic-to-julian">
        <xsl:param name="p_islamic-date"/>
        <!--<xsl:call-template name="f_date-convert-julian-day-to-julian">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-islamic-to-julian-day">
                    <xsl:with-param name="p_islamic-date" select="$p_islamic-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-julian(oape:date-convert-islamic-to-julian-day($p_islamic-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Julian / Rūmī to Islamic Hijrī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_julian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-to-islamic">
        <xsl:param name="p_julian-date"/>
        <!--<xsl:call-template name="f_date-convert-julian-day-to-islamic">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-julian-to-julian-day">
                    <xsl:with-param name="p_julian-date" select="$p_julian-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-islamic(oape:date-convert-julian-to-julian-day($p_julian-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Julian / Rūmī to Gregorian dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_julian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-to-gregorian">
        <xsl:param name="p_julian-date"/>
       <!-- <xsl:call-template name="f_date-convert-julian-day-to-gregorian">
            <xsl:with-param name="p_julian-day">
                <xsl:call-template name="f_date-convert-julian-to-julian-day">
                    <xsl:with-param name="p_julian-date" select="$p_julian-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian(oape:date-convert-julian-to-julian-day($p_julian-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Julian/ Rūmī to Ottoman fiscal / Mālī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_julian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-to-ottoman-fiscal">
        <!-- Mālī is an old Julian calendar that begins on 1 March of the Julian year introduced in 1676. The year count was synchronised with the Hijri calendar until 1872 G -->
        <xsl:param name="p_julian-date"/>
        <xsl:variable name="v_julian-year"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_julian-month"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_julian-day"
            select="number(tokenize($p_julian-date, '([.,&quot;\-])')[3])"/>
        <!-- vMontM computes the months as staring with March -->
        <xsl:variable name="v_ottoman-fiscal-month"
            select="
                if ($v_julian-month &lt;= 2) then
                    ($v_julian-month + 10)
                else
                    ($v_julian-month - 2)"/>
        <!-- v_julian-year-old-system computes old Julian years beginning on 1 March -->
        <xsl:variable name="v_julian-year-old-system"
            select="
                if ($v_julian-month &lt;= 2) then
                    ($v_julian-year - 1)
                else
                    ($v_julian-year)"/>
        <!-- Every 33 lunar years the Hjrī year completes within a single Mālī year. In this case a year was dropped from the Mālī counting ( 1121, 1154, 1188, 1222, and 1255). due to a printing error, Mālī and Hjrī years were not synchronised in on 1872-03-01 G to 1289 M and the synchronisation was dropped for ever. According to Deny 1921, the OE retrospectively established a new solar era with 1 Mārt 1256 (13 Mar 1840) -->
        <xsl:variable name="v_ottoman-fiscal-year">
            <xsl:variable name="v_islamic-date" select="oape:date-convert-julian-to-islamic($p_julian-date)">
                <!--<xsl:call-template name="f_date-convert-julian-to-islamic">
                    <xsl:with-param name="p_julian-date" select="$p_julian-date"/>
                </xsl:call-template>-->
            </xsl:variable>
            <xsl:variable name="v_islamic-year"
                select="number(tokenize($v_islamic-date, '([.,&quot;\-])')[1])"/>
            <xsl:choose>
                <xsl:when test="$v_islamic-year &lt;= 1255">
                    <xsl:choose>
                        <xsl:when test="$v_islamic-year &lt;= 1222">
                            <xsl:choose>
                                <xsl:when test="$v_islamic-year &lt;= 1188">
                                    <xsl:choose>
                                        <xsl:when test="$v_islamic-year &lt;= 1154">
                                            <xsl:choose>
                                                <xsl:when test="$v_islamic-year &lt;= 1121">
                                                  <xsl:value-of
                                                  select="$v_julian-year-old-system - 589"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$v_julian-year-old-system - 588"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$v_julian-year-old-system - 587"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$v_julian-year-old-system - 586"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$v_julian-year-old-system - 585"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$v_julian-year-old-system - 584"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- this variable computes the Hijrī date for the 1 Mar of $v_julian-year. As the lunar year is 354.37 solar days long, it is 11 to 12 days short than the solar year. If 1 Muḥ falls between 1 Mar J and 12 Mar J, the years should be synchronised. But computation is more complicated than empirically established differences between the calendars -->
        <!--<xsl:variable name="v_ottoman-fiscal-year2"><!-\- Julian day for the 1 Mar of the current Mālī year ( -\-><xsl:variable name="v_julian-day-of-inputJ1March"><xsl:call-template name="f_date-convert-julian-to-julian-day"><xsl:with-param name="p_julian-date" select="concat($v_julian-year,'-03-01')"/></xsl:call-template></xsl:variable><!-\- calculate the Hijrī date for 1 Mar of current Mālī year -\-><xsl:variable name="v_islamic-date1March"><xsl:call-template name="f_date-convert-julian-day-to-islamic"><xsl:with-param name="p_julian-day" select="$v_julian-day-of-inputJ1March"/></xsl:call-template></xsl:variable><xsl:variable name="v_islamic-year1March" select="number(tokenize($v_islamic-date1March,'([.,&quot;\-])')[1])"/><!-\- Julian day for the 1 Muḥarram of the year beginning after 1 Mar of the current Mālī year. -\-><xsl:variable name="v_julian-day-of-inputH1Muharram"><xsl:call-template name="f_date-convert-islamic-to-julian-day"><xsl:with-param name="p_islamic-date" select="concat($v_islamic-year1March +1,'-01-01')"/></xsl:call-template></xsl:variable><!-\- check whether the difference between the Julian days is less than 12 days -\-><xsl:choose><xsl:when test="$v_julian-day-of-inputH1Muharram - $v_julian-day-of-inputJ1March &lt; 12"><xsl:value-of select="1"/></xsl:when><xsl:otherwise><xsl:value-of select="$v_islamic-year1March"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="v_ottoman-fiscal-year" select="if($v_julian-month &lt;=2) then($v_ottoman-fiscal-year2 -1) else($v_ottoman-fiscal-year2)"/>-->
        <!-- in 1917 Mālī was synchronised to the Gregorian calendar in two steps: 1333-01-01 M was established as 1917-03-01 and 1334-01-01 was synchronised to 1918-01-01. Yet, despite the alignement of numerical values, the month names, of course, remained untouched: 1334-01-01 was 1 Kan I 1334 and not 1 Mārt 1334 -->
        <!-- the current iteration is not correct for the first 13 days of 1333 / last 13 days of 1332 -->
        <xsl:choose>
            <xsl:when test="$v_ottoman-fiscal-year &lt; 1333">
                <xsl:value-of
                    select="concat(format-number($v_ottoman-fiscal-year, '0000'), '-', format-number($v_ottoman-fiscal-month, '00'), '-', format-number($v_julian-day, '00'))"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- function to convert Julian to Gregorian is needed here -->
                <xsl:variable name="v_gregorian-date" select="oape:date-convert-julian-to-gregorian($p_julian-date)">
                    <!--<xsl:call-template name="f_date-convert-julian-to-gregorian">
                        <xsl:with-param name="p_julian-date" select="$p_julian-date"/>
                    </xsl:call-template>-->
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$v_julian-year &gt;= 1918">
                        <xsl:value-of
                            select="concat(format-number($v_julian-year - 584, '0000'), '-', format-number(number(tokenize($v_gregorian-date, '([.,&quot;\-])')[2]), '00'), '-', format-number(number(tokenize($v_gregorian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="concat(format-number($v_ottoman-fiscal-year, '0000'), '-', format-number(number(tokenize($v_gregorian-date, '([.,&quot;\-])')[2]) - 2, '00'), '-', format-number(number(tokenize($v_gregorian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Ottoman fiscal / Mālī to Julian/ Rūmī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_ottoman-fiscal-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-to-julian">
        <!-- Mālī is an old Julian calendar that begins on 1 March of the Julian year introduced in 1676. The year count was synchronised with the Hijri calendar until 1872 G -->
        <xsl:param name="p_ottoman-fiscal-date"/>
        <xsl:variable name="v_ottoman-fiscal-year"
            select="number(tokenize($p_ottoman-fiscal-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_ottoman-fiscal-month"
            select="number(tokenize($p_ottoman-fiscal-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_ottoman-fiscal-day"
            select="number(tokenize($p_ottoman-fiscal-date, '([.,&quot;\-])')[3])"/>
        <!-- v_julian-month computes the months as staring with January -->
        <xsl:variable name="v_julian-month"
            select="
                if ($v_ottoman-fiscal-month &lt;= 10) then
                    ($v_ottoman-fiscal-month + 2)
                else
                    ($v_ottoman-fiscal-month - 10)"/>
        <!-- v_julian-year-new-system computes Julian years beginning on 1 January -->
        <xsl:variable name="v_julian-year-new-system"
            select="
                if ($v_ottoman-fiscal-month &lt;= 10) then
                    ($v_ottoman-fiscal-year)
                else
                    ($v_ottoman-fiscal-year + 1)"/>
        <!-- Every 33 lunar years the Hjrī year completes within a single Mālī year. In this case a year was dropped from the Mālī counting ( 1121, 1154, 1188, 1222, and 1255). due to a printing error, Mālī and Hjrī years were not synchronised in on 1872-03-01 G to 1289 M and the synchronisation was dropped for ever. According to Deny 1921, the OE retrospectively established a new solar era with 1 Mārt 1256 (13 Mar 1840) -->
        <xsl:variable name="v_julian-year">
            <!-- <xsl:variable name="v_islamic-date"><xsl:call-template name="f_date-convert-julian-to-islamic"><xsl:with-param name="p_julian-date" select="$p_julian-date"/></xsl:call-template></xsl:variable>-->
            <!--<xsl:variable name="v_islamic-year" select="number(tokenize($v_islamic-date,'([.,&quot;\-])')[1])"/>-->
            <xsl:choose>
                <xsl:when test="$v_ottoman-fiscal-year &lt;= 1255">
                    <xsl:choose>
                        <xsl:when test="$v_ottoman-fiscal-year &lt;= 1222">
                            <xsl:choose>
                                <xsl:when test="$v_ottoman-fiscal-year &lt;= 1188">
                                    <xsl:choose>
                                        <xsl:when test="$v_ottoman-fiscal-year &lt;= 1154">
                                            <xsl:choose>
                                                <xsl:when test="$v_ottoman-fiscal-year &lt;= 1121">
                                                  <xsl:value-of
                                                  select="$v_julian-year-new-system + 589"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="$v_julian-year-new-system + 588"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$v_julian-year-new-system + 587"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$v_julian-year-new-system + 586"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$v_julian-year-new-system + 585"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$v_julian-year-new-system + 584"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- in 1917 Mālī was synchronised to the Gregorian calendar in two steps: 1333-01-01 M was established as 1917-03-01 and 1334-01-01 was synchronised to 1918-01-01. Yet, despite the alignement of numerical values, the month names, of course, remained untouched: 1334-01-01 was 1 Kan I 1334 and not 1 Mārt 1334 -->
        <!-- the current iteration is not correct for the first 13 days of 1333 / last 13 days of 1332 -->
        <xsl:choose>
            <xsl:when test="$v_ottoman-fiscal-year &lt; 1333">
                <xsl:value-of
                    select="concat(format-number($v_julian-year, '0000'), '-', format-number($v_julian-month, '00'), '-', format-number($v_ottoman-fiscal-day, '00'))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$v_ottoman-fiscal-year &gt;= 1334">
                        <xsl:variable name="v_julian-date" select="oape:date-convert-gregorian-to-julian(concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month, '-', $v_ottoman-fiscal-day))">
                            <!--<xsl:call-template name="f_date-convert-gregorian-to-julian">
                                <xsl:with-param name="p_gregorian-date"
                                    select="concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month, '-', $v_ottoman-fiscal-day)"
                                />
                            </xsl:call-template>-->
                        </xsl:variable>
                        <xsl:value-of
                            select="concat(format-number($v_ottoman-fiscal-year + 584, '0000'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[2]), '00'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:when>
                    <!-- works correctly -->
                    <xsl:otherwise>
                        <xsl:variable name="v_julian-date" select="oape:date-convert-gregorian-to-julian(concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month + 2, '-', $v_ottoman-fiscal-day))">
                            <!--<xsl:call-template name="f_date-convert-gregorian-to-julian">
                                <xsl:with-param name="p_gregorian-date"
                                    select="concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month + 2, '-', $v_ottoman-fiscal-day)"
                                />
                            </xsl:call-template>-->
                        </xsl:variable>
                        <xsl:value-of
                            select="concat(format-number($v_julian-year, '0000'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[2]), '00'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Ottoman fiscal / Mālī to Gregorian dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_ottoman-fiscal-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-to-gregorian">
        <xsl:param name="p_ottoman-fiscal-date"/>
        <xsl:variable name="v_julian-date" select="oape:date-convert-ottoman-fiscal-to-julian($p_ottoman-fiscal-date)">
            <!--<xsl:call-template name="f_date-convert-ottoman-fiscal-to-julian">
                <xsl:with-param name="p_ottoman-fiscal-date" select="$p_ottoman-fiscal-date"/>
            </xsl:call-template>-->
        </xsl:variable>
        <!--<xsl:variable name="v_gregorian-date">
            <xsl:call-template name="f_date-convert-julian-to-gregorian">
                <xsl:with-param name="p_julian-date" select="$v_julian-date"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$v_gregorian-date"/>-->
        <xsl:value-of select="oape:date-convert-julian-to-gregorian($v_julian-date)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc> this template converts Mali Years to Gregorian year ranges </xd:desc>
        <xd:param name="pYearM"/>
    </xd:doc>
    <xsl:template name="f_date-MY2G">
        <xsl:param name="pYearM" select="'1434'"/>
        <xsl:variable name="v_ottoman-fiscal-date1" select="concat($pYearM, '-01-01')"/>
        <xsl:variable name="v_gregorian-date1" select="oape:date-convert-ottoman-fiscal-to-gregorian($v_ottoman-fiscal-date1)">
           <!-- <xsl:call-template name="f_date-convert-ottoman-fiscal-to-gregorian">
                <xsl:with-param name="p_ottoman-fiscal-date" select="$v_ottoman-fiscal-date1"/>
            </xsl:call-template>-->
        </xsl:variable>
        <xsl:variable name="v_ottoman-fiscal-date2" select="concat($pYearM, '-12-29')"/>
        <xsl:variable name="v_gregorian-date2" select="oape:date-convert-ottoman-fiscal-to-gregorian($v_ottoman-fiscal-date2)">
            <!--<xsl:call-template name="f_date-convert-ottoman-fiscal-to-gregorian">
                <xsl:with-param name="p_ottoman-fiscal-date" select="$v_ottoman-fiscal-date2"/>
            </xsl:call-template>-->
        </xsl:variable>
        <xsl:value-of select="substring($v_gregorian-date1, 1, 4)"/>
        <xsl:if test="substring($v_gregorian-date1, 1, 4) != substring($v_gregorian-date2, 1, 4)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring($v_gregorian-date2, 3, 2)"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This function converts Ottoman fiscal / Mālī to Islamic Hjrī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_ottoman-fiscal-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-to-islamic">
        <xsl:param name="p_ottoman-fiscal-date"/>
        <!--<xsl:call-template name="f_date-convert-julian-to-islamic">
            <xsl:with-param name="p_julian-date">
                <xsl:call-template name="f_date-convert-ottoman-fiscal-to-julian">
                    <xsl:with-param name="p_ottoman-fiscal-date" select="$p_ottoman-fiscal-date"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:value-of select="oape:date-convert-julian-to-islamic(oape:date-convert-ottoman-fiscal-to-julian($p_ottoman-fiscal-date))"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc> v2b: this template provides abbreviation for month names in International Journal of Middle East Studies (IJMES) transscription, Başbakanlik Osmanlu Arşivi (BOA) accronyms, and English abbreviations. As there is no functional difference between calendars, I made the choice of calendars implicit as based on the language selector </xd:desc>
        <xd:param name="pDate"/>
        <xd:param name="pMonth"/>
        <xd:param name="pMode"/>
        <xd:param name="p_input-lang"/>
    </xd:doc>
    <xsl:template name="f_date-MonthNameNumber">
        <xsl:param name="pDate"/>
        <xsl:param name="pMonth" select="number(tokenize($pDate, '([.,&quot;\-])')[2])"/>
        <!-- pMode has value 'name' or 'number' and toggles the output format -->
        <xsl:param name="pMode" select="'name'"/>
        <!-- p_input-lang has value 'HAr' 'HIjmes','HIjmesFull', 'HBoa', 'GEn','JIjmes', 'MIjmes', 'GEnFull', 'GDeFull', 'GTrFull', 'MTrFull' -->
        <xsl:param name="p_input-lang"/>
        <xsl:variable name="vNHIjmes"
            select="'Muḥ,Ṣaf,Rab I,Rab II,Jum I,Jum II,Raj,Shaʿ,Ram,Shaw,Dhu I,Dhu II'"/>
        <xsl:variable name="vNHIjmesFull"
            select="'Muḥarram,Ṣafār,Rabīʿ al-awwal,Rabīʿ al-thānī,Jumāda al-ulā,Jumāda al-tāniya,Rajab,Shaʿbān,Ramaḍān,Shawwāl,Dhū al-qaʿda,Dhū al-ḥijja'"/>
        <xsl:variable name="vNHAr"
            select="'محرم,صفر,ربيع الاول,ربيع الثاني,جمادى الاولى,جمادى الآخرة,رجب,شعبان,رمضان,شوال,ذو القعدة,ذو الحجة'"/>
        <xsl:variable name="vNHBoa" select="'M ,S ,Ra,R ,Ca,C ,B ,Ş ,N ,L ,Za,Z '"/>
        <xsl:variable name="vNMBoa" select="'Ar,Ni,Ma,Ha,Te,Ağ,Ey,Tş,Tn,Ke,Ks, '"/>
        <xsl:variable name="vNGEn" select="'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'"/>
        <xsl:variable name="vNGEnFull"
            select="'January,February,March,April,May,June,July,August,September,October,November,December'"/>
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
            <xsl:if test="lower-case($p_input-lang) = 'har'">
                <xsl:for-each select="tokenize($vNHAr, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'hijmes'">
                <xsl:for-each select="tokenize($vNHIjmes, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'hijmesfull'">
                <xsl:for-each select="tokenize($vNHIjmesFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'hboa'">
                <xsl:for-each select="tokenize($vNHBoa, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'mboa'">
                <xsl:for-each select="tokenize($vNMBoa, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'gen'">
                <xsl:for-each select="tokenize($vNGEn, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'genfull'">
                <xsl:for-each select="tokenize($vNGEnFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'gdefull'">
                <xsl:for-each select="tokenize($vNGDeFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'gtrfull'">
                <xsl:for-each select="tokenize($vNGTrFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'jijmes'">
                <xsl:for-each select="tokenize($vNJIjmes, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'jijmesfull'">
                <xsl:for-each select="tokenize($vNJIjmesFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'mijmes'">
                <xsl:for-each select="tokenize($vNMIjmes, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'mijmesfull'">
                <xsl:for-each select="tokenize($vNMIjmesFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="lower-case($p_input-lang) = 'mtrfull'">
                <xsl:for-each select="tokenize($vNMTrFull, ',')">
                    <xsl:if test="$pMode = 'name'">
                        <xsl:if test="position() = $pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode = 'number'">
                        <xsl:if test="lower-case(.) = lower-case($pMonth)">
                            <xsl:value-of select="position()"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="$vMonth"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>This function converts between month names and numbers according to various calendars.</xd:desc>
        <xd:param name="p_input-month">Input month name or number.</xd:param>
        <xd:param name="p_output-mode">Toggles between 'name' or 'number'.</xd:param>
        <xd:param name="p_input-lang">Takes valid values of @xml:id as input.</xd:param>
        <xd:param name="p_calendar">Toggles between calendars. Uses references to @xml:ids as input: '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal' or '#cal_gregorian'</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-convert-months">
        <xsl:param name="p_input-month"/>
        <!-- pMode has value 'name' or 'number' and toggles the output format -->
        <xsl:param name="p_output-mode"/>
        <!-- select the input lang by means of @xml:lang -->
        <xsl:param name="p_input-lang"/>
        <!-- select the input lang by means of TEI's @datingMethod -->
        <xsl:param name="p_calendar"/>
        <!-- check if all necessary input is provided -->
        <xsl:if test="not($p_output-mode = ('name', 'number'))">
            <xsl:message terminate="yes">
                <xsl:text>The value of $p_output-mode must be either 'name' or 'number'.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:if test="not($p_calendar = ('#cal_islamic', '#cal_julian', '#cal_ottomanfiscal', '#cal_gregorian'))">
            <xsl:message terminate="yes">
                <xsl:text>The value of $p_calendar muse be either '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal' or '#cal_gregorian'.</xsl:text>
            </xsl:message>
        </xsl:if>
        <!-- month names are similar for rūmī /sharqī / Julian and Gregorian calendars -->
        <xsl:variable name="v_calendar">
            <xsl:choose>
                <xsl:when test="$p_calendar = '#cal_gregorian'">
                    <xsl:text>#cal_julian</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_calendar"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_month-names-and-numbers">
            <tei:listNym corresp="#cal_islamic">
                <tei:nym n="1">
                    <!-- <tei:form xml:lang="tr">Mart</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Muḥarram</tei:form>
                    <tei:form xml:lang="ar">محرم</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">M</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <!-- <tei:form xml:lang="tr">Nisan</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ṣafār</tei:form>
                    <tei:form xml:lang="ar">صفار</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">S</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <!-- <tei:form xml:lang="tr">Mayıs</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rabīʿ al-awwal</tei:form>
                    <tei:form xml:lang="ar">ربيع الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ra</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <!-- <tei:form xml:lang="tr">Haziran</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rabīʿ al-thānī</tei:form>
                    <tei:form xml:lang="ar">ربيع الثاني</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">R</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <!-- <tei:form xml:lang="tr">Temmuz</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Jumāda al-ulā</tei:form>
                    <tei:form xml:lang="ar">جمادى الاولى</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ca</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <!-- <tei:form xml:lang="tr">Ağustos</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Jumāda al-tāniya</tei:form>
                    <tei:form xml:lang="ar">جمادى الآخرة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">C</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <!-- <tei:form xml:lang="tr">Eylül</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rajab</tei:form>
                    <tei:form xml:lang="ar">رجب</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">B</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <!-- <tei:form xml:lang="tr">Ekim</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shaʿbān</tei:form>
                    <tei:form xml:lang="ar">شعبان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ş</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <!-- <tei:form xml:lang="tr">Kasım</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ramaḍān</tei:form>
                    <tei:form xml:lang="ar">رمضان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">N</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <!-- <tei:form xml:lang="tr">Aralık</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shawwāl</tei:form>
                    <tei:form xml:lang="ar">شوال</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">L</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <!-- <tei:form xml:lang="tr">Ocak</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Dhū al-qaʿda</tei:form>
                    <tei:form xml:lang="ar">ذو القعدة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Za</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <!-- <tei:form xml:lang="tr">Şubat</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">ShubDhū al-ḥijjaāṭ</tei:form>
                    <tei:form xml:lang="ar">ذو الحجة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Z</tei:form>
                </tei:nym>
            </tei:listNym>
            <tei:listNym corresp="#cal_ottomanfiscal">
                <tei:nym n="1">
                    <tei:form xml:lang="tr">Mart</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Mārt</tei:form>
                    <tei:form xml:lang="ar">مارت</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ar</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <tei:form xml:lang="tr">Nisan</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Nīsān</tei:form>
                    <tei:form xml:lang="ar">نيسان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ni</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <tei:form xml:lang="tr">Mayıs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Māyis</tei:form>
                    <tei:form xml:lang="ar">مايس</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ma</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <tei:form xml:lang="tr">Haziran</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ḥazīrān</tei:form>
                    <tei:form xml:lang="ar">حزيران</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ha</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <tei:form xml:lang="tr">Temmuz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tammūz</tei:form>
                    <tei:form xml:lang="ar">تموز</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Te</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <tei:form xml:lang="tr">Ağustos</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aghusṭūs</tei:form>
                    <tei:form xml:lang="ar">اغسطوس</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ağ</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <tei:form xml:lang="tr">Eylül</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aylūl</tei:form>
                    <tei:form xml:lang="ar">ايلول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ey</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <tei:form xml:lang="tr">Ekim</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-awwal</tei:form>
                    <tei:form xml:lang="ar">تسرين الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Tş</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <tei:form xml:lang="tr">Kasım</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-thānī</tei:form>
                    <tei:form xml:lang="ar">تسرين الثاني</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Tn</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <tei:form xml:lang="tr">Aralık</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-awwal</tei:form>
                    <tei:form xml:lang="ar">كانون الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ke</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <tei:form xml:lang="tr">Ocak</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-thānī</tei:form>
                    <tei:form xml:lang="ar">كانون الثاني</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ks</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <tei:form xml:lang="tr">Şubat</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shubāṭ</tei:form>
                    <tei:form xml:lang="ar">شباط</tei:form>
                </tei:nym>
            </tei:listNym>
            <tei:listNym corresp="#cal_julian">
                <tei:nym n="1">
                    <tei:form xml:lang="tr">Ocak</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-thānī</tei:form>
                    <tei:form xml:lang="ar">كانون الثاني</tei:form>
                    <tei:form xml:lang="en">January</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <tei:form xml:lang="tr">Şubat</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shubāṭ</tei:form>
                    <tei:form xml:lang="ar">شباط</tei:form>
                    <tei:form xml:lang="en">February</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <tei:form xml:lang="tr">Mart</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ādhār</tei:form>
                    <tei:form xml:lang="ar">آذار</tei:form>
                    <tei:form xml:lang="en">March</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <tei:form xml:lang="tr">Nisan</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Nīsān</tei:form>
                    <tei:form xml:lang="ar">نيسان</tei:form>
                    <tei:form xml:lang="en">April</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <tei:form xml:lang="tr">Mayıs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ayyār</tei:form>
                    <tei:form xml:lang="ar">ايار</tei:form>
                    <tei:form xml:lang="en">May</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <tei:form xml:lang="tr">Haziran</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ḥazīrān</tei:form>
                    <tei:form xml:lang="ar">حزيران</tei:form>
                    <tei:form xml:lang="en">June</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <tei:form xml:lang="tr">Temmuz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tammūz</tei:form>
                    <tei:form xml:lang="ar">تموز</tei:form>
                    <tei:form xml:lang="en">July</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <tei:form xml:lang="tr">Ağustos</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Āb</tei:form>
                    <tei:form xml:lang="ar">آب</tei:form>
                    <tei:form xml:lang="en">August</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <tei:form xml:lang="tr">Eylül</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aylūl</tei:form>
                    <tei:form xml:lang="ar">ايلول</tei:form>
                    <tei:form xml:lang="en">September</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <tei:form xml:lang="tr">Ekim</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-awwal</tei:form>
                    <tei:form xml:lang="ar">تسرين الاول</tei:form>
                    <tei:form xml:lang="en">October</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <tei:form xml:lang="tr">Kasım</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-thānī</tei:form>
                    <tei:form xml:lang="ar">تسرين الثاني</tei:form>
                    <tei:form xml:lang="en">November</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <tei:form xml:lang="tr">Aralık</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-awwal</tei:form>
                    <tei:form xml:lang="ar">كانون الاول</tei:form>
                    <tei:form xml:lang="en">December</tei:form>
                </tei:nym>
            </tei:listNym>
        </xsl:variable>
        <xsl:variable name="v_month">
            <xsl:if test="$p_output-mode = 'name' and xs:integer($p_input-month)">
                <!-- check if the nymList for the calendar contains the month name -->
                <xsl:value-of
                    select="$v_month-names-and-numbers/descendant::tei:listNym[@corresp = $v_calendar]/tei:nym[@n = $p_input-month]/tei:form[@xml:lang = $p_input-lang]"
                />
            </xsl:if>
            <xsl:if test="$p_output-mode = 'number'">
                <xsl:value-of
                    select="$v_month-names-and-numbers/descendant::tei:listNym[@corresp = $v_calendar]/tei:nym[tei:form = $p_input-month]/@n"
                />
            </xsl:if>
        </xsl:variable>
        <xsl:if test="$v_month = ''">
            <xsl:message terminate="yes">
                <xsl:text>There is no output data for your input of $p_input-lang="</xsl:text><xsl:value-of select="$p_input-lang"/><xsl:text>" and $p_calendar="</xsl:text><xsl:value-of select="$p_calendar"/><xsl:text>".</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="$v_month"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function takes a date string as input and outputs a correctly formatted tei:date node with @when and @when-custom attributes depending on the calendar </xd:desc>
        <xd:param name="p_input">Input date: string following the ISO standard of 'yyyy-mm-dd'.</xd:param>
        <xd:param name="p_input-calendar">Specify the input calendar with '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal' or '#cal_gregorian'</xd:param>
        <xd:param name="p_format-output">Bolean toggles between input string and formatted output string.</xd:param>
        <xd:param name="p_inluce-weekday">Bolean toggle whether or not to include the weekday in the formatted output.</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-format-iso-string-to-tei">
        <xsl:param name="p_input"/>
        <!-- pCal selects the input calendar: '#cal_gregorian', '#cal_julian', '#cal_ottomanfiscal', or '#cal_islamic' -->
        <xsl:param name="p_input-calendar"/>
        <!-- p_format-output establishes whether the original input or a formatted date is produced as output / content of the tei:date node. Values are 'original' and 'formatted' -->
        <xsl:param name="p_format-output"/>
        <xsl:param name="p_inluce-weekday"/>
        <xsl:variable name="v_lang" select="'ar-Latn-x-ijmes'"/>
        <xsl:variable name="vDateTei1">
            <xsl:element name="tei:date">
                <!-- attributes -->
                <xsl:attribute name="xml:lang" select="$v_lang"/>
                <xsl:choose>
                    <xsl:when test="$p_input-calendar = '#cal_gregorian'">
                        <!-- test if input string is ISO format -->
                        <xsl:attribute name="when" select="$p_input"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$p_input-calendar = '#cal_julian'">
                                <xsl:variable name="v_gregorian-date" select="oape:date-convert-julian-to-gregorian($p_input)"/>
                                <xsl:attribute name="when" select="$v_gregorian-date"/>
                                <xsl:attribute name="when-custom" select="$p_input"/>
                                <xsl:attribute name="calendar" select="$p_input-calendar"/>
                                <xsl:attribute name="datingMethod" select="$p_input-calendar"/>
                            </xsl:when>
                            <xsl:when test="$p_input-calendar = '#cal_ottomanfiscal'">
                                <xsl:variable name="v_gregorian-date" select="oape:date-convert-ottoman-fiscal-to-gregorian($p_input)"/>
                                <xsl:attribute name="when" select="$v_gregorian-date"/>
                                <xsl:attribute name="when-custom" select="$p_input"/>
                                <xsl:attribute name="calendar" select="$p_input-calendar"/>
                                <xsl:attribute name="datingMethod" select="$p_input-calendar"/>
                            </xsl:when>
                            <xsl:when test="$p_input-calendar = '#cal_islamic'">
                                <xsl:variable name="v_gregorian-date" select="oape:date-convert-islamic-to-gregorian($p_input)"/>
                                <xsl:attribute name="when" select="$v_gregorian-date"/>
                                <xsl:attribute name="when-custom" select="$p_input"/>
                                <xsl:attribute name="calendar" select="$p_input-calendar"/>
                                <xsl:attribute name="datingMethod" select="$p_input-calendar"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- element content -->
                <xsl:choose>
                    <xsl:when test="$p_format-output = true()">
                        <xsl:variable name="v_month" select="format-number(number(tokenize($p_input, '([.,&quot;\-])')[2]), '0')"/>
                        <xsl:value-of select="format-number(number(tokenize($p_input, '([.,&quot;\-])')[3]), '0')"/>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$p_input-calendar = '#cal_gregorian'">
                                <xsl:value-of select="oape:date-convert-months($v_month, 'name', 'en', $p_input-calendar)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="oape:date-convert-months($v_month, 'name', $v_lang, $p_input-calendar)"/>
                                <!--<xsl:choose>
                                    <xsl:when test="$p_input-calendar = '#cal_julian'">
                                        <xsl:call-template name="f_date-MonthNameNumber">
                                            <xsl:with-param name="pDate" select="$p_input"/>
                                            <xsl:with-param name="pMode" select="'name'"/>
                                            <xsl:with-param name="p_input-lang" select="'JIjmes'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$p_input-calendar = '#cal_ottomanfiscal'">
                                        <xsl:call-template name="f_date-MonthNameNumber">
                                            <xsl:with-param name="pDate" select="$p_input"/>
                                            <xsl:with-param name="pMode" select="'name'"/>
                                            <xsl:with-param name="p_input-lang" select="'MIjmes'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$p_input-calendar = '#cal_islamic'">
                                        <xsl:call-template name="f_date-MonthNameNumber">
                                            <xsl:with-param name="pDate" select="$p_input"/>
                                            <xsl:with-param name="pMode" select="'name'"/>
                                            <xsl:with-param name="p_input-lang" select="'HIjmes'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                </xsl:choose>-->
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="tokenize($p_input, '([.,&quot;\-])')[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$p_input"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="vDateTei2">
            <xsl:for-each select="$vDateTei1/tei:date">
                <xsl:copy>
                    <xsl:for-each select="@*">
                        <xsl:copy/>
                    </xsl:for-each>
                    <xsl:value-of select="."/>
                    <xsl:if test="$p_inluce-weekday = true()">
                        <xsl:variable name="v_weekday" select="format-date(@when, '[FNn]')"/>
                        <xsl:value-of select="concat(', ', $v_weekday)"/>
                    </xsl:if>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$vDateTei2"/>
        <!-- this part of the template can produce a calendarDesc element for the teiHeader -->
        <!--<xsl:choose><xsl:when test="$pCal='G'"/><xsl:otherwise><xsl:element name="tei:calendarDesc"><xsl:choose><xsl:when test="$pCal='J'"><xsl:element name="tei:calendar"><xsl:attribute name="xml:id">cal_julian</xsl:attribute><xsl:element name="tei:p"><xsl:text>Reformed Julian calendar beginning the Year with 1 January. In the Ottoman context usually referred to as Rūmī.</xsl:text></xsl:element></xsl:element></xsl:when><xsl:when test="$pCal='M'"><xsl:element name="tei:calendar"><xsl:attribute name="xml:id">cal_ottomanfiscal</xsl:attribute><xsl:element name="tei:p"><xsl:text>Ottoman fiscal calendar: an Old Julian calendar beginning the Year with 1 March. The year count is synchronised to the Islamic Hijrī calendar. In the Ottoman context usually referred to as Mālī or Rūmī.</xsl:text></xsl:element></xsl:element></xsl:when><xsl:when test="$pCal='H'"><xsl:element name="tei:calendar"><xsl:attribute name="xml:id">cal_islamic</xsl:attribute><xsl:element name="tei:p"><xsl:text>Islamic Hijrī calendar beginning the Year with 1 Muḥarram.</xsl:text></xsl:element></xsl:element></xsl:when></xsl:choose></xsl:element></xsl:otherwise></xsl:choose>-->
    </xsl:function>
    
    <xd:doc>
        <xd:desc> This template normalises a date input string mixing digits and month names. The output is "yyyy-mm-dd" </xd:desc>
        <xd:param name="p_input"/>
        <xd:param name="p_input-lang"/>
        <xd:param name="p_input-calendar"/>
    </xd:doc>
    <xsl:template name="f_date-NormaliseInput">
        <xsl:param name="p_input" select="'1000'"/>
        <!-- This parameter selects the input language according to @xml:lang -->
        <xsl:param name="p_input-lang"/>
        <!-- this parameter selects the input calendar using the TEI's @datingMethod -->
        <xsl:param name="p_input-calendar"/>
        <xsl:variable name="vDateNode">
            <!-- 1) match yyyy-mm-dd -->
            <xsl:analyze-string regex="\s*(\d{{4}})\-(\d{{2}})\-(\d{{2}})\s*" select="$p_input">
                <xsl:matching-substring>
                    <xsl:element name="tss:date">
                        <xsl:attribute name="day"
                            select="format-number(number(regex-group(3)), '00')"/>
                        <xsl:attribute name="month" select="regex-group(2)"/>
                        <xsl:attribute name="year" select="regex-group(1)"/>
                    </xsl:element>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!-- 2) match dd MNn yyyy -->
                    <xsl:analyze-string regex="\s*(\d+)\s+(.*)\s+(\d{{4}})\s*" select="$p_input">
                        <xsl:matching-substring>
                            <xsl:variable name="vMonth">
                                <xsl:call-template name="f_date-MonthNameNumber">
                                    <xsl:with-param name="pMode" select="'number'"/>
                                    <xsl:with-param name="pMonth"
                                        select="translate(regex-group(2), '.', '')"/>
                                    <xsl:with-param name="p_input-lang" select="$p_input-lang"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:element name="tss:date">
                                <xsl:attribute name="day"
                                    select="format-number(number(regex-group(1)), '00')"/>
                                <xsl:attribute name="month"
                                    select="format-number(number($vMonth), '00')"/>
                                <xsl:attribute name="year" select="regex-group(3)"/>
                            </xsl:element>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <!-- 3) match MNn dd, yyyy -->
                            <xsl:analyze-string regex="\s*(.*)\s+(\d+),\s+(\d{{4}})\s*"
                                select="$p_input">
                                <xsl:matching-substring>
                                    <xsl:variable name="vMonth">
                                        <xsl:call-template name="f_date-MonthNameNumber">
                                            <xsl:with-param name="pMode" select="'number'"/>
                                            <xsl:with-param name="pMonth"
                                                select="translate(regex-group(1), '.', '')"/>
                                            <xsl:with-param name="p_input-lang"
                                                select="$p_input-lang"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:element name="tss:date">
                                        <xsl:attribute name="day"
                                            select="format-number(number(regex-group(2)), '00')"/>
                                        <xsl:attribute name="month"
                                            select="format-number(number($vMonth), '00')"/>
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
            select="concat($vDateNode/tss:date/@year, '-', $vDateNode/tss:date/@month, '-', $vDateNode/tss:date/@day)"
        />
    </xsl:template>
    <!-- v1e -->
    
    <xd:doc>
        <xd:desc> this template generates a list of incremented dates in any calendar with a transformation into another calendar
            it might be used for computing the gregorian dates of the first day of Ramadan, anniversary of the Sultan's 
            accession to the throne etc. </xd:desc>
        <xd:param name="p_onset"/>
        <xd:param name="p_terminus"/>
        <xd:param name="p_increment-period"/>
        <xd:param name="p_increment-by"/>
        <xd:param name="p_input-calendar"/>
        <xd:param name="p_output-calendar"/>
    </xd:doc>
    <xsl:template name="f_date-increment">
        <!-- this param selects the date, format: 'yyyy-mm-dd' -->
        <xsl:param name="p_onset"/>
        <!-- sets the end date -->
        <xsl:param name="p_terminus"/>
        <!-- select what to increment: 'year', 'month', or 'day' -->
        <xsl:param name="p_increment-period" select="'year'"/>
        <!-- select the incremental step -->
        <xsl:param as="xs:integer" name="p_increment-by" select="1"/>
        <!-- select input calendar by means of the tei @datingMethod attribute -->
        <xsl:param name="p_input-calendar"/>
        <!-- select output calendar by means of the tei @datingMethod attribute -->
        <xsl:param name="p_output-calendar"/>
        <!-- this param selects the conversion calendars: 'H2G', 'G2H', 'G2J', 'J2G', 'H2J', 'J2H', and 'none' -->
        <!--<xsl:param name="pCalendars"/><xsl:variable name="vInputCal" select="substring($pCalendars,1,1)"/>-->
        <xsl:if test="xs:date($p_onset) &lt;= xs:date($p_terminus)">
            <xsl:variable name="v_onset-converted-to-output-calendar">
                <xsl:choose>
                    <xsl:when
                        test="$p_input-calendar = '#cal_gregorian' and $p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-gregorian-to-islamic($p_onset)"/>
                        <!--<xsl:call-template name="f_date-convert-gregorian-to-islamic">
                            <xsl:with-param name="p_gregorian-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:when
                        test="$p_input-calendar = '#cal_islamic' and $p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-islamic-to-gregorian($p_onset)"/>
                        <!--<xsl:call-template name="f_date-convert-islamic-to-gregorian">
                            <xsl:with-param name="p_islamic-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:when
                        test="$p_input-calendar = '#cal_gregorian' and $p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-gregorian-to-julian($p_onset)"/>
                       <!-- <xsl:call-template name="f_date-convert-gregorian-to-julian">
                            <xsl:with-param name="p_gregorian-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:when
                        test="$p_input-calendar = '#cal_julian' and $p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-to-gregorian($p_onset)"/>
                        <!--<xsl:call-template name="f_date-convert-julian-to-gregorian">
                            <xsl:with-param name="p_julian-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:when
                        test="$p_input-calendar = '#cal_islamic' and $p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-islamic-to-julian($p_onset)"/>
                       <!-- <xsl:call-template name="f_date-convert-islamic-to-julian">
                            <xsl:with-param name="p_islamic-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:when
                        test="$p_input-calendar = '#cal_julian' and $p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-to-islamic($p_onset)"/>
                        <!--<xsl:call-template name="f_date-convert-julian-to-islamic">
                            <xsl:with-param name="p_julian-date" select="$p_onset"/>
                        </xsl:call-template>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$p_onset"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_incremented-date">
                <xsl:choose>
                    <xsl:when test="$p_increment-period = 'year'">
                        <xsl:value-of
                            select="xs:date($p_onset) + xs:yearMonthDuration(concat('P', $p_increment-by, 'Y'))"
                        />
                    </xsl:when>
                    <xsl:when test="$p_increment-period = 'month'">
                        <xsl:value-of
                            select="xs:date($p_onset) + xs:yearMonthDuration(concat('P0Y', $p_increment-by, 'M'))"
                        />
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <!--<xsl:value-of select="$p_onset"/><xsl:text>= </xsl:text><xsl:value-of select="$v_onset-converted-to-output-calendar"/><xsl:text>,
            </xsl:text>-->
            <!--<xsl:call-template name="f_date-format-iso-string-to-tei">
                <xsl:with-param name="p_input" select="$p_onset"/>
                <xsl:with-param name="p_input-calendar" select="$p_input-calendar"/>
                <xsl:with-param name="p_format-output" select="true()"/>
                <xsl:with-param name="p_inluce-weekday" select="false()"/>
            </xsl:call-template>-->
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($p_onset, $p_input-calendar, true(), false())"/>
            <xsl:call-template name="f_date-increment">
                <xsl:with-param name="p_onset" select="$v_incremented-date"/>
                <xsl:with-param name="p_terminus" select="$p_terminus"/>
                <xsl:with-param name="p_increment-period" select="$p_increment-period"/>
                <xsl:with-param name="p_increment-by" select="$p_increment-by"/>
                <xsl:with-param name="p_input-calendar" select="$p_input-calendar"/>
                <xsl:with-param name="p_output-calendar" select="$p_output-calendar"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc> this template increments Julian days between two dates.
            The output is a set of comma-separarted values</xd:desc>
        <xd:param name="p_julian-dayStart"/>
        <xd:param name="p_julian-dayStop"/>
        <xd:param name="pIntervalDays"/>
    </xd:doc>
    <xsl:template name="f_date-incrementJD">
        <xsl:param name="p_julian-dayStart"/>
        <xsl:param name="p_julian-dayStop"/>
        <xsl:param name="pIntervalDays" select="1"/>
        <xsl:value-of select="$p_julian-dayStart"/>
        <xsl:if test="$p_julian-dayStart &lt; $p_julian-dayStop">
            <xsl:text>,
            </xsl:text>
            <xsl:call-template name="f_date-incrementJD">
                <xsl:with-param name="p_julian-dayStart"
                    select="$p_julian-dayStart + $pIntervalDays"/>
                <xsl:with-param name="p_julian-dayStop" select="$p_julian-dayStop"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc> this template is used to normalise and convert the date strings found in the BOA online catalogue </xd:desc>
        <xd:param name="pDateString"/>
    </xd:doc>
    <xsl:template name="f_date-Boa">
        <xsl:param name="pDateString"/>
        <xsl:choose>
            <xsl:when test="contains($pDateString, 'Miladî')">
                <xsl:analyze-string regex="(\d+)/(\d+)/(\d{{4}})" select="$pDateString">
                    <xsl:matching-substring>
                        <xsl:variable name="v_gregorian-date">
                            <xsl:value-of
                                select="concat(regex-group(3), '-', format-number(number(regex-group(2)), '00'), '-', format-number(number(regex-group(1)), '00'))"
                            />
                        </xsl:variable>
                        <xsl:value-of select="$v_gregorian-date"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="contains($pDateString, 'Hicrî')">
                <xsl:analyze-string regex="(\d+)/(.{{2}})/(\d{{4}})" select="$pDateString">
                    <xsl:matching-substring>
                        <xsl:variable name="v_islamic-month">
                            <xsl:call-template name="f_date-MonthNameNumber">
                                <xsl:with-param name="pMonth" select="regex-group(2)"/>
                                <xsl:with-param name="pMode" select="'number'"/>
                                <xsl:with-param name="p_input-lang" select="'HBoa'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="v_islamic-date">
                            <xsl:value-of
                                select="concat(regex-group(3), '-', format-number(number($v_islamic-month), '00'), '-', format-number(number(regex-group(1)), '00'))"
                            />
                        </xsl:variable>
                        <xsl:variable name="v_gregorian-date" select="oape:date-convert-islamic-to-gregorian($v_islamic-date)">
                            <!--<xsl:call-template name="f_date-convert-islamic-to-gregorian">
                                <xsl:with-param name="p_islamic-date" select="$v_islamic-date"/>
                            </xsl:call-template>-->
                        </xsl:variable>
                        <xsl:value-of select="$v_gregorian-date"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <!-- Mālī, which they call Rūmī is marked by not being marked -->
                <xsl:analyze-string regex="(\d+)/(.{{2}})/(\d{{4}})" select="$pDateString">
                    <xsl:matching-substring>
                        <xsl:variable name="v_ottoman-fiscal-month">
                            <xsl:call-template name="f_date-MonthNameNumber">
                                <xsl:with-param name="pMonth" select="regex-group(2)"/>
                                <xsl:with-param name="pMode" select="'number'"/>
                                <xsl:with-param name="p_input-lang" select="'MBoa'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="v_ottoman-fiscal-date">
                            <xsl:value-of
                                select="concat(regex-group(3), '-', format-number(number($v_ottoman-fiscal-month), '00'), '-', format-number(number(regex-group(1)), '00'))"
                            />
                        </xsl:variable>
                        <xsl:variable name="v_gregorian-date" select="oape:date-convert-ottoman-fiscal-to-gregorian($v_ottoman-fiscal-date)">
                            <!--<xsl:call-template name="f_date-convert-ottoman-fiscal-to-gregorian">
                                <xsl:with-param name="p_ottoman-fiscal-date"
                                    select="$v_ottoman-fiscal-date"/>
                            </xsl:call-template>-->
                        </xsl:variable>
                        <xsl:value-of select="$v_gregorian-date"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>