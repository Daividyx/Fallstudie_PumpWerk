/* ---------------------------------------------------------- */
/* Ausgabe als ODS PDF-Bericht                                */
/* ---------------------------------------------------------- */

ods pdf file='/home/u64189976/PumpWerk/Ergebnisse/Finanzbericht.pdf' startpage=never;
ods escapechar='^';  /* Aktiviert Formatierungsoptionen im PDF-Text */


/* ---------------------------------------------------------- */
/* Titel für den Bericht                                      */
/* ---------------------------------------------------------- */
title1 "Finanzbericht";
title2 "Pumpwerk GmbH";

/* ---------------------------------------------------------- */
/* Verkaufsübersicht nach Monat mit Summen- und Durchschnittszeile */
/* ---------------------------------------------------------- */

ods pdf text="^S={font_weight=bold} Verkaufsübersicht nach Monat mit Summen- und Durchschnittszeile";
proc report data=xlstemp.monatsbericht_final nowd style(summary)=[font_weight=bold];
    column Monat Anzahl_Verkaeufe Anzahl_Pumpen Umsatz Durchschnittspreis;
    define Monat / "Monat" display;
    define Anzahl_Verkaeufe / "Anzahl Verkäufe";
    define Anzahl_Pumpen / "Anzahl verkaufter Pumpen";
    define Umsatz / "Umsatz (€)";
    define Durchschnittspreis / "Ø Pumpenpreis (€)";
run;

/* ---------------------------------------------------------- */
/* Boxplot: Pumpenpreise je Land                              */
/* ---------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Boxplot: Pumpenpreise je Land";
proc sgplot data=pumpwerk.'Verkäufe'n;
    title "Pumpenpreise je Land";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbox Summe_pro_Pumpe / category=Land;
    yaxis grid label="Preis pro Pumpe";
run;

/* ---------------------------------------------------------- */
/* Scatterplot: Marketingkosten vs. Monatsumsatz              */
/* ---------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Scatterplot: Marketingkosten vs. Monatsumsatz";
proc sgplot data=xlstemp.ausgaben_verkaeufe;
    title "Zusammenhang zwischen Marketingausgaben und Monatsumsatz";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    loess x=Marketingkosten y=Umsatz_monat / nomarkers;
    scatter x=Marketingkosten y=Umsatz_monat / markerattrs=(symbol=circle);
    xaxis grid label="Marketingkosten";
    yaxis grid label="Monatsumsatz";
run;

/* ---------------------------------------------------------- */
/* Balkendiagramm: Verkäufe je Land			                  */
/* ---------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Verkäufe je Land";
proc sgplot data=xlstemp.umsatz_je_land;
    title "Umsatz je Land";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Land / response=Umsatz_Land datalabel;
    yaxis grid label="Umsatz (€)";
run;

/* ---------------------------------------------------------- */
/* Balkendiagramm: Verkäufe je Aquisequelle	                  */
/* ---------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Verkäufe je Akquisequelle";
proc sgplot data=xlstemp.verkaeufe_je_kanal;
    title "Verkäufe je Akquisequelle";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Akquiriert_durch / response=Anzahl_Verkaeufe datalabel;
    yaxis grid label="Anzahl Verkäufe";
run;

/* ---------------------------------------------------------- */
/* Balkendiagramm: Durchschnittlicher Pumpenpreis je Kontinent*/
/* ---------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Durchschnittspreis je Kontinent";
proc sgplot data=xlstemp.preis_kontinent;
    title "Durchschnittlicher Pumpenpreis je Kontinent";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Kontinent / response=Durchschnittspreis datalabel;
    yaxis grid label="Ø Preis pro Pumpe (€)";
run;

ods pdf close; /* Beenden der ODS-Ausgabe und Speichern des Dokuments */

