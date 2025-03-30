/* ========================================================= */
/*    SAS-Analyse für Kapitel 5.2 der Fallstudie „PumpWerk“   */
/*                                                           */
/*   Enthält alle durchgeführten Analysen auf Basis der     */
/*   Excel-Dateien zu Ausgaben und Verkäufen.                */
/* ========================================================= */

/* ---------------------------------------------------------- */
/*                      Bibliotheken einbinden                */
/* ---------------------------------------------------------- */
libname pumpwerk  "/home/u64189976/PumpWerk";
libname xlstemp   "/home/u64189976/PumpWerk/TEMP/Excel";

/* ---------------------------------------------------------- */
/*                       Datei-Importe                        */
/* ---------------------------------------------------------- */
filename reffile '/home/u64189976/PumpWerk/Ausgaben_Pumpwerk.xlsx';
proc import datafile=reffile
    dbms=xlsx
    out=pumpwerk.ausgaben
    replace;
    getnames=yes;
run;

filename reffile '/home/u64189976/PumpWerk/Verkäufe_Pumpwerk.xlsx';
proc import datafile=reffile
    dbms=xlsx
    out=pumpwerk.'Verkäufe'n
    replace;
    getnames=yes;
run;

/* ---------------------------------------------------------- */
/* Verkaufsübersicht nach Monat mit Summen- und Durchschnittszeile */
/* ---------------------------------------------------------- */
proc sql;
/* neue Tabelle mit SQL erstellen*/
    create table xlstemp.monat_uebersicht as
    select
        Monat,
        count(*) as Anzahl_Verkaeufe,
        sum(Anzahl_verkauft) as Anzahl_Pumpen,
        sum(Gesamtsumme) as Umsatz format=comma12.2,
        mean(Summe_pro_Pumpe) as Durchschnittspreis format=comma8.2
    from pumpwerk.'Verkäufe'n
    group by Monat;
quit;
/*Hilfstabelle für die spätere Sortierung der Monate*/
data xlstemp.monat_uebersicht_sortiert;
    set xlstemp.monat_uebersicht;
    length Monatsort 8;
    select (Monat);
        when ('Januar') Monatsort = 1;
        when ('Februar') Monatsort = 2;
        when ('März') Monatsort = 3;
        when ('April') Monatsort = 4;
        when ('Mai') Monatsort = 5;
        when ('Juni') Monatsort = 6;
        when ('Juli') Monatsort = 7;
        when ('August') Monatsort = 8;
        when ('September') Monatsort = 9;
        when ('Oktober') Monatsort = 10;
        when ('November') Monatsort = 11;
        when ('Dezember') Monatsort = 12;
        otherwise Monatsort = .;
    end;
run;
/*Tabelle für die Summenberechnung erstellen*/
proc sql;
    create table xlstemp.summen_zeile as
    select
        'Σ' as Monat length=20,
        sum(Anzahl_Verkaeufe) as Anzahl_Verkaeufe,
        sum(Anzahl_Pumpen) as Anzahl_Pumpen,
        sum(Umsatz) as Umsatz format=comma12.2,
        . as Durchschnittspreis,
        99 as Monatsort
    from xlstemp.monat_uebersicht_sortiert;
quit;
/*Tabelle für die Durchschnittsberechnung erstellen*/
proc sql;
    create table xlstemp.durchschnitt_zeile as
    select
        'Ø' as Monat length=20,
        mean(Anzahl_Verkaeufe) as Anzahl_Verkaeufe format=comma8.1,
        mean(Anzahl_Pumpen) as Anzahl_Pumpen format=comma8.1,
        mean(Umsatz) as Umsatz format=comma12.2,
        mean(Durchschnittspreis) as Durchschnittspreis format=comma8.2,
        100 as Monatsort
    from xlstemp.monat_uebersicht_sortiert;
quit;
/*Alle Tabellen zusammenfügen*/
data xlstemp.monatsbericht_final;
    set xlstemp.monat_uebersicht_sortiert
        xlstemp.summen_zeile
        xlstemp.durchschnitt_zeile;
run;
/*sortieren nach Monat*/
proc sort data=xlstemp.monatsbericht_final;
    by Monatsort;
