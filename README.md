#xslt-calendar-conversion


This repo contains XSLT templates for the conversion of Calendars in use in the late Ottoman Empire: Gregorian, Rumi, Mali, and Islamic Hijri.

##General description

The single stylesheet in this repo was conceived as a remedy for the bugs in the XPath specification that prevent the computation of Islamic (Hijrī) dates. As I was, at the same time, working on the transcription of Arabic and Ottoman Turkish sources from the nineteenth century, which made use of Gregorian, Hijrī, Rūmī, and Mālī calendars, into XML files, I also wanted to reliably compute conversions between the various calendars.

In addition to numerical dates, the stylesheet provides a function that returns the common month names.

Detailed descriptions of the functions and their parameters can be found inside the stylesheet.

##Characteristics of the non-Gregorian calendars

- **Hijrī** reckoning relies on the observation of the lunar year. Year counts began with Muhammad's exodus (hijrā) from Mecca to Medina. Hijrī dates cannot really be computed as observations of the new moon varied between locations. The stylesheet uses common astronomical computations of the lunar calendar.
- **Rūmī** reckoning is a Julian calendar that adopted 1 January as the beginning of the year. As the rules for leap years are slightly different between Julian and Gregorian calendars, the difference between these two is slowly increasing (currently 13 days).
- **Mālī** reckoning is a combination of the old Julian calendar beginning on 1 March and a Hijrī year count, that was introduced as the fiscal calendar of the Ottoman Empire in 1676. Every 33 lunar years, the year counts between Mālī and Hijrī calendars are synchronised by dropping a year.

##Input / Output

Input and output for all templates converting dates between the various calendars is as follows:

"yyyy-mm-dd"

##License

[CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/)
