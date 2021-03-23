<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" 
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
            <xd:p>NOTE: the stylesheet has been extensively updated to make use of functions instead of templates.
                the documentation does not, yet, reflect these changes.</xd:p>
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
    <!-- Julian day for Gregorian 0001-01-01 -->
    <xsl:param name="p_julian-day-for-gregorian-base" select="1721425.5"/>
    <!-- Julian day for Hijri 0001-01-01 -->
    <xsl:param name="p_julian-day-for-islamic-base" select="1948439.5"/>
    <!-- Julian day for Coptic 0001-01-01 -->
    <xsl:param name="p_julian-day-for-coptic-base" select="1825029"/>
    <!-- treshhold year for deciding whether a date belongs to the Ottomann fiscal or the Julian calendar -->
    <xsl:param name="p_ottoman-fiscal-last-year" select="1338"/>
    <xsl:param name="p_islamic-last-year" select="number(substring(oape:date-convert-calendars(string(format-date(current-date(), '[Y0001]-[M01]-[D01]')), '#cal_gregorian', '#cal_islamic'), 1, 4))" as="xs:double"/>
    <xsl:param name="p_debug" select="true()"/>
    
   <!-- translate strings -->
    <xsl:variable name="v_string-digits-latn" select="'0123456789'"/>
    <xsl:variable name="v_string-digits-ar" select="'٠١٢٣٤٥٦٧٨٩'"/>
    <xsl:variable name="v_string-ar" select="'إأئؤ'"/>
    <xsl:variable name="v_string-ar-normalised" select="'اايو'"/>
    
    <!-- regex variables -->
    <xsl:variable name="v_regex-date-yyyy-mm-dd" select="'(\d{4})\-(\d{1,2})\-(\d{1,2})'"/>
    <xsl:variable name="v_regex-date-dd-MNn-yyyy" select="'(\d{1,2})\s+((\w+\s){1,2}?)(\s*سنة)?\s*(\d{3,4})'"/>
    <xsl:variable name="v_regex-date-MNn-dd-yyyy" select="'(\w+)\s+(\d+),\s+(\d{4})'"/>
    <xsl:variable name="v_regex-date-calendars" select="'((هـ|هجرية*)|(م[\W]|ملادية*|للمسيح))'"/>
    <xsl:variable name="v_regex-date-yyyy-cal" select="concat('سنة\s+(\d{3,4})', '\s+', $v_regex-date-calendars, '*')"/>
    <xsl:variable name="v_regex-date-dd-MNn-yyyy-cal" select="concat($v_regex-date-dd-MNn-yyyy, '\s+', $v_regex-date-calendars, '*')"/>
    
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
        <xd:desc>This function converts Hijrī Years to Gregorian year ranges </xd:desc>
        <xd:param name="p_islamic-year"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-islamic-year-to-gregorian">
        <xsl:param name="p_islamic-year"/>
        <xsl:variable name="v_islamic-date-onset" select="concat($p_islamic-year, '-01-01')"/>
        <xsl:variable name="v_gregorian-date-onset" select="oape:date-convert-calendars($v_islamic-date-onset, '#cal_islamic', '#cal_gregorian')"/>
        <xsl:variable name="v_islamic-date-terminus" select="concat($p_islamic-year, '-12-29')"/>
        <xsl:variable name="v_gregorian-date-terminus" select="oape:date-convert-calendars($v_islamic-date-terminus, '#cal_islamic', '#cal_gregorian')"/>
        <xsl:variable name="v_output">
        <xsl:value-of select="substring($v_gregorian-date-onset, 1, 4)"/>
        <!-- test if the Hijrī year spans more than one Gregorian year (this is not the case for 1295, 1329  -->
        <xsl:if test="substring($v_gregorian-date-onset, 1, 4) != substring($v_gregorian-date-terminus, 1, 4)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring($v_gregorian-date-terminus, 1, 4)"/>
            <!--<xsl:choose>
                <!-\- the range 1899-1900 must be accounted for -\->
                <xsl:when test="substring($v_gregorian-date-terminus, 3, 2) = '00'">
                    <xsl:value-of select="substring($v_gregorian-date-terminus, 1, 4)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($v_gregorian-date-terminus, 3, 2)"/>
                </xsl:otherwise>
            </xsl:choose>-->
        </xsl:if>
        </xsl:variable>
        <xsl:value-of select="$v_output"/>
    </xsl:function>
    <!-- this template converts Gregorian to Mali dates (i.e. Julian, commencing on 1 Mar, minus 584 years from 13 March 1840 onwards)  -->
    
   <!-- <xd:doc>
        <xd:desc>This function converts Gregorian to Ottoman fiscal / Mālī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_gregorian-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-gregorian-to-ottoman-fiscal">
        <xsl:param name="p_gregorian-date"/>
        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-gregorian-to-julian($p_gregorian-date))"/>
    </xsl:function>-->
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
        <!-- Algorithm as given in Meeus, Astronomical Algorithms, Chapter 7, page 61 -->
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
        <xd:desc>This function converts Coptic dates to Julian Day </xd:desc>
        <xd:param name="p_coptic-date">A coptic date, provided in the form "yyyy-mm-dd".</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-convert-coptic-to-julian-day">
        <xsl:param name="p_coptic-date"/>
        <xsl:variable name="v_coptic-year"
            select="number(tokenize($p_coptic-date, '([.,&quot;\-])')[1])"/>
        <xsl:variable name="v_coptic-month"
            select="number(tokenize($p_coptic-date, '([.,&quot;\-])')[2])"/>
        <xsl:variable name="v_coptic-day"
            select="number(tokenize($p_coptic-date, '([.,&quot;\-])')[3])"/>
        <!-- each month of the coptic year has 12 days, save for the 13th, which has only 5 or 6, depending on the leap year -->
        <xsl:variable name="v_julian-day-of-input">
            <!-- days of past years -->
            <xsl:variable name="v_y" select="floor(365.25 * ($v_coptic-year -1) +0.30)"/>
            <!-- days of previous months in the current year -->
            <xsl:variable name="v_m" select="30 * ($v_coptic-month -1)"/>
            <!-- days of the current month -->
            <xsl:variable name="v_d" select="$v_coptic-day"/>
            <xsl:value-of select="$v_y + $v_m + $v_d + $p_julian-day-for-coptic-base"/>
        </xsl:variable>
        <xsl:value-of select="$v_julian-day-of-input"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function converts Julian Days to Coptic dates </xd:desc>
        <xd:param name="p_julian-day">A Julian day</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-convert-julian-day-to-coptic">
        <xsl:param name="p_julian-day"/>
        <!-- substract the coptic epoch -->
        <xsl:variable name="v_base-day" select="$p_julian-day - $p_julian-day-for-coptic-base"/>
        <!-- year: divide by 365.25 -->
        <xsl:variable name="v_coptic-year" select="ceiling($v_base-day div 365.25)"/>
        <!-- remaining days of the current year -->
        <xsl:variable name="v_a" select="$v_base-day - (($v_coptic-year -1) * 365.25)"/>
        <!-- divide by length of months -->
        <xsl:variable name="v_coptic-month" select="ceiling($v_a div 30)"/>
        <!--  -->
        <xsl:variable name="v_c" select="($v_a div 30) - floor($v_a div 30)"/>
        <xsl:variable name="v_coptic-day" select="ceiling($v_c * 30)"/>
        <xsl:value-of select="concat(format-number($v_coptic-year,'0000'),'-',format-number($v_coptic-month,'00'),'-',format-number($v_coptic-day,'00'))"/>
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
            <xsl:variable name="v_islamic-date" select="oape:date-convert-calendars($p_julian-date,'#cal_julian', '#cal_islamic')"/>
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
                <xsl:variable name="v_gregorian-date" select="oape:date-convert-calendars($p_julian-date, '#cal_julian', '#cal_gregorian')"/>
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
                        <xsl:variable name="v_julian-date" select="oape:date-convert-calendars(concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month, '-', $v_ottoman-fiscal-day),'#cal_gregorian', '#cal_julian')"/>
                        <xsl:value-of
                            select="concat(format-number($v_ottoman-fiscal-year + 584, '0000'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[2]), '00'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:when>
                    <!-- works correctly -->
                    <xsl:otherwise>
                        <xsl:variable name="v_julian-date" select="oape:date-convert-calendars(concat(format-number($v_julian-year, '0000'), '-', $v_ottoman-fiscal-month + 2, '-', $v_ottoman-fiscal-day),'#cal_gregorian', '#cal_julian')"/>
                        <xsl:value-of
                            select="concat(format-number($v_julian-year, '0000'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[2]), '00'), '-', format-number(number(tokenize($v_julian-date, '([.,&quot;\-])')[3]), '00'))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--<xd:doc>
        <xd:desc>This function converts Ottoman fiscal / Mālī to Gregorian dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_ottoman-fiscal-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-to-gregorian">
        <xsl:param name="p_ottoman-fiscal-date"/>
        <xsl:value-of select="oape:date-convert-julian-to-gregorian(oape:date-convert-ottoman-fiscal-to-julian($p_ottoman-fiscal-date))"/>
    </xsl:function>-->
    
    <xd:doc>
        <xd:desc>This function converts Mali Years to Gregorian year ranges </xd:desc>
        <xd:param name="p_ottoman-fiscal-year"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-year-to-gregorian">
        <xsl:param name="p_ottoman-fiscal-year"/>
        <xsl:variable name="v_ottoman-fiscal-date-onset" select="concat($p_ottoman-fiscal-year, '-01-01')"/>
        <xsl:variable name="v_gregorian-date-onset" select="oape:date-convert-calendars($v_ottoman-fiscal-date-onset,'#cal_ottomanfiscal', '#cal_gregorian')">
        </xsl:variable>
        <xsl:variable name="v_ottoman-fiscal-date-terminus" select="concat($p_ottoman-fiscal-year, '-12-29')"/>
        <xsl:variable name="v_gregorian-date-terminus" select="oape:date-convert-calendars($v_ottoman-fiscal-date-terminus, '#cal_ottomanfiscal', '#cal_gregorian')">
        </xsl:variable>
        <xsl:value-of select="substring($v_gregorian-date-onset, 1, 4)"/>
        <xsl:if test="substring($v_gregorian-date-onset, 1, 4) != substring($v_gregorian-date-terminus, 1, 4)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring($v_gregorian-date-terminus, 3, 2)"/>
        </xsl:if>
    </xsl:function>
    
    <!--<xd:doc>
        <xd:desc>This function converts Ottoman fiscal / Mālī to Islamic Hjrī dates. Input and output are ISO-conformant date strings.</xd:desc>
        <xd:param name="p_ottoman-fiscal-date"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-ottoman-fiscal-to-islamic">
        <xsl:param name="p_ottoman-fiscal-date"/>
        <xsl:value-of select="oape:date-convert-julian-to-islamic(oape:date-convert-ottoman-fiscal-to-julian($p_ottoman-fiscal-date))"/>
    </xsl:function>-->
    
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
        <xd:param name="p_input-lang">Takes valid values of @xml:lang as input.</xd:param>
        <xd:param name="p_calendar">Toggles between calendars. Uses references to @xml:ids as input: '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal' or '#cal_gregorian'</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-convert-months">
        <xsl:param name="p_input-month"/>
        <!-- pMode has value 'name' or 'number' and toggles the output format -->
        <xsl:param name="p_output-mode" as="xs:string"/>
        <!-- select the input lang by means of @xml:lang -->
        <xsl:param name="p_input-lang" as="xs:string"/>
        <!-- select the input lang by means of TEI's @datingMethod -->
        <xsl:param name="p_calendar" as="xs:string"/>
        <!-- check if all necessary input is provided -->
        <xsl:if test="not($p_output-mode = ('name', 'number'))">
            <xsl:message terminate="no">
                <xsl:text>The value of $p_output-mode must be either 'name' or 'number'.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:if test="not($p_calendar = ('#cal_islamic', '#cal_julian', '#cal_ottomanfiscal', '#cal_gregorian', '#cal_coptic'))">
            <xsl:message terminate="no">
                <xsl:text>The value of $p_calendar is "</xsl:text><xsl:value-of select="$p_calendar"/><xsl:text>" must be either '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal', '#cal_coptic' or '#cal_gregorian'.</xsl:text>
            </xsl:message>
        </xsl:if>
        <!-- month names are similar for rūmī /sharqī / Julian and Gregorian calendars -->
        <xsl:if test="$p_output-mode = ('name', 'number') and $p_calendar = ('#cal_islamic', '#cal_julian', '#cal_ottomanfiscal', '#cal_gregorian', '#cal_coptic')">
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
        <xsl:variable name="v_month">
            <xsl:if test="$p_output-mode = 'name' and xs:integer($p_input-month)">
                <!-- check if the nymList for the calendar contains the month name -->
                <xsl:value-of
                    select="$v_month-names-and-numbers/descendant::tei:listNym[@corresp = $v_calendar]/tei:nym[@n = $p_input-month]/tei:form[@xml:lang = $p_input-lang][1]"
                />
            </xsl:if>
            <xsl:if test="$p_output-mode = 'number'">
                <!-- normalise the input month for arabic -->
                <xsl:variable name="v_input-month" select="translate($p_input-month, $v_string-ar, $v_string-ar-normalised)"/>
                <xsl:value-of
                    select="$v_month-names-and-numbers/descendant::tei:listNym[@corresp = $v_calendar]/tei:nym[tei:form = $v_input-month]/@n"
                />
            </xsl:if>
        </xsl:variable>
        <xsl:if test="$v_month = ''">
            <xsl:message terminate="yes">
                <xsl:text>There is no output data for the month of "</xsl:text><xsl:value-of select="$p_input-month"/><xsl:text>" using $p_input-lang="</xsl:text><xsl:value-of select="$p_input-lang"/><xsl:text>" and $p_calendar="</xsl:text><xsl:value-of select="$p_calendar"/><xsl:text>".</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="$v_month"/>
        </xsl:if>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function takes a date string as input and outputs a correctly formatted tei:date node with @when and @when-custom attributes depending on the calendar </xd:desc>
        <xd:param name="p_input">Input date: string following the ISO standard of 'yyyy-mm-dd'.</xd:param>
        <xd:param name="p_input-calendar">Specify the input calendar with '#cal_islamic', '#cal_julian', '#cal_ottomanfiscal', '#cal_gregorian', or '#cal_coptic'</xd:param>
        <xd:param name="p_format-output">Bolean toggles between input string and formatted output string.</xd:param>
        <xd:param name="p_include-weekday">Bolean toggle whether or not to include the weekday in the formatted output.</xd:param>
        <xd:param name="p_lang">Accepts values of @xml:lang</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-format-iso-string-to-tei">
        <xsl:param name="p_input"/>
        <!-- pCal selects the input calendar: '#cal_gregorian', '#cal_julian', '#cal_ottomanfiscal', '#cal_islamic' or '#cal_coptic' -->
        <xsl:param name="p_input-calendar"/>
        <!-- p_format-output establishes whether the original input or a formatted date is produced as output / content of the tei:date node. Values are 'false()' and 'true()' -->
        <xsl:param name="p_format-output"/>
        <xsl:param name="p_include-weekday"/>
        <xsl:param name="p_lang"/>
        <xsl:variable name="vDateTei1">
            <xsl:element name="date">
                <!-- attributes -->
                <xsl:attribute name="calendar" select="$p_input-calendar"/>
                <xsl:attribute name="xml:lang" select="$p_lang"/>
                <xsl:choose>
                    <xsl:when test="$p_input-calendar = '#cal_gregorian'">
                        <!-- test if input string is ISO format -->
                        <xsl:attribute name="when" select="$p_input"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="v_gregorian-date" select="oape:date-convert-calendars($p_input,$p_input-calendar, '#cal_gregorian')"/>
                        <xsl:attribute name="when" select="$v_gregorian-date"/>
                        <xsl:attribute name="when-custom" select="$p_input"/>
                        <xsl:attribute name="datingMethod" select="$p_input-calendar"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- element content -->
                <xsl:choose>
                    <!-- format date -->
                    <xsl:when test="$p_format-output = true()">
                        <xsl:variable name="v_day" select="format-number(number(tokenize($p_input, '([.,&quot;\-])')[3]), '0')"/>
                        <xsl:variable name="v_month" select="format-number(number(tokenize($p_input, '([.,&quot;\-])')[2]), '0')"/>
                        <xsl:variable name="v_year" select="tokenize($p_input, '([.,&quot;\-])')[1]"/>
                        <!-- day -->
                        <xsl:choose>
                            <xsl:when test="$p_lang = 'ar'">
                                <xsl:value-of select="translate($v_day, $v_string-digits-latn, $v_string-digits-ar)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$v_day"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                        <!-- month -->
                        <xsl:value-of select="oape:date-convert-months($v_month, 'name', $p_lang, $p_input-calendar)"/>
                        <xsl:text> </xsl:text>
                        <!-- year -->
                        <xsl:choose>
                            <xsl:when test="$p_lang = 'ar'">
                                <xsl:text>سنة </xsl:text>
                                <xsl:value-of select="translate($v_year, $v_string-digits-latn, $v_string-digits-ar)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$v_year"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- fallback: replicate input -->
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
                    <xsl:if test="$p_include-weekday = true()">
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
        <xd:desc>This function takes a tei:date node as input and outputs a correctly formatted tei:date node describing the month this date falls in, depending of the calendar of the input with @from, @from-custom, @to and @to-custom attributes. The language of the output can be selected through a parameter</xd:desc>
        <xd:param name="p_date">Input date: string following the ISO standard of 'yyyy-mm-dd'.</xd:param>
        <xd:param name="p_output-language">Accepts values of @xml:lang</xd:param>
    </xd:doc>
    <xsl:function name="oape:date-convert-tei-to-current-month">
        <xsl:param name="p_date"/>
        <xsl:param name="p_output-language"/>
        <!-- check if this is a Gregorian date or not -->
        <xsl:variable name="v_calendar">
            <xsl:choose>
                <xsl:when test="$p_date/@when-custom and $p_date/@datingMethod">
                    <xsl:value-of select="$p_date/@datingMethod"/>
                </xsl:when>
                <xsl:when test="$p_date/@when-custom">
                    <xsl:message>
                        <xsl:text>The input date is missing the mandatory @datingMethod attribute</xsl:text>
                    </xsl:message>
                </xsl:when>
                <xsl:when test="$p_date/@when">
                    <xsl:value-of select="'#cal_gregorian'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:text>The input date has no machine-readible data</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_date-iso">
            <xsl:choose>
                <xsl:when test="$v_calendar = ''">
                    <xsl:message>
                        <xsl:text>No calendar found</xsl:text>
                    </xsl:message>
                </xsl:when>
                <xsl:when test="$v_calendar = '#cal_gregorian'">
                    <xsl:value-of select="$p_date/@when"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$p_date/@when-custom"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_month" select="number(substring($v_date-iso,6,2))"/>
        <xsl:variable name="v_year" select="substring($v_date-iso,1,4)"/>
        <xsl:variable name="v_first-of-month" select="concat(substring($v_date-iso,1,8),'01')"/>
        <!-- last of month: find the Julian day for the first of the following month, subtract one, and convert to the target calendar -->
        <xsl:variable name="v_last-of-month">
            <xsl:variable name="v_first-of-following-month" select="concat($v_year,'-',format-number($v_month + 1,'00'),'-01')"/>
            <xsl:variable name="v_julian-day" select="oape:date-convert-date-to-julian-day($v_first-of-following-month, $v_calendar)"/>
            <xsl:value-of select="oape:date-convert-julian-day-to-date($v_julian-day - 1, $v_calendar)"/>
        </xsl:variable>
        <xsl:variable name="v_date-tei">
            <xsl:element name="date">
                <xsl:attribute name="calendar" select="$v_calendar"/>
                <xsl:attribute name="xml:lang" select="$p_output-language"/>
                <!-- machine-readible dating in attributes -->
                <xsl:choose>
                    <xsl:when test="$v_calendar = '#cal_gregorian'">
                        <xsl:attribute name="from" select="$v_first-of-month"/>
                        <xsl:attribute name="to" select="$v_last-of-month"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="from" select="oape:date-convert-calendars($v_first-of-month,$v_calendar, '#cal_gregorian')"/>
                        <xsl:attribute name="to" select="oape:date-convert-calendars($v_last-of-month,$v_calendar, '#cal_gregorian')"/>
                        <xsl:attribute name="from-custom" select="$v_first-of-month"/>
                        <xsl:attribute name="to-custom" select="$v_last-of-month"/>
                        <xsl:attribute name="datingMethod" select="$v_calendar"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- content: formatted date by language -->
                <xsl:if test="$p_output-language = 'ar'">
                    <xsl:text>شهر </xsl:text>
                </xsl:if>
                <xsl:value-of select="oape:date-convert-months($v_month, 'name', $p_output-language ,$v_calendar)"/>
                <xsl:text> </xsl:text>
                <!-- if the target language is Arabic, then the digits should be translated -->
                <xsl:choose>
                    <xsl:when test="$p_output-language = 'ar'">
                        <xsl:text>سنة </xsl:text>
                        <xsl:value-of select="translate($v_year, $v_string-digits-latn, $v_string-digits-ar)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$v_year"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:variable>
        <!-- debugging -->
        <!--<xsl:message>
            <xsl:value-of select="$v_calendar"/>
            <xsl:value-of select="$v_month"/>
            <xsl:value-of select="$v_first-of-month"/>
            <xsl:value-of select="$v_last-of-month"/>
        </xsl:message>-->
        <!-- output -->
        <xsl:copy-of select="$v_date-tei"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This funtion normalises a date input string mixing digits and month names. The output is "yyyy-mm-dd" </xd:desc>
        <xd:param name="p_input"/>
        <xd:param name="p_input-lang"/>
        <xd:param name="p_input-calendar"/>
    </xd:doc>
    <!-- PROBLEM: I got the following output: when-custom="1331-08-13١٣ شعبان ١٣٣١هـ" -->
