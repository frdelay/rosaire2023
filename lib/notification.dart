import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'param.dart';


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
          badgeNumber: 1,
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
        "${tz.TZDateTime.now(tz.getLocation('Europe/Paris'))}",
        "Aujourd'hui nouveau mystère",
        tz.TZDateTime.now(tz.local).add(Duration(seconds: delay)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  showNotifDate(DateTime date, String titre,String text, int id) {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: _androidNotificationDetails,
      iOS: _iosNotificationDetails,
    );
    var time = tz.TZDateTime.from(date, tz.local);

    flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        titre,
        text,
        time,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }


 /// Generates notifications for the next 30 days.
  //generate30Notifications({required int meditationNumber, required String prenom }) async {
  generate30Notifications({required int meditationNumber, required String prenom}) async {
    List<Meditation> meditations = await Meditation.notifMedit();
    //DateTime dateInit = DateTime.now().add(const Duration(seconds: 10));

    // TODO: remove print below
    print("++ notif 105: $meditationNumber");

    const int notificationNumber = 30;

    for (int i = 1; i <= notificationNumber; i = i + 1) {
      int processedMeditationNumber = meditationNumber + i-2;
      int selectedMeditationNumber =
          selectMeditationNumber(processedMeditationNumber);

      Meditation meditationNotification = meditations[selectedMeditationNumber];
      String notificationTitle = meditationNotification.titre;
      String notificationCat = meditationNotification.code.substring(0,1);

      DateTime now = DateTime.now();
      DateTime notificationDate =
          DateTime(now.year, now.month, now.day + i, 7, 0, 0);

      int notifId = int.parse('${notificationDate.year}${notificationDate.month}${notificationDate.day}');

      String nomJourNotif = DateFormat.EEEE().format(notificationDate);
      String numeroJourNotif = DateFormat.d().format(notificationDate);
      int moisNotif = int.parse(DateFormat.M().format(notificationDate)) - 1;
      String anneeNotif = DateFormat.y().format(notificationDate);


      LocalNotificationService().showNotifDate(
          notificationDate,
          notificationTitle,
          "$prenom, "
          "Aujourd'hui, ${jourFR[nomJourNotif]} $numeroJourNotif ${moisFR[moisNotif]} $anneeNotif, "
          "vous méditez un mystère ${famille[notificationCat]}",
          notifId);



      // TODO: remove print below
      print(
          "++ notif 142 : $prenom $notificationTitle ($selectedMeditationNumber)"
          " ${jourFR[nomJourNotif]} $numeroJourNotif  "
);
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
