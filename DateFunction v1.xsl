<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
        <desc>
            <p>
                XSL stylesheet for date conversions in XML.
            </p>
            <p>
                The stylesheet currenly supports conversions between four calendars using
                a calculation of the Julian Day: Gregorian, Julian, Ottoman fiscal (Mālī),
                and Hijrī calendars.
                Many of the calculations were adapted from John Walker's Calender Converter
                JavaScript functions (http://www.fourmilab.ch/documents/calendar/).
            </p>
            <p> Input and output are formatted as yyyy-mm-dd for the conversions between
                the four currently supported calendars.
                Abbreviavtions in the funcDateMonthNameNumber try to cut the Month names
                to three letters, as is established practice for English. In case of
                Arabic letters whose transcription requires two english letters, month 
                names can be longer than three english letters, i.e. Shub (for Shubāṭ),
                Tish (for Tishrīn), etc.
            </p>
            <p>This software is licensed as:
                
                Distributed under a Creative Commons Attribution-ShareAlike 3.0
                Unported License http://creativecommons.org/licenses/by-sa/3.0/ 
                
                
                This software is provided by the copyright holders and contributors
                "as is" and any express or implied warranties, including, but not
                limited to, the implied warranties of merchantability and fitness for
                a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental,
                special, exemplary, or consequential damages (including, but not
                limited to, procurement of substitute goods or services; loss of use,
                data, or profits; or business interruption) however caused and on any
                theory of liability, whether in contract, strict liability, or tort
                (including negligence or otherwise) arising in any way out of the use
                of this software, even if advised of the possibility of such damage.
            </p>
            <p>Author: Till Grallert</p>
        </desc>
    </doc>
    

    <!-- Julian day for Gregorian 0001-01-01 -->
    <xsl:variable name="vgJDGreg1" select="1721424.5"/>
    <!-- Julian day for Hijri 0001-01-01 -->
    <xsl:variable name="vgJDHijri1" select="1948439.5"/>

    <!-- This template determines whether Gregorian years are leap years. Returns y or n -->
    <xsl:template name="funcDateLeapG">
        <xsl:param name="pDateG"/>
        <xsl:param name="pYearG" select="number(tokenize($pDateG,'-')[1])"/>
        <!-- determines wether the year is a leap year: can be divided by four, but in centesial years divided by 400 -->
        <xsl:value-of
            select="if(($pYearG mod 4)=0 and (not((($pYearG mod 100)=0) and (not(($pYearG mod 400)=0)))))  then('y') else('n')"
        />
    </xsl:template>

    <!-- This template converts Gregorian to Julian Day -->
    <xsl:template name="funcDateG2JD">
        <xsl:param name="pDateG" select="'1899-1-1'"/>
        <xsl:param name="vYear" select="number(tokenize($pDateG,'-')[1])"/>
        <xsl:param name="vMonth" select="number(tokenize($pDateG,'-')[2])"/>
        <xsl:param name="vDay" select="number(tokenize($pDateG,'-')[3])"/>

        <!-- vLeap indicates when a year is a leap year -->
        <xsl:variable name="vLeapG">
            <xsl:call-template name="funcDateLeapG">
                <xsl:with-param name="pDateG" select="$pDateG"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- this DOES NOT provide exactly the same Julian date as the JS: the computation is off by one day. As this behaviour is triggered by the year, it can only follow from conditions that involve the year -->
        <!-- the calculation for the current day of the year works correctly -->
        <xsl:variable name="vA" select="(((367 * $vMonth) -362) div 12)"/>
        <xsl:variable name="vB"
            select="(if($vMonth &lt;=2) then(0) else (if($vLeapG='y') then(-1) else(-2)))"/>
        <xsl:variable name="vDayCurrentYear" select="floor($vA + $vB + $vDay)"/>
        <!-- the error lies in the calculation of the JD for the current year -->
        <xsl:variable name="vC" select="$vYear -1"/>
        <!-- for some unexplained reason, removing the substraction of one from the JDGreg1 ($vJDGreg1 -1) does the trick -->
        <xsl:variable name="vJDCurrentYear"
            select="($vgJDGreg1)
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
        <xsl:variable name="vDayG" select="($vWjd - $vDayG2JD) + 1"/>

        <xsl:value-of
            select="concat($vYearG,'-',format-number($vMonthG,'00'),'-',format-number($vDayG,'00'))"
        />
    </xsl:template>

    <!-- This template converts Hijrī to Julian Day -->
    <xsl:template name="funcDateH2JD">
        <xsl:param name="pDateH"/>
        <xsl:param name="vYear" select="number(tokenize($pDateH,'-')[1])"/>
        <xsl:param name="vMonth" select="number(tokenize($pDateH,'-')[2])"/>
        <xsl:param name="vDay" select="number(tokenize($pDateH,'-')[3])"/>

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
        <xsl:variable name="vYearJ" select="number(tokenize($pDateJ,'-')[1])"/>
        <xsl:variable name="vMonthJ" select="number(tokenize($pDateJ,'-')[2])"/>
        <xsl:variable name="vDayJ" select="number(tokenize($pDateJ,'-')[3])"/>
        
        <xsl:variable name="vYearJ1" select="if($vMonthJ &lt;= 2) then($vYearJ -1) else($vYearJ)"/>
        <xsl:variable name="vMonthJ1" select="if($vMonthJ &lt;= 2) then($vMonthJ +12) else($vMonthJ)"/>
        <xsl:variable name="vJD" select="floor(365.25 * ($vYearJ1 + 4716)) + floor(30.6001 * ($vMonthJ1 + 1)) + $vDayJ - 1524.5"/>
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
        <xsl:variable name="vYearJ" select="number(tokenize($pDateJ,'-')[1])"/>
        <xsl:variable name="vMonthJ" select="number(tokenize($pDateJ,'-')[2])"/>
        <xsl:variable name="vDayJ" select="number(tokenize($pDateJ,'-')[3])"/>
        <xsl:variable name="vMonthM" select="if($vMonthJ &lt;=2) then($vMonthJ +10) else($vMonthJ -2)"/>
        <!-- vYearJM coputes old Julian years beginning on 1 March -->
        <xsl:variable name="vYearJM" select="if($vMonthJ &lt;=2) then($vYearJ -1) else($vYearJ)"/>
        <!-- Every 33 lunar years the Hjrī year completes within a single Mālī year. In this case a year was dropped from the Mālī counting ( 1121, 1154, 1188, 1222, and 1255). due to a printing error, Mālī and Hjrī years were not synchronised in on 1872-03-01 G to 1289 M and the synchronisation was dropped for ever. According to Deny 1921, the OE retrospectively established a new solar era with 1 Mārt 1256 (13 Mar 1840) -->
        <xsl:variable name="vYearM">
            <xsl:variable name="vDateH">
                <xsl:call-template name="funcDateJ2H">
                    <xsl:with-param name="pDateJ" select="$pDateJ"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="vYearH" select="number(tokenize($vDateH,'-')[1])"/>
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
                                                    <xsl:value-of select="$vYearJM -589"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$vYearJM -588"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$vYearJM -587"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$vYearJM -586"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$vYearJM -585"/>
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
                    <xsl:value-of select="$vYearJM -584"/>
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
            <xsl:variable name="vYearH1March" select="number(tokenize($vDateH1March,'-')[1])"/>
            
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
                <xsl:value-of select="concat($vYearM,'-',format-number($vMonthM,'00'),'-',format-number($vDayJ,'00'))"/>
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
                        <xsl:value-of select="concat($vYearJ - 584,'-',format-number(number(tokenize($vDateG,'-')[2]),'00'),'-',format-number(number(tokenize($vDateG,'-')[3]),'00'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($vYearM,'-',format-number(number(tokenize($vDateG,'-')[2])-2,'00'),'-',format-number(number(tokenize($vDateG,'-')[3]),'00'))"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- v2b: this template provides abbreviation for month names in International Journal of Middle East Studies (IJMES) transscription, Başbakanlik Osmanlu Arşivi (BOA) accronyms, and English abbreviations. As there is no functional difference between calendars, I made the choice of calendars implicit as based on the language selector -->
    <xsl:template name="funcDateMonthNameNumber">
        <xsl:param name="pDate" select="'1434-6-12'"/>
        <xsl:param name="pMonth" select="number(tokenize($pDate,'-')[2])"/>
        <!-- pMode has value 'name' or 'number' and toggles the output format -->
        <xsl:param name="pMode" select="'name'"/>
        <!-- pLang has value 'HIjmes', 'HBoa', 'GEn','JIjmes', 'MIjmes', 'GEnFull', 'GDeFull'-->
        <xsl:param name="pLang" select="'HIjmes'"/>
        <xsl:variable name="vNHIjmes"
            select="'Muḥ,Ṣaf,Rab I,Rab II,Jum I,Jum II,Raj,Shaʿ,Ram,Shaw,Dhu I,Dhu II'"/>
        <xsl:variable name="vNHBoa" select="'M ,S ,Ra,R ,Ca,C ,B ,Ş ,N ,L ,Za,Z '"/>
        <xsl:variable name="vNGEn" select="'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'"/>
        <xsl:variable name="vNGEnFull"
            select="'January,February,March,April,May,June,July,August,September,October,November,December'"/>
        <xsl:variable name="vNGDeFull"
            select="'Januar,Februar,März,April,Mai,Juni,Juli,August,September,Oktober,November,Dezember'"/>
        <xsl:variable name="vNJIjmes"
            select="'Kān II,Shub,Ādhār,Nīs,Ayyār,Ḥaz,Tam,Āb,Ayl,Tish I,Tish II,Kān I'"/>
        <xsl:variable name="vNMIjmes"
            select="'Mārt,Nīs,Māyis,Ḥaz,Tam,Agh,Ayl,Tish I,Tish II,Kān I,Kān II,Shub'"/>
        <xsl:variable name="vMonth">
            <xsl:if test="lower-case($pLang)='hijmes'">
                <xsl:for-each select="tokenize($vNHIjmes,',')">
                    <xsl:if test="$pMode='name'">
                        <xsl:if test="position()=$pMonth">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$pMode='number'">
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                        <xsl:if test=".=$pMonth">
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
                            <xsl:attribute name="calendar" select="'#julian'"/>
                            <xsl:attribute name="datingMethod" select="'#julian'"/>
                        </xsl:when>
                        <xsl:when test="$pCal='M'">
                            <!--<xsl:variable name="vDateG">
                                <xsl:call-template name="funcDateM2G">
                                    <xsl:with-param name="pDateM" select="$pDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="when" select="$vDateG"/> -->
                            <xsl:attribute name="when-custom" select="$pDate"/>
                            <xsl:attribute name="calendar" select="'#ottomanfiscal'"/>
                            <xsl:attribute name="datingMethod" select="'#ottomanfiscal'"/>
                        </xsl:when>
                        <xsl:when test="$pCal='H'">
                            <xsl:variable name="vDateG">
                                <xsl:call-template name="funcDateH2G">
                                    <xsl:with-param name="pDateH" select="$pDate"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:attribute name="when" select="$vDateG"/> 
                            <xsl:attribute name="when-custom" select="$pDate"/>
                            <xsl:attribute name="calendar" select="'#islamic'"/>
                            <xsl:attribute name="datingMethod" select="'#islamic'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <!-- element content -->
            <xsl:choose>
                <xsl:when test="$pOutput='formatted'">
                    <xsl:choose>
                        <xsl:when test="$pCal='G'">
                            <xsl:value-of select="format-number(number(tokenize($pDate,'-')[3]),'0')"/>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="funcDateMonthNameNumber">
                                <xsl:with-param name="pDate" select="$pDate"/>
                                <xsl:with-param name="pMode" select="'name'"/>
                                <xsl:with-param name="pLang" select="'Gen'"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="tokenize($pDate,'-')[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$pCal='J'">
                                    <xsl:value-of select="format-number(number(tokenize($pDate,'-')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'JIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'-')[1]"/>
                                </xsl:when>
                                <xsl:when test="$pCal='M'">
                                    <xsl:value-of select="format-number(number(tokenize($pDate,'-')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'MIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'-')[1]"/>
                                </xsl:when>
                                <xsl:when test="$pCal='H'">
                                    <xsl:value-of select="format-number(number(tokenize($pDate,'-')[3]),'0')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:call-template name="funcDateMonthNameNumber">
                                        <xsl:with-param name="pDate" select="$pDate"/>
                                        <xsl:with-param name="pMode" select="'name'"/>
                                        <xsl:with-param name="pLang" select="'HIjmes'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="tokenize($pDate,'-')[1]"/>
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
        
        <!-- this part of the template can produce a calendarDesc element for the teiHeader -->
        <!--<xsl:choose>
            <xsl:when test="$pCal='G'"/>
            <xsl:otherwise>
                <xsl:element name="tei:calendarDesc">
                <xsl:choose>
                    <xsl:when test="$pCal='J'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">julian</xsl:attribute>
                            <xsl:element name="tei:p">
                                <xsl:text>Reformed Julian calendar beginning the Year with 1 January. In the Ottoman context usually referred to as Rūmī.</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$pCal='M'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">ottomanfiscal</xsl:attribute>
                            <xsl:element name="tei:p">
                                <xsl:text>Ottoman fiscal calendar: an Old Julian calendar beginning the Year with 1 March. The year count is synchronised to the Islamic Hijrī calendar. In the Ottoman context usually referred to as Mālī or Rūmī.</xsl:text>
                            </xsl:element>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$pCal='H'">
                        <xsl:element name="tei:calendar">
                            <xsl:attribute name="xml:id">islamic</xsl:attribute>
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
    
    <!-- this template increments the input date annually until a stop date. Optionally calendars can be chosen for transformation through the pCalendars parameter. This helps, for instance to compute the Gregorian date of 1 Muḥarram of the Hijrī year for a specific period.
    The output is a set of comma-separated values -->
    <xsl:template name="funcDateIncrementAnnually">
        <xsl:param name="pYearStop"/>
        <xsl:param name="pYearStart"/>
        <!-- this param selects the date, format: '01-01' -->
        <xsl:param name="pDateStart"/>
        <!-- this param selects the conversion calendars: 'H2G', 'G2H', 'G2J', 'J2G', 'H2J', 'J2H', and 'none' -->
        <xsl:param name="pCalendars"/>
        <xsl:variable name="vDate" select="concat($pYearStart,'-',$pDateStart)"/>
        <xsl:variable name="vDateTarget">
            <xsl:choose>
                <xsl:when test="$pCalendars='G2H'">
                    <xsl:call-template name="funcDateG2H">
                        <xsl:with-param name="pDateG" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pCalendars='H2G'">
                    <xsl:call-template name="funcDateH2G">
                        <xsl:with-param name="pDateH" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pCalendars='G2J'">
                    <xsl:call-template name="funcDateG2J">
                        <xsl:with-param name="pDateG" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pCalendars='J2G'">
                    <xsl:call-template name="funcDateJ2G">
                        <xsl:with-param name="pDateJ" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pCalendars='H2J'">
                    <xsl:call-template name="funcDateH2J">
                        <xsl:with-param name="pDateH" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$pCalendars='J2H'">
                    <xsl:call-template name="funcDateJ2H">
                        <xsl:with-param name="pDateJ" select="$vDate"/>
                    </xsl:call-template>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="$vDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$pYearStart&lt;=$pYearStop">
            <xsl:value-of select="$vDate"/>
            <xsl:text> = </xsl:text>
            <xsl:value-of select="$vDateTarget"/>
            <xsl:text>,
            </xsl:text>
            <xsl:call-template name="funcDateIncrementAnnually">
                <xsl:with-param name="pYearStart" select="$pYearStart +1"/>
                <xsl:with-param name="pDateStart" select="$pDateStart"/>
                <xsl:with-param name="pYearStop" select="$pYearStop"/>
                <xsl:with-param name="pCalendars" select="$pCalendars"/>
            </xsl:call-template>
        </xsl:if>
        
    </xsl:template>
</xsl:stylesheet>