<!-- FIXED -->
    <xsl:function name="oape:date-normalise-input">
        <xsl:param name="p_input" as="xs:string"/>
        <!-- This parameter selects the input language according to @xml:lang -->
        <xsl:param name="p_input-lang" as="xs:string"/>
        <!-- this parameter selects the input calendar using the TEI's @datingMethod or @calendar -->
        <xsl:param name="p_input-calendar" as="xs:string"/>
        <!-- if the input language is Arabic, numericals must be first normalised. Otherwise they are read as characters -->
        <xsl:variable name="v_input-normalised" select="normalize-space(translate($p_input, $v_string-digits-ar, $v_string-digits-latn))"/>
        <xsl:variable name="v_date-output">
            <xsl:analyze-string regex="\s*(\d{{4}})\-(\d{{1,2}})\-(\d{{1,2}})\s*|\s*(\d+)\s+(.*)\s+(\d{{4}})\s*.*|\s*(.*)\s+(\d+),\s+(\d{{4}})\s*.*" select="normalize-space($v_input-normalised)">
                <xsl:matching-substring>
                    <xsl:choose>
                        <!-- 1) match yyyy-mm-dd: this works as expected -->
                        <xsl:when test="matches($v_input-normalised,'\s*(\d{4})\-(\d{1,2})\-(\d{1,2})\s*')">
                            <!-- output -->
                            <xsl:value-of select="regex-group(1)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number(regex-group(2)), '00')"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number(regex-group(3)), '00')"/>
                        </xsl:when>
                        <!-- 2) match dd MNn yyyy -->
                        <xsl:when test="matches($v_input-normalised,'\s*(\d+)\s+(.*)\s+(\d{4})\s*(هـ)*')">
                            <xsl:variable name="v_month-name" select="translate(regex-group(5), '.', '')"/>
                            <xsl:variable name="v_month-name" select="replace($v_month-name,'\s*سنة\s*','')"/>
                            <xsl:variable name="v_month-number" select="oape:date-convert-months($v_month-name, 'number', $p_input-lang, $p_input-calendar)"/>
                            <!-- output -->
                            <xsl:value-of select="regex-group(6)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number($v_month-number), '00')"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number(regex-group(4)), '00')"/>
                        </xsl:when>
                        <!-- 3) match MNn dd, yyyy -->
                        <xsl:when test="matches($v_input-normalised,'\s*(.*)\s+(\d+),\s+(\d{4})\s*(هـ)*')">
                            <xsl:variable name="v_month-name" select="translate(regex-group(7), '.', '')"/>
                            <xsl:variable name="v_month-name" select="replace($v_month-name,'\s*سنة\s*','')"/>
                            <xsl:variable name="v_month-number" select="oape:date-convert-months($v_month-name, 'number', $p_input-lang, $p_input-calendar)"/>
                            <!-- output -->
                            <xsl:value-of select="regex-group(9)"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number($v_month-number), '00')"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="format-number(number(regex-group(8)), '00')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="$p_input"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <!-- debugging -->
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:text>Input: </xsl:text><xsl:value-of select="$p_input"/><xsl:text>; calendar: </xsl:text><xsl:value-of select="$p_input-calendar"/><xsl:text>; output: </xsl:text><xsl:copy-of select="$v_date-output"/>
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="normalize-space($v_date-output)"/>
    </xsl:function>
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
        <xd:param name="p_lang"/>
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
        <xsl:param name="p_lang"/>
        <!-- this param selects the conversion calendars: 'H2G', 'G2H', 'G2J', 'J2G', 'H2J', 'J2H', and 'none' -->
        <!--<xsl:param name="pCalendars"/><xsl:variable name="vInputCal" select="substring($pCalendars,1,1)"/>-->
        <xsl:if test="xs:date($p_onset) &lt;= xs:date($p_terminus)">
            <xsl:variable name="v_onset-converted-to-output-calendar">
                <xsl:value-of select="oape:date-convert-calendars($p_onset, $p_input-calendar, $p_output-calendar)"/>
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
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($p_onset, $p_input-calendar, true(), false(), $p_lang)"/>
            <xsl:call-template name="f_date-increment">
                <xsl:with-param name="p_onset" select="$v_incremented-date"/>
                <xsl:with-param name="p_terminus" select="$p_terminus"/>
                <xsl:with-param name="p_increment-period" select="$p_increment-period"/>
                <xsl:with-param name="p_increment-by" select="$p_increment-by"/>
                <xsl:with-param name="p_input-calendar" select="$p_input-calendar"/>
                <xsl:with-param name="p_output-calendar" select="$p_output-calendar"/>
                <xsl:with-param name="p_lang" select="$p_lang"/>
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
                        <xsl:variable name="v_gregorian-date" select="oape:date-convert-calendars($v_islamic-date, '#cal_islamic', '#cal_gregorian')"/>
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
                        <xsl:variable name="v_gregorian-date" select="oape:date-convert-calendars($v_ottoman-fiscal-date, '#cal_ottomanfiscal', '#cal_gregorian')"/>
                        <xsl:value-of select="$v_gregorian-date"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
     <xd:doc>
        <xd:desc>This function converts calendars. Input and output are ISO strings.</xd:desc>
        <xd:param name="p_input"/>
         <xd:param name="p_input-calendar"/>
        <xd:param name="p_output-calendar"/>
    </xd:doc>
    <xsl:function name="oape:date-convert-calendars">
        <xsl:param name="p_input"/>
        <xsl:param name="p_input-calendar" as="xs:string"/>
        <xsl:param name="p_output-calendar" as="xs:string"/>
        <!-- test if the input is an ISO date -->
        <xsl:if test="not(matches($p_input, '\d{4}-\d{2}-\d{2}'))">
            <xsl:message terminate="yes">
                <xsl:text>The input </xsl:text>
                <xsl:value-of select="$p_input"/>
                <xsl:text> is not an ISO date</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:choose>
            <!-- input = output -->
            <xsl:when test="$p_input-calendar = $p_output-calendar">
                <xsl:value-of select="$p_input"/>
            </xsl:when>
            <!-- input: gregorian -->
            <xsl:when test="$p_input-calendar = '#cal_gregorian'">
                <xsl:variable name="v_julian-day-of-input" select="oape:date-convert-gregorian-to-julian-day($p_input)"/>
                <xsl:choose>
                    <xsl:when test="$p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-julian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-islamic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-julian-day-to-julian($v_julian-day-of-input))"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-coptic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Output calendar has not been recognised.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- input: Islamic -->
             <xsl:when test="$p_input-calendar = '#cal_islamic'">
                <xsl:variable name="v_julian-day-of-input" select="oape:date-convert-islamic-to-julian-day($p_input)"/>
                <xsl:choose>
                    <xsl:when test="$p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-julian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-julian-day-to-julian($v_julian-day-of-input))"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-coptic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Output calendar has not been recognised.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- input: Julian -->
             <xsl:when test="$p_input-calendar = '#cal_julian'">
                <xsl:variable name="v_julian-day-of-input" select="oape:date-convert-julian-to-julian-day($p_input)"/>
                <xsl:choose>
                    <xsl:when test="$p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-islamic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal($p_input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-coptic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Output calendar has not been recognised.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- input: Ottoman fiscal -->
             <xsl:when test="$p_input-calendar = '#cal_ottomanfiscal'">
                <xsl:variable name="v_julian-day-of-input" select="oape:date-convert-julian-to-julian-day(oape:date-convert-ottoman-fiscal-to-julian($p_input))"/>
                <xsl:choose>
                    <xsl:when test="$p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-islamic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-julian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-coptic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Output calendar has not been recognised.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- input: Coptic -->
             <xsl:when test="$p_input-calendar = '#cal_coptic'">
                <xsl:variable name="v_julian-day-of-input" select="oape:date-convert-coptic-to-julian-day($p_input)"/>
                <xsl:choose>
                    <xsl:when test="$p_output-calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-islamic($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-julian($v_julian-day-of-input)"/>
                    </xsl:when>
                    <xsl:when test="$p_output-calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-julian-day-to-julian($v_julian-day-of-input))"/>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Output calendar has not been recognised.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- fallback -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>Input calendar has not been recognised.</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- the function tries to establish a calender based on an input -->
    <xd:doc>
        <xd:desc>This function tries to establish calendars for an input date string on the basis of month names. This approach will fail with calendars that use the same month names, such as the Gregorian and the new Julian calendar. The preference for any one of them needs to be set with an additional calendar.</xd:desc>
        <xd:param name="p_input"/>
         <xd:param name="p_mode"/>
    </xd:doc>
    <xsl:function name="oape:date-establish-calendar">
        <!-- $p_input is a date or a month name -->
        <xsl:param name="p_input" as="xs:string"/>
        <!-- modes: date, month -->
        <xsl:param name="p_mode" as="xs:string"/>
        <!-- extract the month name from the input -->
        <!-- to do: remove harakat, hamza, etc for Arabic words -->
        <xsl:variable name="v_month-name" select="if ($p_mode = 'date') then (oape:date-extract-month-name($p_input)) else ($p_input)"/>
        <xsl:variable name="v_month-name" select="normalize-space(translate($v_month-name, $v_string-ar, $v_string-ar-normalised))"/>
        <!-- check if the month name is found in our reference table -->
        <xsl:choose>
            <xsl:when test="$v_month-name = ''">
                <xsl:message>
                    <xsl:text>I cannot try to establish a calendar without a month name.</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="$v_month-names-and-numbers/descendant::tei:form = $v_month-name">
                <xsl:variable name="v_calendar" select="$v_month-names-and-numbers/descendant-or-self::tei:listNym[descendant::tei:form = $v_month-name]"/>
                <!-- test if there are more than one calendars with this month name -->
                <xsl:choose>
                    <xsl:when test="count($v_calendar/descendant-or-self::tei:listNym) > 1">
                        <!-- debugging -->
                        <xsl:message>
                            <xsl:text>Found more than one calendar for "</xsl:text><xsl:value-of select="$p_input"/><xsl:text>": </xsl:text>
                            <xsl:for-each select="$v_calendar/descendant-or-self::tei:listNym">
                                <xsl:value-of select="@corresp"/>
                                <xsl:if test="not(position() = last())">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:message>
                        <!-- Ottoman fiscal, Julian, and Gregorian calendars share the same month names. Try to differentiate through the year -->
                        <!-- there are regions, such as Egypt, that did not make regular use of the Julian calendar. If month names come from this region, we could automatically switch calendars  -->
                        <xsl:choose>
                            <xsl:when test="$p_mode = 'date' and $v_calendar/descendant-or-self::tei:listNym/@corresp = '#cal_julian'">
                            <xsl:variable name="v_year" select="number(replace($p_input, '^.*(\d{4}).*$', '$1'))"/>
                            <xsl:variable name="v_calendar">
                                <xsl:choose>
                                    <xsl:when test="$v_year &lt;= $p_ottoman-fiscal-last-year">
                                        <xsl:text>#cal_ottomanfiscal</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$v_calendar/descendant::tei:form[. = $v_month-name]/@xml:lang = 'ar-EG'" >
                                        <xsl:text>#cal_gregorian</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>#cal_julian</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:message>
                                <xsl:text>The input "</xsl:text><xsl:value-of select="$v_year"/><xsl:text>" most likely indicates the calendar: </xsl:text>
                                <xsl:value-of select="$v_calendar"/>
                            </xsl:message>
                            <xsl:value-of select="$v_calendar"/>
                        </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'NA'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- a single hit: correct Julian to Gregorian for Egyptian contexts -->
                    <xsl:when test="$v_calendar/descendant-or-self::tei:listNym/@corresp = '#cal_julian' and $v_calendar/descendant::tei:form[. = $v_month-name]/@xml:lang = 'ar-EG'">
                        <xsl:text>#cal_gregorian</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- debugging -->
                        <xsl:if test="$p_debug = true()">
                            <xsl:message>
                                <xsl:text>The input "</xsl:text><xsl:value-of select="$p_input"/><xsl:text>" indicates the calendar: </xsl:text>
                                <xsl:value-of select="$v_calendar/descendant-or-self::tei:listNym/@corresp"/>
                            </xsl:message>
                        </xsl:if>
                        <xsl:value-of select="$v_calendar/descendant-or-self::tei:listNym/@corresp"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>Could not establish a calendar. The input "</xsl:text><xsl:value-of select="$v_month-name"/><xsl:text>"</xsl:text>
                    <xsl:text> was not found in the reference file of month names</xsl:text>
                </xsl:message>
                <xsl:value-of select="'NA'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>This function extracts likely month names from a text string. Output is a text string with a likely month name or 'NA' in cases that no such string was found.</xd:desc>
        <xd:param name="p_input"/>
    </xd:doc>
    <xsl:function name="oape:date-extract-month-name">
        <xsl:param name="p_input" as="xs:string"/>
        <xsl:variable name="v_input-normalised" select="normalize-space(translate($p_input, $v_string-digits-ar, $v_string-digits-latn))"/>
            <!-- <xsl:analyze-string regex="\s*(\d{{4}})\-(\d{{1,2}})\-(\d{{1,2}})\s*|\s*(\d+)\s+(.*)\s+(\d{{4}})\s*|\s*(.*)\s+(\d+),\s+(\d{{4}})\s*" select="normalize-space($v_input-normalised)"> -->
        <xsl:analyze-string regex="{concat($v_regex-date-yyyy-mm-dd, '|', $v_regex-date-dd-MNn-yyyy, '|', $v_regex-date-MNn-dd-yyyy)}" select="normalize-space($v_input-normalised)">
                 <xsl:matching-substring>
                    <xsl:choose>
                        <!-- 1) match yyyy-mm-dd: cannot guess calendar -->
                        <xsl:when test="matches(.,concat('(^|\D)', $v_regex-date-yyyy-mm-dd))">
                            <!-- regex groups: 3 -->
                            <xsl:message>
                                <xsl:text>No month name present</xsl:text>
                            </xsl:message>
                        </xsl:when>
                        <!-- 2) match dd MNn yyyy: guess based on month name -->
                        <xsl:when test="matches(.,concat('(^|\D)', $v_regex-date-dd-MNn-yyyy))">
                            <!-- regex groups: 3 -->
                            <xsl:value-of select="translate(regex-group(5), '.', '')"/>
                        </xsl:when>
                        <!-- 3) match MNn dd, yyyy: guess based on month name -->
                        <xsl:when test="matches(.,concat('(^|\W)', $v_regex-date-MNn-dd-yyyy))">
                            <!-- regex groups: 3 -->
                            <xsl:value-of select="translate(regex-group(7), '.', '')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'NA'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:message>
                        <xsl:text>The input "</xsl:text><xsl:value-of select="$v_input-normalised"/><xsl:text>" contains no month name.</xsl:text>
                    </xsl:message>
                    <xsl:value-of select="'NA'"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="oape:date-convert-date-to-julian-day">
        <xsl:param name="p_date"/>
        <xsl:param name="p_calendar"/>
        <!-- test if the input is an ISO date -->
        <xsl:if test="not(matches($p_date, '\d{4}-\d{2}-\d{2}'))">
            <xsl:message terminate="yes">
                <xsl:text>The input </xsl:text>
                <xsl:value-of select="$p_date"/>
                <xsl:text> is not an ISO date</xsl:text>
            </xsl:message>
        </xsl:if>
                <!-- convert by calendar -->
                <xsl:choose>
                    <xsl:when test="$p_calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-gregorian-to-julian-day($p_date)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-coptic-to-julian-day($p_date)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-to-julian-day($p_date)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-islamic-to-julian-day($p_date)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-julian-day(oape:date-convert-ottoman-fiscal-to-julian($p_date))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>The calendar </xsl:text><xsl:value-of select="$p_calendar"/><xsl:text> is not supported</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
    </xsl:function>
    <xsl:function name="oape:date-convert-julian-day-to-date">
        <xsl:param name="p_julian-day"/>
        <xsl:param name="p_calendar"/>
                <!-- convert by calendar -->
                <xsl:choose>
                    <xsl:when test="$p_calendar = '#cal_gregorian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-gregorian($p_julian-day)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_coptic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-coptic($p_julian-day)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_julian'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-julian($p_julian-day)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_islamic'">
                        <xsl:value-of select="oape:date-convert-julian-day-to-islamic($p_julian-day)"/>
                    </xsl:when>
                    <xsl:when test="$p_calendar = '#cal_ottomanfiscal'">
                        <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal(oape:date-convert-julian-day-to-julian($p_julian-day))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>The calendar </xsl:text><xsl:value-of select="$p_calendar"/><xsl:text> is not supported</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
           
    </xsl:function>
    
    <xsl:variable name="v_month-names-and-numbers">
            <tei:listNym corresp="#cal_islamic">
                <tei:nym n="1">
                    <!-- <tei:form xml:lang="tr">Mart</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Muḥarram</tei:form>
                    <tei:form xml:lang="ar">محرم</tei:form>
                    <tei:form xml:lang="ar">المحرم</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">M</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Muḥ</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <!-- <tei:form xml:lang="tr">Nisan</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ṣafar</tei:form>
                    <tei:form xml:lang="ar">صفر</tei:form>
