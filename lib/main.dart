import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'notification.dart';
import 'dart:convert';

void main() async {// Force the layout to Portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final LocalNotificationService localNotificationService;

int login=0 ;
String prenom = "";
int notifmedit = 0;

// variables extraites des url
int ulogin=0;
String utodo = "";

String urlMedit =
      "https://app2.equipes-rosaire.org/medit_liste.php?menu=medit";

  final controllerMedit = WebViewController();

  @override
  void initState() {
    super.initState();

   localNotificationService = LocalNotificationService();
   localNotificationService.init();
    gestionEtat();
    initWebviewControllers();
  }

  void initWebviewControllers() {
    controllerMedit
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlMedit))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            var extrlogin = RegExp(
              r'(?<=\&login=)[0-9]*',
            );
            if (url.contains(extrlogin)) {
              ulogin =
                  int.parse(extrlogin.allMatches(url.toString(), 0).first[0]!);
            }

            var extrtodo = RegExp(
              r'(?<=&todo=)[a-zA-Z]*',
            );
            if (url.contains(extrtodo)) {
              utodo = extrtodo.allMatches(url.toString(), 0).first[0]!;
            }
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if ((utodo == "okcre")||(utodo == "okedit")){
              prefs.setInt("login", ulogin);
              setState(() {
                login =ulogin;
              print("++ main 76 : SP $url / ulogin : $ulogin");
                } );
            }

          },
        ),
      );
      gestionEtat();
  }

  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? pplogin=prefs.getInt('login');print ("++ main85 pplogin : $pplogin");
    if (pplogin == null) {
      setState(() {
        urlMedit =
            "https://app2.equipes-rosaire.org/medit_liste.php?menu=medit";
      });
      print("++ main 88 : S0 $urlMedit");
    } else {
      var uri =
          Uri.parse("http://app2.equipes-rosaire.org/user.php?login=$pplogin");
      var response = await http.post(uri);
      var jsonMedit = jsonDecode(response.body);
      setState(() {
        prenom = jsonMedit['prenom'];
        notifmedit = int.parse(jsonMedit['notifmedit']);
        urlMedit =
            "https://app2.equipes-rosaire.org/medit_view.php?login=$pplogin&menu=medit";
        localNotificationService.generate30Notifications(
            meditationNumber: notifmedit,
            prenom: prenom);
      });
      print("++ main 102 : S1  $urlMedit");

      controllerMedit.loadRequest(Uri.parse(urlMedit));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/EDR-logo-blanc.png'),
          backgroundColor: Color(0xFF2ba8a8),
          shadowColor: Color(0xffffff),
        ),
        body: WebViewWidget(controller: controllerMedit));
  }
}