run;
/*Tabelle ausgeben*/
title "Verkaufsübersicht Pumpwerk GmbH 2024";
proc report data=xlstemp.monatsbericht_final nowd style(summary)=[font_weight=bold];
    column Monat Anzahl_Verkaeufe Anzahl_Pumpen Umsatz Durchschnittspreis;
    define Monat / "Monat" display;
    define Anzahl_Verkaeufe / "Anzahl Verkäufe";
    define Anzahl_Pumpen / "Anzahl verkaufter Pumpen";
    define Umsatz / "Umsatz (€)";
    define Durchschnittspreis / "Ø Pumpenpreis (€)";
run;
title;

/* ---------------------------------------------------------- */
/* Boxplot: Pumpenpreise je Land                              */
/* ---------------------------------------------------------- */
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=pumpwerk.'Verkäufe'n;
    title height=14pt "Pumpenpreise je Land";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbox Summe_pro_Pumpe / category=Land;
    yaxis grid label="Preis pro Pumpe";
run;

/* ---------------------------------------------------------- */
/* Tabellen zusammenführen für Scatterplot (Umsatz & Marketing) */
/* ---------------------------------------------------------- */
proc sql;
    create table xlstemp.ausgaben_verkaeufe as
    select
        a.Monat,
        sum(b.Gesamtsumme) as Umsatz_monat format=comma12.2,
        a.Marketingkosten,
        a.Materialkosten,
        a.Garantiekosten
    from pumpwerk.ausgaben as a
    inner join pumpwerk.'Verkäufe'n as b
        on a.Monat = b.Monat
    group by
        a.Monat,
        a.Marketingkosten,
        a.Materialkosten,
        a.Garantiekosten;
quit;

/* ---------------------------------------------------------- */
/* Scatterplot: Marketingkosten vs. Monatsumsatz              */
/* ---------------------------------------------------------- */
proc sgplot data=xlstemp.ausgaben_verkaeufe;
    title height=14pt "Zusammenhang zwischen Marketingausgaben und Monatsumsatz";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    loess x=Marketingkosten y=Umsatz_monat / nomarkers;
    scatter x=Marketingkosten y=Umsatz_monat / markerattrs=(symbol=circle);
    xaxis grid label="Marketingkosten";
    yaxis grid label="Monatsumsatz";
run;

ods graphics / reset;
title;
footnote2;



/* ---------------------------------------------------------- */
/* Balkendiagramm: Verkäufe je Land			                  */
/* ---------------------------------------------------------- */
proc sql;
    create table xlstemp.umsatz_je_land as
    select
        Land,
        sum(Gesamtsumme) as Umsatz_Land format=comma12.2
    from pumpwerk.'Verkäufe'n
    group by Land;
quit;

proc sgplot data=xlstemp.umsatz_je_land;
    title "Umsatz je Land";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Land / response=Umsatz_Land datalabel;
    yaxis grid label="Umsatz (€)";
run;

/* ---------------------------------------------------------- */
/* Balkendiagramm: Verkäufe je Aquisequelle	                  */
/* ---------------------------------------------------------- */
proc sql;
    create table xlstemp.verkaeufe_je_kanal as
    select
        Akquiriert_durch,
        count(*) as Anzahl_Verkaeufe
    from pumpwerk.'Verkäufe'n
    group by Akquiriert_durch;
quit;

proc sgplot data=xlstemp.verkaeufe_je_kanal;
    title "Verkäufe je Akquisequelle";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Akquiriert_durch / response=Anzahl_Verkaeufe datalabel;
    yaxis grid label="Anzahl Verkäufe";
run;

/* ---------------------------------------------------------- */
/* Balkendiagramm: Durchschnittlicher Pumpenpreis je Kontinent*/
/* ---------------------------------------------------------- */
proc sql;
    create table xlstemp.preis_kontinent as
    select
        Kontinent,
        mean(Summe_pro_Pumpe) as Durchschnittspreis format=comma10.2
    from pumpwerk.'Verkäufe'n
    group by Kontinent;
quit;

proc sgplot data=xlstemp.preis_kontinent;
    title "Durchschnittlicher Pumpenpreis je Kontinent";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar Kontinent / response=Durchschnittspreis datalabel;
    yaxis grid label="Ø Preis pro Pumpe (€)";
run;