<!--                    <tei:form xml:lang="ar">صفار</tei:form>-->
                    <tei:form xml:lang="ota-Latn-x-boa">S</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ṣaf</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <!-- <tei:form xml:lang="tr">Mayıs</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rabīʿ al-awwal</tei:form>
                    <tei:form xml:lang="ar">ربيع الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ra</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Rab I</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <!-- <tei:form xml:lang="tr">Haziran</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rabīʿ al-thānī</tei:form>
                    <tei:form xml:lang="ar">ربيع الثاني</tei:form>
                    <tei:form xml:lang="ar">ربيع الآخر</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">R</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Rab II</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <!-- <tei:form xml:lang="tr">Temmuz</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Jumāda al-ulā</tei:form>
                    <tei:form xml:lang="ar">جمادى الاولى</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ca</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Jum I</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <!-- <tei:form xml:lang="tr">Ağustos</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Jumāda al-thāniya</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Jumāda al-ākhira</tei:form>
                    <tei:form xml:lang="ar">جمادى الآخرة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">C</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Jum II</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <!-- <tei:form xml:lang="tr">Eylül</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Rajab</tei:form>
                    <tei:form xml:lang="ar">رجب</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">B</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Raj</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <!-- <tei:form xml:lang="tr">Ekim</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shaʿbān</tei:form>
                    <tei:form xml:lang="ar">شعبان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ş</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Shaʿ</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <!-- <tei:form xml:lang="tr">Kasım</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ramaḍān</tei:form>
                    <tei:form xml:lang="ar">رمضان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">N</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ram</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <!-- <tei:form xml:lang="tr">Aralık</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shawwāl</tei:form>
                    <tei:form xml:lang="ar">شوال</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">L</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Shaw</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <!-- <tei:form xml:lang="tr">Ocak</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Dhū al-qaʿda</tei:form>
                    <tei:form xml:lang="ar">ذو القعدة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Za</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Dhu I</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <!-- <tei:form xml:lang="tr">Şubat</tei:form> -->
                    <tei:form xml:lang="ar-Latn-x-ijmes">Dhū al-ḥijja</tei:form>
                    <tei:form xml:lang="ar">ذو الحجة</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Z</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Dhu II</tei:form>
                </tei:nym>
            </tei:listNym>
            <tei:listNym corresp="#cal_ottomanfiscal">
                <tei:nym n="1">
                    <tei:form xml:lang="tr">Mart</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Mārt</tei:form>
                    <tei:form xml:lang="ar">مارت</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ar</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Mārt</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <tei:form xml:lang="tr">Nisan</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Nīsān</tei:form>
