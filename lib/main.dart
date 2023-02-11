import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_view/param.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'notification.dart';

void main() => runApp(MyApp());

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

  String todo = "";
  int login = 0;
  String prenom = "";
  String email = "";
  int usernum = 0;
  String ekipnum = "";

  String urlMedit = "https://app2.equipes-rosaire.org/medit_liste.php";
  String urlJournal = "https://app2.equipes-rosaire.org/journal.php";
  String urlCpte = "https://app2.equipes-rosaire.org/cpte.php?todo=start";
  String urlMsg = "https://app2.equipes-rosaire.org/msg.php";

  int nMedit = 0;
  final controllerMedit = WebViewController();
  final controllerCpte = WebViewController();
  final controllerJournal = WebViewController();
  final controllerContact = WebViewController();

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
          NavigationDelegate(onPageStarted: (String url) async {
        print("++ main 65 : $url");
      }));

    controllerJournal
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlJournal))
      ..setNavigationDelegate(
          NavigationDelegate(onPageStarted: (String url) async {
        print("++ main 76 : $url");
      }));

    controllerCpte
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlCpte))
      ..setNavigationDelegate(
        NavigationDelegate(onPageStarted: (String url) async {
        

          //extracton des variables utilisées par les notifications

          var extrlogin = RegExp(
            r'(?<=\?login=)[0-9]*',
          );
          if (url.contains(extrlogin)) {
            login =
                int.parse(extrlogin.allMatches(url.toString(), 0).first[0]!);
          }

          var extruser = RegExp(
            r'(?<=\&usernum=)[0-9]*',
          );
          if (url.contains(extruser)) {
            usernum =
                int.parse(extruser.allMatches(url.toString(), 0).first[0]!);
          }

          var extrprenom = RegExp(
            r'(?<=\&prenom=)[a-zA-Z]*',
          );
          if (url.contains(extrprenom)) {
            prenom = extrprenom.allMatches(url.toString(), 0).first[0]!;
          }

          var extremail = RegExp(
            r'(?<=\&email=)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}'
          );
          if (url.contains(extremail)) {
            email = extremail.allMatches(url.toString(), 0).first[0]!;
          }

          var extrekipnum = RegExp(
            r'(?<=\&ekipnum=)[A-Za-z0-9]*',
          );
          if (url.contains(extrekipnum)) {
            ekipnum = extrekipnum.allMatches(url.toString(), 0).first[0]!;
          }

          var extrtodo = RegExp(
            r'(?<=\&todo=)[a-zA-Z]*',
          );
          if (url.contains(extrtodo)) {
            todo = extrtodo.allMatches(url.toString(), 0).first[0]!;
            todo=todo.substring(0,2);
          }
          //deconnexion
          if (url.contains("todo=suppr")) {
            login = 0;
            prenom = "";
            email = "";
            usernum = 0;
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          //final int? oldLogin = prefs.getInt('login');

          prefs.setInt("login", login);
          prefs.setInt("usernum", usernum);
          prefs.setString("prenom", prenom);
          prefs.setString("email", email);
          prefs.setString("ekipnum", ekipnum);
          print("++ main 150 : $url ");
  print("++ main 142 : $url  todo=$todo");
          if (todo == "ok") {
            gestionEtat();
          }
        }),
      );

    controllerContact
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlMsg))
      ..setNavigationDelegate(
          NavigationDelegate(onPageStarted: (String url) async {
        print("++ main 168 : $url");
      }));
  }

  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if ((prefs.getInt('login') == null) || (prefs.getInt('login') == 0)) {
      setState(() {
        urlMedit = "https://app2.equipes-rosaire.org/medit_liste.php";
        urlJournal = "https://app2.equipes-rosaire.org/journal.php";
        urlCpte = "https://app2.equipes-rosaire.org/cpte.php?todo=start";
        urlMsg = "https://app2.equipes-rosaire.org/msg.php";
      });
      print(
          "++ main 170 : State0 tlupek = $todo / $login / $usernum / $prenom / $email / $ekipnum");
    } else {
      setState(() {
        login = prefs.getInt('login')!;
        usernum = prefs.getInt('usernum')!;
        nMedit = d + usernum - 2; //nMedit = numéro de la médition du jour
        prenom = prefs.getString('prenom')!;
        email = prefs.getString('email')!;
        ekipnum = prefs.getString('ekipnum')!;
        urlMedit =
            "https://app2.equipes-rosaire.org/medit_view.php?login=$login&n=$nMedit";
        urlJournal =
            "https://app2.equipes-rosaire.org/journal.php?ekipnum=$ekipnum";
        urlCpte =
            "https://app2.equipes-rosaire.org/cpte.php?login=$login&todo=formedit";
        urlMsg =
            "https://app2.equipes-rosaire.org/msg.php?login=$login&prenom=$prenom&email=$email&ekipnum=$ekipnum";
        localNotificationService.generate30Notifications(
            meditationNumber: nMedit, prenom: prenom); //introduire nummedit,
      });
      print(
          "++ main 201 : State1 = $urlMedit / $urlJournal / $urlCpte / $urlMsg ");
      controllerMedit.loadRequest(Uri.parse(urlMedit))  ;  
      controllerJournal.loadRequest(Uri.parse(urlJournal))  ;  
      controllerCpte.loadRequest(Uri.parse(urlCpte))  ;  
      controllerContact.loadRequest(Uri.parse(urlMsg))  ;  

    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(child: Text("Meditation")),
                Tab(child: Text("Avec moi")),
                Tab(child: Text("Compte")),
                Tab(child: Text("Contact")),
              ],
            ),
            title: Image.asset('assets/EDR-logo-blanc.png'),
            backgroundColor: Color(0xFF2ba8a8),
          ),
          body: TabBarView(
            children: [
              Center(child: Builder(builder: (context) {
                //1
                return WebViewWidget(controller: controllerMedit);
              })),
              Center(
                //2
                child: WebViewWidget(
                  controller: controllerJournal,
                ),
              ),
              Center(
                  child: WebViewWidget(
                controller: controllerCpte,
              )),
              Center(
                //4
                child: WebViewWidget(
                  controller: controllerContact,
                ),
              ),
            ],
          ),
        ));
  }
}
