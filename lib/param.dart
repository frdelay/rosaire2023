import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


DateTime now = DateTime.now();
String dayOfWeek = DateFormat.EEEE().format(now);
String day = DateFormat.d().format(now);
int d = int.parse(DateFormat.d().format(now));
int mois = int.parse(DateFormat.M().format(now)) - 1;
String year = DateFormat.y().format(now);

const jourFR = {
  "Monday": "lundi",
  "Tuesday": "mardi",
  "Wednesday": "mercredi",
  "Thursday": "jeudi",
  "Friday": "vendredi",
  "Saturday": "samedi",
  "Sunday": "dimanche"
};

const moisFR = [
  "janvier",
  "février",
  "mars",
  "avril",
  "mai",
  "juin",
  "juillet",
  "août",
  "septembre",
  "octobre",
  "novembre",
  "décembre"
];

const colorTitle = {
  "J": Color(0xffac7a10),
  "L": Color(0xff1957CC),
  "D": Color(0xff96143f),
  "G": Color(0xff2E986E),
};

const famille = {
  "J": "joyeux",
  "L": "lumineux",
  "D": "douloureux",
  "G": "glorieux",
};


// on récupère la liste des méditations et on retourne un tableau Objet de type Méditation

String MeditNotif=
'[{"Nummedit":"1","Code":"J1","Titre":"L\u2019Annonciation"},{"Nummedit":"2","Code":"J2","Titre":"La Visitation"},{"Nummedit":"3","Code":"J3","Titre":"La Nativit\u00e9"},{"Nummedit":"4","Code":"J4","Titre":"La Pr\u00e9sentation au Temple"},{"Nummedit":"5","Code":"J5","Titre":"Le Recouvrement au Temple"},{"Nummedit":"6","Code":"L1","Titre":"Le Bapt\u00eame au Jourdain"},{"Nummedit":"7","Code":"L2","Titre":"Les Noces de Cana"},{"Nummedit":"8","Code":"L3","Titre":"L\u2019Annonce du Royaume"},{"Nummedit":"9","Code":"L4","Titre":"La Transfiguration"},{"Nummedit":"10","Code":"L5","Titre":"L\u2019Institution de l\u2019Eucharistie"},{"Nummedit":"11","Code":"D1","Titre":"L\u2019Agonie de J\u00e9sus"},{"Nummedit":"12","Code":"D2","Titre":"La Flagellation"},{"Nummedit":"13","Code":"D3","Titre":"Le Couronnement d\u2019\u00c9pines"},{"Nummedit":"14","Code":"D4","Titre":"Le Portement de Croix"},{"Nummedit":"15","Code":"D5","Titre":"La Mort de J\u00e9sus sur la Croix"},{"Nummedit":"16","Code":"G1","Titre":"La R\u00e9surrection"},{"Nummedit":"17","Code":"G2","Titre":"L\u2019Ascension"},{"Nummedit":"18","Code":"G3","Titre":"La Pentec\u00f4te"},{"Nummedit":"19","Code":"G4","Titre":"L\u2019Assomption"},{"Nummedit":"20","Code":"G5","Titre":"Le Couronnement de Marie"}]';


class Meditation {
  String nummedit = " ";
  String code = "G";
  String titre = "";

  static Meditation fromJson(Map<String, dynamic> json) {
    var medit = Meditation();
    medit.nummedit = json["Nummedit"];
    medit.code = json["Code"];
    medit.titre = json["Titre"];

    return medit;
  }

  static List<Meditation> notifMedit() {
    var jsonMedit = jsonDecode(MeditNotif);
    List<Meditation> meditations = [];

    jsonMedit.forEach((data) {
      var meditation = Meditation.fromJson(data);
      meditations.add(meditation);
    });
    return meditations;
  }
}


