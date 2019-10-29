---
title: "Read me: XSLT calendar conversion"
author: Till Grallert
date: 2018-11-15 12:40:29 +0200
---

# xslt-calendar-conversion

XSLT functions and templates for the conversion of calendars in use in the late Ottoman Empire: Gregorian, Rumi, Mali, and Islamic Hijri.

## Installation and use

The functions and templates can be loaded into other XSLT stylesheets or XQuery. For XSLT use the `<xsl:include>` or `<xsl:import>` methods. Note that the functions make use of the `oape` namespace, which is mapped to `xmlns:oape="https://openarabicpe.github.io/ns"`. You can either download a copy of this repository or link to the online version of the stylesheet which is hosted on the gh-pages branch of this repository. To include the latest version of the functions use

```xml
<xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>
```

## General description

The single stylesheet in this repo was conceived as a remedy for the bugs in the XPath implementation that prevent the computation of Islamic (Hijrī) dates.[^1] As I was, at the same time, working on the transcription of Arabic and Ottoman Turkish sources from the nineteenth century into XML files, which made use of Gregorian, Hijrī, Rūmī, and Mālī calendars, I also wanted to reliably compute conversions between the various calendars.

In addition to numerical dates, the stylesheet provides a function that returns the common month names in various languages and scripts.

Detailed descriptions of the functions and their parameters can be found inside the stylesheet.

## Characteristics of the non-Gregorian calendars

- Islamic **Hijrī** reckoning relies on the observation of the lunar year. Year counts began with Muhammad's exodus (hijrā) from Mecca to Medina. Hijrī dates cannot really be computed as observations of the new moon varied between locations. The stylesheet uses common astronomical computations of the lunar calendar.
- **Rūmī** reckoning is a Julian calendar that adopted 1 January as the beginning of the year. As the rules for leap years are slightly different between Julian and Gregorian calendars, the difference between these two is slowly increasing (currently 13 days).
- Ottoman fiscal **Mālī** reckoning is a combination of the old Julian calendar beginning on 1 March and a Hijrī year count, that was introduced as the fiscal calendar of the Ottoman Empire in 1676. Every 33 lunar years, the year counts between Mālī and Hijrī calendars are synchronised by dropping a year.

## Templates

Templates for the conversion between calendars:

- funcDateG2H
- funcDateG2J
- funcDateG2JD
- funcDateG2M
- funcDateH2G
- funcDateH2J
- funcDateH2JD
- funcDateH2M
- funcDateJ2G
- funcDateJ2H
- funcDateJ2JD
- funcDateJD2G
- funcDateJD2H
- funcDateJD2J
- funcDateM2G
- funcDateM2H
- funcDateM2J

Templates for converting Date formats

- funcDateMonthNameNumber
- funcDateNormaliseInput
- funcDateFormatTei

## Input / Output

- Input and output for all templates converting dates between the various calendars is as follows: "yyyy-mm-dd"
- The template "funcDateFormatTei" accepts the same input but produces a `<tei:date>` note with `@when` or `@when`, `@when-custom`, `@calendar`, and `@datingMethod` attributes depending on the input calendar.
- The template "funcDateNormaliseInput" can be used to convert variously formatted input  strings to the yyyy-mm-dd required by other templates. Possible input formats are  the common English formats of `dd(.) MNn(.) yyyy`, `MNn(.) dd(.), yyyy`, i.e. '15  Shaʿbān 1324' or 'Jan. 15, 2014'. The template requires an input string and a  calendar-language combination as found in funcDateMonthNameNumber.

## License

[CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/)


[^1]: According to the XPath specifications, the [`format-date()`](https://www.w3.org/TR/xpath-functions-30/#func-format-date) function supports a number calendars beyond the Gregorian standard since version 2.0. However, the actual support for calendars and languages is implementation-dependent and the main XSLT, XPath and XQuery processor, Saxon, has not implemented any of these alternative calendars; [documentation for `format-dateTime()`](https://www.saxonica.com/html/documentation/functions/fn/format-dateTime.html).