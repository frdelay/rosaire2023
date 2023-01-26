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

  int login = 0;
  int user = 0;
  String prenom = "";
  String gestCpte = "";
  String urlGestCpte =
      "https://app2.equipes-rosaire.org/cpte_cre.php?cre=start";
  String urlMedit = 'https://app2.equipes-rosaire.org/medit_liste.php';
  int nMedit = 0;
  final controller1 = WebViewController();
  final controllerCpte_FormEditLogged = WebViewController();
  final controllerCpte_FormEditNotLogged = WebViewController();
  final controllerJournal = WebViewController();
  final controllerContact = WebViewController();

  @override
  void initState() {
    super.initState();

    localNotificationService = LocalNotificationService();
    localNotificationService.init();

    initWebviewControllers();
    gestionEtat();
  }

  void initWebviewControllers() {
    controller1
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlMedit));

    controllerCpte_FormEditLogged
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlGestCpte))
      ..setNavigationDelegate(
        NavigationDelegate(onPageStarted: (String url) async {
          print('++ main 65 : $url login : $login');
          //extracton des variables utilisées par les notification
          var expl = RegExp(
            r'(?<=\?login=)[0-9]*',
          );
          if (url.contains(expl)) {
            login = int.parse(expl.allMatches(url.toString(), 0).first[0]!);
          }
          var expu = RegExp(
            r'(?<=\&u=)[0-9]*',
          );
          if (url.contains(expu)) {
            user = int.parse(expu.allMatches(url.toString(), 0).first[0]!);
          }
          var expp = RegExp(
            r'(?<=\&p=)[a-zA-Z]*',
          );
          if (url.contains(expp)) {
            prenom = expp.allMatches(url.toString(), 0).first[0]!;
          }

          //deconnexion
          if (url.contains("cre=start")) {
            login = 0;
            user = 0;
            prenom = "";
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          final int? oldLogin = prefs.getInt('login');

          prefs.setInt("login", login);
          prefs.setInt("user", user);
          prefs.setString("prenom", prenom);
          print("++ main 99 : editlogin = $login    u = $user  p= $prenom");

          if (oldLogin != login) {
            gestionEtat();
          }
        }),
      );

    controllerCpte_FormEditNotLogged
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(urlGestCpte))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            var expl = RegExp(
              r'(?<=\?login=)[0-9]*',
            );
            if (url.contains(expl)) {
              login = int.parse(expl.allMatches(url.toString(), 0).first[0]!);
            }
            var expu = RegExp(
              r'(?<=\&u=)[0-9]*',
            );
            if (url.contains(expu)) {
              user = int.parse(expu.allMatches(url.toString(), 0).first[0]!);
            }
            var expp = RegExp(
              r'(?<=\&p=)[a-zA-Z]*',
            );
            if (url.contains(expp)) {
              prenom = expp.allMatches(url.toString(), 0).first[0]!;
            }

            //deconnexion
            if (url.contains("cre=start")) {
              login = 0;
              user = 0;
              prenom = "";
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();
            final int? oldLogin = prefs.getInt('login');
            prefs.setInt("login", login);
            prefs.setInt("user", user);
            prefs.setString("prenom", prenom);
            print(
                "++ main 180 : url = $url crelogin = $login  u = $user  p= $prenom");

            if (oldLogin != login) {
              gestionEtat();
            }
          },
        ),
      );

    controllerJournal
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://app2.equipes-rosaire.org/journal.php'));

    controllerContact
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://app2.equipes-rosaire.org/msg_form.php'));
  }

  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if ((prefs.getInt('login') == null) || (prefs.getInt('login') == 0)) {
      setState(() {
        gestCpte = "Crécpte";
        urlGestCpte = "https://app2.equipes-rosaire.org/cpte_cre.php?cre=start";
        urlMedit = 'https://app2.equipes-rosaire.org/medit_liste.php';
      });
      print(
          "++ main 60 : gestionEtat login = $login, user = $user, prenom = $prenom");
    } else {
      setState(() {
        login = prefs.getInt('login')!;
        user = prefs.getInt('user')!;
        nMedit = d + user - 2; //nMedit = numéro de la médition du jour

        gestCpte = "Modifcpte";
        urlGestCpte =
            "https://app2.equipes-rosaire.org/cpte_edit.php?login=$login";
        urlMedit =
            'https://app2.equipes-rosaire.org/medit_view.php?login=$login&n=$nMedit';

        localNotificationService.generate30Notifications(
            meditationNumber: nMedit, prenom: prenom); //introduire nummedit,
      });
      print(
          "++ main 82 : gestionEtat login = $login, user = $user, prenom = $prenom");
    }

    controller1.loadRequest(Uri.parse(urlMedit));
    controllerCpte_FormEditLogged.loadRequest(Uri.parse(urlGestCpte));
    controllerCpte_FormEditNotLogged.loadRequest(Uri.parse(urlGestCpte));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "Medit"),
                Tab(text: "$gestCpte"),
                Tab(text: "Journal"),
                Tab(text: "Contact"),
              ],
            ),
            title: Image.asset('assets/EDR-logo-long.png'),
          ),
          body: TabBarView(
            children: [
              Center(child: Builder(builder: (context) {
                //1

                return WebViewWidget(controller: controller1);
              })),
              Center(child: Builder(builder: (context) {
                //2

                return login != 0
                    ?

                    //Cpte_FormEdit(login)
                    WebViewWidget(
                        controller: controllerCpte_FormEditLogged,
                      )
                    :

                    //Cpte_FormCre() ;
                    WebViewWidget(
                        controller: controllerCpte_FormEditNotLogged,
                      );
              })),
              Center(
                //3
                child: WebViewWidget(
                  controller: controllerJournal,
                ),
              ),
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
