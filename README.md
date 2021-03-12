---
title: "Read me: XSLT calendar conversion"
author: Till Grallert
date: 2021-03-12
---

# xslt-calendar-conversion

XSLT functions and templates for the conversion of calendars in use in the late Ottoman Empire: Gregorian, Julian (*rūmī*), Ottoman fiscal (*mālī*), Islamic (*hijrī*), and Coptic calendars. The approach follows John Walker's [Calender Converter](http://www.fourmilab.ch/documents/calendar/) JavaScript functions and bases conversions on the Julian Day as an intermediary step.

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
- **Rūmī** reckoning is a Julian calendar that adopted 1 January as the beginning of the year. As the rules for leap years are slightly different between Julian and Gregorian calendars, the difference between these two increases by one day with every century (currently 13 days).
- Ottoman fiscal **Mālī** reckoning is a combination of the old Julian calendar beginning on 1 March and a Hijrī year count, that was introduced as the fiscal calendar of the Ottoman Empire in 1676. Every 33 lunar years, the year counts between Mālī and Hijrī calendars are synchronised by dropping a year.  Due to a printing error in the coupon booklets for the consolidated debt repayment program for 1872 (1288 M instead of 1289 M), synchronisation of *mālī* and *hijrī* years was henceforth abolished. As *mālī* years began with 1 March, *mālī* leap years preceded their *rūmī* and Gregorian counterpart (the leap year 1315 M commenced on 13 March 1899).

## Templates/ functions

Originally the stylesheet was organised into templates but starting in 2018, I converted everything into modular functions that can be used in XPath expressions. The namespace for the functions is "https://openarabicpe.github.io/ns".

### main function(s)

- `date-convert-calendars`: bi-directional conversion of any of the supported calendars.

- convert years only
    - `date-convert-islamic-year-to-gregorian`: converts Islamic (*hijrī*) years to Gregorian year ranges
    - `date-convert-ottoman-fiscal-year-to-gregorian`

### helper functions

- `date-is-gregorian-leap-year`: determines if a an Gregorian date false into a leap year. Output is `true()` or `false()`
- convert input calendars to Julian Day:
    + any calendar: `date-convert-date-to-julian-day`
    + Gregorian: `date-convert-gregorian-to-julian-day`
    + Islamic (*hijrī*): `date-convert-islamic-to-julian-day`
    + Julian (*rūmī*): `date-convert-julian-to-julian-day`
    + Coptic: `date-convert-coptic-to-julian-day`
- convert Julian Day to output calendars
    + `oape:date-convert-julian-day-to-date`
    + `date-convert-julian-day-to-gregorian`
    + `date-convert-julian-day-to-islamic`
    + `date-convert-julian-day-to-julian`
    + `date-convert-julian-day-to-coptic`
- direct conversion between related calendars: Julian (*rūmī*) and Ottoman fiscal (*mālī*)
    + `date-convert-julian-to-ottoman-fiscal`
    + `date-convert-ottoman-fiscal-to-julian`
- `date-convert-months`: convert between names and nummerical values for months, depending on an input calendar. supports multiple languages

### miscellaneous

- NLP
    + `date-establish-calendar`: tries to establish the calendar of an input date string based on month names
    + `date-normalise-input`: a textual date string will be converted into ISO format (yyyy-mm-dd)
- TEI specific
    - `date-format-iso-string-to-tei`: generate a full `<tei:date>` nodes with attributes for any of the supported calendars
    - `date-convert-tei-to-current-month`: takes a `<tei:date>` node as input and generates a correctly formatted tei:date node describing the month this date falls in, depending of the calendar of the input with `@from`, `@from-custom`, `@to` and `@to-custom` attributes. The language of the output can be selected through a parameter

### Input / Output

- Dates: Unless otherwise specified, input and output for all templates converting dates between the various calendars follows the ISO standard for dates as "yyyy-mm-dd"
- Calendars: Due to historical reasons, this code makes use of values specified for my project "Open Arabic Periodical Editions ([OpenArabicPE](https://openarabicpe.github.io/))". Unfortunately, they take the form of local references (`#cal_...`). For the future, I plan to use LOD references. Wikidate would be the place to go to, because one can add entities.
    + Gregorian calendar: `#cal_gregorian`
        * Wikidata: [Q12138](https://www.wikidata.org/wiki/Q12138)
    + Islamic (*hirjrī*) calendar: `#cal_islamic`
        * Wikidata: [Q28892](https://www.wikidata.org/wiki/Q28892)
    + (New) Julian (*rūmī*) calendar: `#cal_julian`
        * Wikidata: [Q1279922](https://www.wikidata.org/wiki/Q1279922)
            * [Q11184](https://www.wikidata.org/wiki/Q11184) refers to the Old Julian calendar
    + Ottoman fiscal (*mālī*) calendar: `#cal_ottomanfiscal`
    + Coptic calendar: `#cal_coptic`
        * Wikidata: [Q750430](https://www.wikidata.org/wiki/Q750430)

## License

[CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/)


[^1]: According to the XPath specifications, the [`format-date()`](https://www.w3.org/TR/xpath-functions-30/#func-format-date) function supports a number calendars beyond the Gregorian standard since version 2.0. However, the actual support for calendars and languages is implementation-dependent and the main XSLT, XPath and XQuery processor, Saxon, has not implemented any of these alternative calendars; [documentation for `format-dateTime()`](https://www.saxonica.com/html/documentation/functions/fn/format-dateTime.html).