/*
[{"Nummedit":"1","Code":"J1","Titre":"L\u2019Annonciation"},{"Nummedit":"2","Code":"J2","Titre":"La Visitation"},{"Nummedit":"3","Code":"J3","Titre":"La Nativit\u00e9"},{"Nummedit":"4","Code":"J4","Titre":"La Pr\u00e9sentation au Temple"},{"Nummedit":"5","Code":"J5","Titre":"Le Recouvrement au Temple"},{"Nummedit":"6","Code":"L1","Titre":"Le Bapt\u00eame au Jourdain"},{"Nummedit":"7","Code":"L2","Titre":"Les Noces de Cana"},{"Nummedit":"8","Code":"L3","Titre":"L\u2019Annonce du Royaume"},{"Nummedit":"9","Code":"L4","Titre":"La Transfiguration"},{"Nummedit":"10","Code":"L5","Titre":"L\u2019Institution de l\u2019Eucharistie"},{"Nummedit":"11","Code":"D1","Titre":"L\u2019Agonie de J\u00e9sus"},{"Nummedit":"12","Code":"D2","Titre":"La Flagellation"},{"Nummedit":"13","Code":"D3","Titre":"Le Couronnement d\u2019\u00c9pines"},{"Nummedit":"14","Code":"D4","Titre":"Le Portement de Croix"},{"Nummedit":"15","Code":"D5","Titre":"La Mort de J\u00e9sus sur la Croix"},{"Nummedit":"16","Code":"G1","Titre":"La R\u00e9surrection"},{"Nummedit":"17","Code":"G2","Titre":"L\u2019Ascension"},{"Nummedit":"18","Code":"G3","Titre":"La Pentec\u00f4te"},{"Nummedit":"19","Code":"G4","Titre":"L\u2019Assomption"},{"Nummedit":"20","Code":"G5","Titre":"Le Couronnement de Marie"}]
*/




import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



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

// on récupère la liste des méditations et on retourne un tableau Objet de type Méditation
  static Future<List<Meditation>> notifMedit() async {
    var uri = Uri.parse("http://app2.equipes-rosaire.org/jsonmedit.php");
    var response = await http.post(uri);
    var jsonMedit = jsonDecode(response.body);
    List<Meditation> meditations = [];

    jsonMedit.forEach((data) {
      var meditation = Meditation.fromJson(data);
      meditations.add(meditation);
    });
    return meditations;
  }
}



class LocalNotificationService {
  //Singleton pattern
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _notificationService;
  }

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'channel ID',
    'channel name',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );
  final DarwinNotificationDetails _iosNotificationDetails =
      const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 5,
          attachments: [],
      );

  LocalNotificationService._internal();

  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    tz.initializeTimeZones();

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void showNotif(int delay) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: _androidNotificationDetails,
        iOS: _iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "${tz.TZDateTime.now}",
        "Aujourd'hui nouveau mystère",
        tz.TZDateTime.now(tz.local).add(Duration(seconds: delay)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  showNotifDate(DateTime date, String titre) {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: _androidNotificationDetails,
      iOS: _iosNotificationDetails,
    );
    var time = tz.TZDateTime.from(date, tz.local);

    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        titre,
        "Aujourd'hui nouveau mystère",
        time,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  /// Generates notifications for the next 30 days.
  generate30Notifications({required int meditationNumber}) async {
    List<Meditation> meditations = await Meditation.notifMedit();
    DateTime dateInit = DateTime.now().add(const Duration(seconds: 30));

    // TODO: remove print below
    print("++145 notif.dart meditationNumber: $meditationNumber #####");

    const int notificationNumber = 15;

    for (int i = 1; i <= notificationNumber; i = i + 1) {
      int processedMeditationNumber = meditationNumber - 1 + i;
      int selectedMeditationNumber = selectMeditationNumber(processedMeditationNumber);

      // TODO: remove print below
      print("++154 notif.dart selectedMeditationNumber: $selectedMeditationNumber #####");

      Meditation meditationNotification = meditations[selectedMeditationNumber];
      String notificationTitle = meditationNotification.titre;

      DateTime notificationDate = dateInit.add(Duration(seconds: 300 * i));
      LocalNotificationService().showNotifDate(notificationDate, "$notificationTitle / $i");

      // TODO: remove print below
      print("++163 notif.dart / notif $i $notificationDate $notificationTitle $selectedMeditationNumber");
    }
  }
}

// Helper functions

/// Select the correct mediation number then returns it.
int selectMeditationNumber(int processedMeditationNumber) {
  if (processedMeditationNumber >= 60) {
    int selectedMeditationNumber = processedMeditationNumber - 60;
    return selectedMeditationNumber;
  } else if (processedMeditationNumber >= 40) {
    int selectedMeditationNumber = processedMeditationNumber - 40;
    return selectedMeditationNumber;
  } else if (processedMeditationNumber >= 20) {
    int selectedMeditationNumber = processedMeditationNumber - 20;
    return selectedMeditationNumber;
  } else {
    int selectedMeditationNumber = processedMeditationNumber;
    return selectedMeditationNumber;
  }
}
