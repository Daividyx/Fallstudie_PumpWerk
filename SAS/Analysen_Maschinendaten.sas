/* -------------------------------------------------------------- */
/* Bibliotheken einbinden                                         */
/* -------------------------------------------------------------- */
libname pumpwerk  "/home/u64189976/PumpWerk";               /* Rohdaten */
libname jsontemp  "/home/u64189976/PumpWerk/TEMP/JSON";     /* Analyseergebnisse */

/* -------------------------------------------------------------- */
/* JSON-Datei importieren und in jsontemp speichern               */
/* -------------------------------------------------------------- */
filename mraw "/home/u64189976/PumpWerk/maschinenlog_Pumpwerk.json";
libname mlog JSON fileref=mraw;

data jsontemp.maschinenlog;
    set mlog.root;
run;

/* -------------------------------------------------------------- */
/* Vorschau: erste 10 Zeilen anzeigen                             */
/* -------------------------------------------------------------- */
proc print data=jsontemp.maschinenlog(obs=10) label;
    title "Beispielhafte Datenvorschau: jsontemp.maschinenlog";
run;

/* ---------------------------------------------------------------- */
/* Analyse 1: Übersichtstabelle                                     */
/* ---------------------------------------------------------------- */

ods graphics / reset width=16cm height=8cm imagemap;

proc sql;
    create table jsontemp.maschinenbericht as
    select
        machine_id,

        /* Temperaturwerte */
        mean(temperature_C)  as temp_avg  label="Durchschnittliche Temperatur (C)" format=6.2,
        max(temperature_C)   as temp_max  label="Maximale Temperatur (C)"         format=6.2,

        /* Druckwerte */
        mean(pressure_bar)   as press_avg label="Durchschnittlicher Druck (bar)"  format=6.2,
        max(pressure_bar)    as press_max label="Maximaler Druck (bar)"           format=6.2,

        /* Fehleranzahl insgesamt */
        sum(case when not missing(error_code) then 1 else 0 end) as error_total
            label="Anzahl Fehler",

        /* Fehleranzahl je Code */
        sum(case when error_code = 'E001' then 1 else 0 end) as e001 label="E001",
        sum(case when error_code = 'E002' then 1 else 0 end) as e002 label="E002",
        sum(case when error_code = 'E003' then 1 else 0 end) as e003 label="E003",
        sum(case when error_code = 'E004' then 1 else 0 end) as e004 label="E004",
        sum(case when error_code = 'E005' then 1 else 0 end) as e005 label="E005",
        sum(case when error_code = 'E006' then 1 else 0 end) as e006 label="E006",

        /* Ausfallzeiten */
        max(downtime_min)  as downtime_max label="Maximale Ausfallzeit (min)",
        mean(downtime_min) as downtime_avg label="Durchschnittliche Ausfallzeit (min)" format=6.1

    from jsontemp.maschinenlog
    group by machine_id;
quit;


proc print data=jsontemp.maschinenbericht label;
    title "Übersichtstabelle Maschinendaten";
run;

/* -------------------------------------------------------------- */
/* Analyse 2: Häufigkeit von Fehlercodes                          */
/* -------------------------------------------------------------- */
ods graphics / reset width=16cm height=8cm imagemap;

proc sgplot data=jsontemp.maschinenlog;
    title height=14pt "Häufigkeiten von Fehlercodes (absolut)";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar error_code /
        fillattrs=(color=CXbf6e26 transparency=0.25)
        datalabel;
    xaxis label="Fehlercodes";
    yaxis grid;
run;

ods graphics / reset;
title;
footnote2;

/* -------------------------------------------------------------- */
/* Analyse 3: Fehlercodes je Maschine (gruppiert)                 */
/* -------------------------------------------------------------- */
ods graphics / reset width=16cm height=8cm imagemap;

proc sgplot data=jsontemp.maschinenlog;
    title height=14pt "Fehlercode Häufigkeit je Maschine";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    vbar machine_id / group=error_code
                     groupdisplay=cluster
                     datalabel;
    xaxis label="Maschine";
    yaxis grid label="Häufigkeit";
run;

ods graphics / reset;
title;
footnote2;

/* -------------------------------------------------------------- */
/* Analyse 4: Temperatur vs. Druck (Scatter + Trends)             */
/* -------------------------------------------------------------- */
ods graphics / reset width=16cm height=8cm imagemap;

proc sgplot data=jsontemp.maschinenlog;
    title height=14pt "Zusammenhang zwischen Temperatur und Druck";
    footnote2 justify=center height=12pt "PumpWerk GmbH";
    reg     x=temperature_C y=pressure_bar / nomarkers;
    loess   x=temperature_C y=pressure_bar / nomarkers;
    scatter x=temperature_C y=pressure_bar /
            markerattrs=(symbol=circle);
    xaxis grid label="Temperatur (°C)";
    yaxis grid label="Druck (bar)";
run;

ods graphics / reset;
title;
footnote2;


/* -------------------------------------------------------------- */
/* Analyse 5: Durchschnittliche Ausfallzeit je Maschine           */
/* -------------------------------------------------------------- */

ods graphics / reset width=16cm height=8cm imagemap;

proc sgplot data=jsontemp.maschinenbericht;
    title height=14pt "Durchschnittliche Ausfallzeit je Maschine";
    footnote2 justify=center height=12pt "PumpWerk GmbH";

    /* Balken nach Maschine mit durchschnittlicher Ausfallzeit */
    vbar machine_id /
        response=downtime_avg
        datalabel
        fillattrs=(color=CXbf6e26 transparency=0.25);

    xaxis label="Maschine";
    yaxis grid label="Durchschnittliche Ausfallzeit (Minuten)";
run;

ods graphics / reset;
title;
footnote2;

	