<!--                    <tei:form xml:lang="ar-Latn-x-ijmes">Nīs</tei:form>-->
                    <tei:form xml:lang="ar">نيسان</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ni</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Nīs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Nis</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <tei:form xml:lang="tr">Mayıs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Māyis</tei:form>
                    <tei:form xml:lang="ar">مايس</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ma</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Māy</tei:form>
                    
                </tei:nym>
                <tei:nym n="4">
                    <tei:form xml:lang="tr">Haziran</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ḥazīrān</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ḥaz</tei:form>
                    <tei:form xml:lang="ar">حزيران</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ha</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <tei:form xml:lang="tr">Temmuz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tammūz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tam</tei:form>
                    <tei:form xml:lang="ar">تموز</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Te</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <tei:form xml:lang="tr">Ağustos</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aghusṭūs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Agh</tei:form>
                    <tei:form xml:lang="ar">اغسطوس</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ağ</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <tei:form xml:lang="tr">Eylül</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aylūl</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ayl</tei:form>
                    <tei:form xml:lang="ar">ايلول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ey</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <tei:form xml:lang="tr">Ekim</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-awwal</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tish I</tei:form>
                    <tei:form xml:lang="ar">تسرين الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Tş</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <tei:form xml:lang="tr">Kasım</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-thānī</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tish II</tei:form>
                    <tei:form xml:lang="ar">تسرين الثاني</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Tn</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <tei:form xml:lang="tr">Aralık</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-awwal</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kān I</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kan I</tei:form>
                    <tei:form xml:lang="ar">كانون الاول</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ke</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <tei:form xml:lang="tr">Ocak</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-thānī</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kān II</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kan II</tei:form>
                    <tei:form xml:lang="ar">كانون الثاني</tei:form>
                    <tei:form xml:lang="ota-Latn-x-boa">Ks</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <tei:form xml:lang="tr">Şubat</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shubāṭ</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Shub</tei:form>
                    <tei:form xml:lang="ar">شباط</tei:form>
                </tei:nym>
            </tei:listNym>
            <!-- these are also the month names of the Gregorian calendar -->
            <tei:listNym corresp="#cal_julian">
                <tei:nym n="1">
                    <tei:form xml:lang="tr">Ocak</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-thānī</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kān II</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kan II</tei:form>
                    <tei:form xml:lang="ar">كانون الثاني</tei:form>
                    <tei:form xml:lang="ar-EG">يناير</tei:form>
                    <tei:form xml:lang="en">January</tei:form>
                    <tei:form xml:lang="en">Jan</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <tei:form xml:lang="tr">Şubat</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Shubāṭ</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Shub</tei:form>
                    <tei:form xml:lang="ar">شباط</tei:form>
                    <tei:form xml:lang="ar-EG">فبراير</tei:form>
                    <tei:form xml:lang="en">February</tei:form>
                    <tei:form xml:lang="en">Feb</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <tei:form xml:lang="tr">Mart</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ādhār</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ādhār</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Adhar</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Mār</tei:form>
                    <tei:form xml:lang="ar">آذار</tei:form>
                    <tei:form xml:lang="ar-EG">مارس</tei:form>
                    <tei:form xml:lang="en">March</tei:form>
                    <tei:form xml:lang="en">Mar</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <tei:form xml:lang="tr">Nisan</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Nīsān</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Nīs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Nis</tei:form>
                    <tei:form xml:lang="ar">نيسان</tei:form>
                    <tei:form xml:lang="ar-EG">ابريل</tei:form>
                    <tei:form xml:lang="en">April</tei:form>
                    <tei:form xml:lang="en">Apr</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <tei:form xml:lang="tr">Mayıs</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ayyār</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ayyār</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ayyar</tei:form>
                    <tei:form xml:lang="ar">ايار</tei:form>
                    <tei:form xml:lang="ar-EG">مايو</tei:form>
                    <tei:form xml:lang="en">May</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <tei:form xml:lang="tr">Haziran</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ḥazīrān</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ḥaz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Haz</tei:form>
                    <tei:form xml:lang="ar">حزيران</tei:form>
                    <tei:form xml:lang="ar-EG">يونيو</tei:form>
                    <tei:form xml:lang="ar-EG">يونيه</tei:form>
                    <tei:form xml:lang="en">June</tei:form>
                    <tei:form xml:lang="en">Jun</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <tei:form xml:lang="tr">Temmuz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tammūz</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tam</tei:form>
                    <tei:form xml:lang="ar">تموز</tei:form>
                    <tei:form xml:lang="ar-EG">يوليو</tei:form>
                    <tei:form xml:lang="en">July</tei:form>
                    <tei:form xml:lang="en">Jul</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <tei:form xml:lang="tr">Ağustos</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Āb</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Āb</tei:form>
                    <tei:form xml:lang="ar">آب</tei:form>
                    <tei:form xml:lang="ar-EG">اغسطس</tei:form>
                    <tei:form xml:lang="en">August</tei:form>
                    <tei:form xml:lang="en">Aug</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <tei:form xml:lang="tr">Eylül</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Aylūl</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Ayl</tei:form>
                    <tei:form xml:lang="ar">ايلول</tei:form>
                    <tei:form xml:lang="ar-EG">سبتمبر</tei:form>
                    <tei:form xml:lang="en">September</tei:form>
                    <tei:form xml:lang="en">Sep</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <tei:form xml:lang="tr">Ekim</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-awwal</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tish I</tei:form>
                    <tei:form xml:lang="ar">تسرين الاول</tei:form>
                    <tei:form xml:lang="ar-EG">اكتوبر</tei:form>
                    <tei:form xml:lang="en">October</tei:form>
                    <tei:form xml:lang="en">Oct</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <tei:form xml:lang="tr">Kasım</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tishrīn al-thānī</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Tish II</tei:form>
                    <tei:form xml:lang="ar">تسرين الثاني</tei:form>
                    <tei:form xml:lang="ar-EG">نوفمبر</tei:form>
                    <tei:form xml:lang="ar-EG">نوڤمبر</tei:form>
                    <tei:form xml:lang="en">November</tei:form>
                    <tei:form xml:lang="en">Nov</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <tei:form xml:lang="tr">Aralık</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kānūn al-awwal</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kān I</tei:form>
                    <tei:form xml:lang="ar-Latn-x-sente">Kan I</tei:form>
                    <tei:form xml:lang="ar">كانون الاول</tei:form>
                    <tei:form xml:lang="ar-EG">دسمبر</tei:form>
                    <tei:form xml:lang="ar-EG">ديسمبر</tei:form>
                    <tei:form xml:lang="en">December</tei:form>
                    <tei:form xml:lang="en">Dec</tei:form>
                </tei:nym>
            </tei:listNym>
            <tei:listNym corresp="#cal_coptic">
                <tei:nym n="1">
                    <tei:form xml:lang="ar">توت</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Tūt</tei:form>
                </tei:nym>
                <tei:nym n="2">
                    <tei:form xml:lang="ar">بابة</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Bāba</tei:form>
                </tei:nym>
                <tei:nym n="3">
                    <tei:form xml:lang="ar">هاتور</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Hātūr</tei:form>
                </tei:nym>
                <tei:nym n="4">
                    <tei:form xml:lang="ar">كيهك</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Kiyahk</tei:form>
                </tei:nym>
                <tei:nym n="5">
                    <tei:form xml:lang="ar">طوبة</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Ṭūba</tei:form>
                </tei:nym>
                <tei:nym n="6">
                    <tei:form xml:lang="ar">امشير</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Amshīr</tei:form>
                </tei:nym>
                <tei:nym n="7">
                    <tei:form xml:lang="ar">برمهات</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Baramhāt</tei:form>
                </tei:nym>
                <tei:nym n="8">
                    <tei:form xml:lang="ar">برمودة</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Baramūda</tei:form>
                </tei:nym>
                <tei:nym n="9">
                    <tei:form xml:lang="ar">بشنس</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Bashans</tei:form>
                </tei:nym>
                <tei:nym n="10">
                    <tei:form xml:lang="ar">بؤونة</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Baʾūna</tei:form>
                </tei:nym>
                <tei:nym n="11">
                    <tei:form xml:lang="ar">أبيب</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Abīb</tei:form>
                </tei:nym>
                <tei:nym n="12">
                    <tei:form xml:lang="ar">مسرى</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Masrā</tei:form>
                </tei:nym>
                <tei:nym n="13">
                    <tei:form xml:lang="ar">نسيء</tei:form>
                    <tei:form xml:lang="ar-Latn-x-ijmes">Nasīʾ</tei:form>
                </tei:nym>
            </tei:listNym>
        </xsl:variable>
    
    <xsl:function name="oape:find-dates">
        <xsl:param as="xs:string" name="p_text"/>
        <xsl:param as="xs:string" name="p_id-change"/>
        <!-- the regex matches dd MNn yyyy with or without calendars -->
        <xsl:analyze-string regex="{concat('(^|\D)', $v_regex-date-dd-MNn-yyyy-cal, '|', '(^|\W)', $v_regex-date-yyyy-cal)}" select="$p_text">
            <xsl:matching-substring>
                <xsl:variable name="v_format">
                    <xsl:choose>
                        <!-- 9 regex groups -->
                        <xsl:when test="matches(., concat('(^|\D)', $v_regex-date-dd-MNn-yyyy-cal))">
                            <xsl:text>full</xsl:text>
                        </xsl:when>
                        <!-- 5 regex groups -->
                        <xsl:when test="matches(., concat('(^|\D)', $v_regex-date-yyyy-cal))">
                            <xsl:text>year</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="v_prefix">
                    <xsl:if test="$v_format = 'full'">
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:if>
                    <xsl:if test="$v_format = 'year'">
                        <xsl:value-of select="regex-group(10)"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="v_day">
                    <xsl:if test="$v_format = 'full'">
                        <xsl:value-of select="format-number(number(translate(regex-group(2), $v_string-digits-ar, $v_string-digits-latn)), '00')"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="v_month-name">
                    <xsl:if test="$v_format = 'full'">
                        <!--<xsl:value-of select="normalize-space(regex-group(3))"/>-->
                        <!-- this is a work around that corrects for some surprising matching. The regex should not have matched a trailing "sana", but it does -->
                        <xsl:value-of select="replace(normalize-space(regex-group(3)), '\s+(سنة|من)', '')"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable as="xs:double" name="v_year">
                    <xsl:if test="$v_format = 'full'">
                        <xsl:value-of select="format-number(number(translate(regex-group(6), $v_string-digits-ar, $v_string-digits-latn)), '0000')"/>
                    </xsl:if>
                    <xsl:if test="$v_format = 'year'">
                        <xsl:value-of select="format-number(number(translate(regex-group(11), $v_string-digits-ar, $v_string-digits-latn)), '0000')"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="v_calendar">
                    <xsl:if test="$v_format = 'full'">
                        <xsl:choose>
                            <xsl:when test="regex-group(7) = '' and $v_month-name != ''">
                                <!-- there is a weird error here: this function can return a calendar, for which the function oape:date-convert-months retruns a fatal error -->
                                <!-- this was a wrong assumption. the error returns when the calendar is explicitly stated -->
                                <!--<xsl:value-of select="oape:date-establish-calendar($v_month-name, 'month')"/>-->
                                <xsl:value-of select="oape:date-establish-calendar(concat($v_day, ' ', $v_month-name, ' ', $v_year), 'date')"/>
                            </xsl:when>
                            <xsl:when test="regex-group(8) != ''">
                                <xsl:text>#cal_islamic</xsl:text>
                            </xsl:when>
                            <xsl:when test="regex-group(9) != ''">
                                <xsl:text>#cal_gregorian</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>NA</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="$v_format = 'year'">
                        <xsl:choose>
                            <xsl:when test="regex-group(13) != ''">
                                <xsl:text>#cal_islamic</xsl:text>
                            </xsl:when>
                            <xsl:when test="regex-group(14) != ''">
                                <xsl:text>#cal_gregorian</xsl:text>
                            </xsl:when>
                            <xsl:when test="$v_year lt $p_islamic-last-year">
                                <xsl:text>#cal_islamic</xsl:text>
                            </xsl:when>
                            <xsl:when test="$v_year &gt;= $p_islamic-last-year">
                                <xsl:text>#cal_gregorian</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>NA</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:variable>
                <!--<xsl:message>
                    <xsl:value-of select="."/>
                    <xsl:text> = format: </xsl:text>
                    <xsl:value-of select="$v_format"/>
                    <xsl:text>, day: </xsl:text>
                    <xsl:value-of select="$v_day"/>
                    <xsl:text>, month: </xsl:text>
                    <xsl:value-of select="$v_month-name"/>
                    <xsl:text>, year: </xsl:text>
                    <xsl:value-of select="$v_year"/>
                    <xsl:text>, calendar: </xsl:text>
                    <xsl:value-of select="$v_calendar"/>
                </xsl:message>-->
                <xsl:choose>
                    <!-- if there is an calendar -->
                    <xsl:when test="$v_calendar != 'NA'">
                        <xsl:if test="$p_debug = true() and $v_format = 'full'">
                            <xsl:message>
                                <xsl:text>month: </xsl:text><xsl:value-of select="$v_month-name"/>
                                <xsl:text>, calendar: </xsl:text><xsl:value-of select="oape:date-establish-calendar($v_month-name, 'month')"/>
                                <xsl:text>, number: </xsl:text><xsl:value-of select="oape:date-convert-months($v_month-name, 'number', 'ar', $v_calendar)"/>
                            </xsl:message>
                        </xsl:if>
                        <xsl:variable name="v_date-iso">
                            <xsl:if test="$v_format = 'full'">
                                <!-- there is a weird error here: oape:date-convert-months retruns a fatal error for a combination of month names and calendars -->
                                <xsl:value-of
                                    select="concat(format-number($v_year, '0000'), '-', format-number(oape:date-convert-months($v_month-name, 'number', 'ar', $v_calendar), '00'), '-', format-number($v_day, '00'))"
                                />
                            </xsl:if>
                            <xsl:if test="$v_format = 'year'">
                                <xsl:value-of select="format-number($v_year, '0000')"/>
                            </xsl:if>
                        </xsl:variable>
                        <!-- construct TEI node -->
                        <xsl:value-of select="$v_prefix"/>
                        <xsl:element name="date">
                            <xsl:attribute name="change" select="concat('#', $p_id-change)"/>
                            <xsl:attribute name="calendar" select="$v_calendar"/>
                            <!-- responsibility and certainty -->
                            <xsl:attribute name="resp" select="'#xslt'"/>
                            <xsl:attribute name="cert">
                                <xsl:choose>
                                <!-- the confidence of calendar selection is generally high if based on an exiplicit information in the input string string -->
                                    <xsl:when test="$v_format = 'full' and regex-group(7) != ''">
                                        <xsl:text>high</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$v_format = 'year' and regex-group(12) != ''">
                                        <xsl:text>high</xsl:text>
                                    </xsl:when>
                                <!-- if the date string is full and the calendar was established as Islamic through month names, the confidence is high -->
                                    <xsl:when test="$v_format = 'full' and $v_calendar = '#cal_islamic'">
                                        <xsl:text>high</xsl:text>
                                    </xsl:when>
                                <!-- if the date string is full and the calendar Ottoman fiscal has been ruled out through a threshold year, the confidence is high -->
                                <!-- Ottoman fiscal is of medium high confidence as it is based on month names and an assumed threshold year -->
                                    <xsl:when test="$v_format = 'full' and $v_calendar = '#cal_ottomanfiscal'">
                                        <xsl:text>medium</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$v_format = 'full' and $v_calendar = ('#cal_julian', '#cal_gregorian')">
                                        <xsl:text>low</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$v_format = 'year' and regex-group(12) = ''">
                                        <xsl:text>low</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>undefined</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="xml:lang" select="'ar'"/>
                            <xsl:if test="$v_calendar != '#cal_gregorian'">
                                <xsl:attribute name="datingMethod" select="$v_calendar"/>
                                <xsl:attribute name="when-custom" select="$v_date-iso"/>
                                <xsl:if test="$v_format = 'full'">
                                    <xsl:attribute name="when" select="oape:date-convert-calendars($v_date-iso, $v_calendar, '#cal_gregorian')"/>
                                </xsl:if>
                                <xsl:if test="$v_format = 'year' and $v_calendar = '#cal_islamic'">
                                    <xsl:variable name="v_year-range" select="oape:date-convert-islamic-year-to-gregorian($v_date-iso)"/>
                                    <xsl:choose>
                                        <xsl:when test="matches($v_year-range, '\d-\d')">
                                            <xsl:attribute name="from" select="substring-before($v_year-range, '-')"/>
                                            <xsl:attribute name="to" select="substring-after($v_year-range, '-')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="when" select="$v_year-range"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:if>
                            <xsl:if test="$v_calendar = '#cal_gregorian'">
                                <xsl:attribute name="when" select="$v_date-iso"/>
                            </xsl:if>
                            <!-- content -->
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:element>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <!-- fallback -->
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:value-of select="."/>
                            <xsl:text> = format: </xsl:text>
                            <xsl:value-of select="$v_format"/>
                            <xsl:text>, day: </xsl:text>
                            <xsl:value-of select="$v_day"/>
                            <xsl:text>, month: </xsl:text>
                            <xsl:value-of select="$v_month-name"/>
                            <xsl:text>, year: </xsl:text>
                            <xsl:value-of select="$v_year"/>
                            <xsl:text>, calendar: </xsl:text>
                            <xsl:value-of select="$v_calendar"/>
                        </xsl:message>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
</xsl:stylesheet>
