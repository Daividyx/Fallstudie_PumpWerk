/* -------------------------------------------------------------- */
/* Ausgabe als ODS PDF-Bericht                                   */
/* -------------------------------------------------------------- */
ods pdf file="/home/u64189976/PumpWerk/Ergebnisse/Maschinenbericht.pdf" 
    style=journal dpi=300 notoc startpage=never;
    ods escapechar='^';  /* Aktiviert Formatierungsoptionen im PDF-Text */


/* -------------------------------------------------------------- */
/* Titel für den Bericht                                          */
/* -------------------------------------------------------------- */
title1 "Maschinenanalyse";
title2 "PumpWerk GmbH";

/* -------------------------------------------------------------- */
/* Übersichtstabelle: Durchschnittswerte je Maschine              */
/* -------------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Übersicht: Durchschnittswerte je Maschine";

proc print data=jsontemp.maschinenbericht label noobs;
run;

/* -------------------------------------------------------------- */
/* Fehlercode-Häufigkeit (absolut)                                */
/* -------------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Fehlercode-Häufigkeit (gesamt)";

proc sgplot data=jsontemp.maschinenlog;
    title "Fehlercode-Häufigkeit (absolut)";
    footnote2 justify=center "PumpWerk GmbH";
    vbar error_code / 
        datalabel 
        fillattrs=(color=CXbf6e26 transparency=0.25);
    xaxis label="Fehlercode";
    yaxis grid;
run;

title;
footnote2;

/* -------------------------------------------------------------- */
/* Fehlercode-Häufigkeit je Maschine                              */
/* -------------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Fehlercode-Häufigkeit je Maschine";

proc sgplot data=jsontemp.maschinenlog;
    title "Fehlercode-Häufigkeit je Maschine";
    footnote2 justify=center "PumpWerk GmbH";
    vbar machine_id / 
        group=error_code 
        groupdisplay=cluster 
        datalabel;
    xaxis label="Maschine";
    yaxis grid label="Häufigkeit";
run;

title;
footnote2;

/* -------------------------------------------------------------- */
/* Temperatur vs. Druck (Scatterplot + Trends)                    */
/* -------------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Zusammenhang zwischen Temperatur und Druck";

proc sgplot data=jsontemp.maschinenlog;
    title "Temperatur vs. Druck";
    footnote2 justify=center "PumpWerk GmbH";
    reg     x=temperature_C y=pressure_bar / nomarkers;
    loess   x=temperature_C y=pressure_bar / nomarkers;
    scatter x=temperature_C y=pressure_bar / 
            markerattrs=(symbol=circle);
    xaxis grid label="Temperatur (°C)";
    yaxis grid label="Druck (bar)";
run;

title;
footnote2;

/* -------------------------------------------------------------- */
/* Durchschnittliche Ausfallzeit je Maschine                      */
/* -------------------------------------------------------------- */
ods pdf text="^S={font_weight=bold} Durchschnittliche Ausfallzeit je Maschine";

proc sgplot data=jsontemp.maschinenbericht;
    title "Durchschnittliche Ausfallzeit je Maschine";
    footnote2 justify=center "PumpWerk GmbH";
    vbar machine_id / 
        response=downtime_avg 
        datalabel 
        fillattrs=(color=CXbf6e26 transparency=0.25);
    xaxis label="Maschine";
    yaxis grid label="Durchschnittliche Ausfallzeit (Minuten)";
run;

title;
footnote2;

/* -------------------------------------------------------------- */
/* PDF schließen                                                  */
/* -------------------------------------------------------------- */
ods pdf close;
