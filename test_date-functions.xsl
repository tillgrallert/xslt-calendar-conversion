<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs oape"
    version="3.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:include href="/BachUni/BachBibliothek/GitHub/xslt-calendar-conversion/date-function.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="v_gregorian-date" select="'1900-01-01'"/>
        <xsl:variable name="v_islamic-date" select="oape:date-convert-gregorian-to-islamic($v_gregorian-date)"/>
        <xsl:variable name="v_julian-date" select="oape:date-convert-gregorian-to-julian($v_gregorian-date)"/>
        <xsl:variable name="v_ottoman-fiscal-date" select="oape:date-convert-gregorian-to-ottoman-fiscal($v_gregorian-date)"/>
        <!-- output -->
        <div>
        <h1>Input: <xsl:value-of select="$v_gregorian-date"/></h1>
        <ul>
            <li>Islamic date: <xsl:value-of select="$v_islamic-date"/> aH (
                <xsl:value-of select="oape:date-convert-islamic-to-gregorian($v_islamic-date)"/> / 
                <xsl:value-of select="oape:date-convert-islamic-to-julian($v_islamic-date)"/> R)
            <xsl:copy-of select="oape:date-format-iso-string-to-tei($v_islamic-date, '#cal_islamic', true(), false())"></xsl:copy-of></li>
            <li>Julian date: <xsl:value-of select="$v_julian-date"/> R (
                <xsl:value-of select="oape:date-convert-julian-to-gregorian($v_julian-date)"/> / 
                <xsl:value-of select="oape:date-convert-julian-to-islamic($v_julian-date)"/> aH /
                <xsl:value-of select="oape:date-convert-julian-to-ottoman-fiscal($v_julian-date)"/> M)</li>
            <li>Ottoman fiscal date: <xsl:value-of select="$v_ottoman-fiscal-date"/> M (
                <xsl:value-of select="oape:date-convert-ottoman-fiscal-to-gregorian($v_ottoman-fiscal-date)"/> / 
                <xsl:value-of select="oape:date-convert-ottoman-fiscal-to-julian($v_ottoman-fiscal-date)"/> R / 
                <xsl:value-of select="oape:date-convert-ottoman-fiscal-to-islamic($v_ottoman-fiscal-date)"/> aH)</li>
        </ul>
        </div>
    </xsl:template>
    
</xsl:stylesheet>