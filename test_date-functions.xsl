<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs oape"
    version="3.0">
    <xsl:output method="html" indent="yes"/>
<!--    <xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>-->
    <xsl:include href="functions/date-functions.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="v_input" select="'10 August 1907'"/>
        <xsl:variable name="v_gregorian-date" select="oape:date-normalise-input($v_input,'en', '#cal_gregorian')"/>
<!--        <xsl:variable name="v_gregorian-date" select="oape:date-convert-julian-day-to-gregorian(oape:date-convert-coptic-to-julian-day('1609-10-07'))"/>-->
        <xsl:variable name="v_islamic-date" select="oape:date-convert-calendars($v_gregorian-date, '#cal_gregorian', 'https://www.wikidata.org/wiki/Q28892')"/>
        <xsl:variable name="v_julian-date" select="oape:date-convert-calendars($v_gregorian-date, '#cal_gregorian', 'https://www.wikidata.org/wiki/Q1279922')"/>
        <xsl:variable name="v_ottoman-fiscal-date" select="oape:date-convert-calendars($v_gregorian-date, '#cal_gregorian', '#cal_ottomanfiscal')"/>
        <xsl:variable name="v_coptic-date" select="oape:date-convert-calendars($v_gregorian-date,'#cal_gregorian', '#cal_coptic')"/>
        <!-- output -->
        <div>
        <h1>Input: <xsl:value-of select="$v_gregorian-date"/></h1>
        <ul>
            <li>Gregorian date: <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_gregorian-date, '#cal_gregorian', true(), true(),'ar')"/>
            </li>
            <li>Islamic date: <xsl:value-of select="$v_islamic-date"/> aH (
                <xsl:value-of select="oape:date-convert-calendars($v_islamic-date, '#cal_islamic', '#cal_gregorian')"/> / 
                <xsl:value-of select="oape:date-convert-calendars($v_islamic-date, '#cal_islamic', '#cal_julian')"/> R /
                <xsl:value-of select="oape:date-convert-calendars($v_islamic-date, '#cal_islamic', '#cal_ottomanfiscal')"/> M)
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_islamic-date, '#cal_islamic', true(), true(),'ar')"/>
            </li>
            <li>Julian date: <xsl:value-of select="$v_julian-date"/> R (
                <xsl:value-of select="oape:date-convert-calendars($v_julian-date, '#cal_julian', '#cal_gregorian')"/> / 
                <xsl:value-of select="oape:date-convert-calendars($v_julian-date, '#cal_julian', '#cal_islamic')"/> aH /
                <xsl:value-of select="oape:date-convert-calendars($v_julian-date, '#cal_julian', '#cal_ottomanfiscal')"/> M)
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_julian-date, '#cal_julian', true(), true(),'ar')"/>
            </li>
            <li>Ottoman fiscal date: <xsl:value-of select="$v_ottoman-fiscal-date"/> M (
                <xsl:value-of select="oape:date-convert-calendars($v_ottoman-fiscal-date, '#cal_ottomanfiscal', '#cal_gregorian')"/> / 
                <xsl:value-of select="oape:date-convert-calendars($v_ottoman-fiscal-date, '#cal_ottomanfiscal', '#cal_julian')"/> R / 
                <xsl:value-of select="oape:date-convert-calendars($v_ottoman-fiscal-date, '#cal_ottomanfiscal', '#cal_islamic')"/> aH)
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_ottoman-fiscal-date, '#cal_ottomanfiscal', true(), true(),'ar')"/>
            </li>
            <li>Coptic date: <xsl:value-of select="$v_coptic-date"/> C (
                )
                <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_coptic-date, '#cal_coptic', true(), true(),'ar')"/>
            </li>
        </ul>
        </div>
    </xsl:template>
    
</xsl:stylesheet>