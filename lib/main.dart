import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late WebViewController controller;
  late final LocalNotificationService localNotificationService;

  String login = "";

  @override
  void initState() {
    super.initState();  

    localNotificationService = LocalNotificationService();
    localNotificationService.init();

    gestionEtat();
  }

  

  String gestCpte = "Crécpte";
  String urlGestCpte = "https://app2.equipes-rosaire.org/cpte_formcre.php";
  String urlMedit='https://app2.equipes-rosaire.org/medit_liste.php';


  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

if (prefs.getString('login') == null) {
  login="0";
  prefs.setString("login", "0");
}
      login = (prefs.getString('login'))!;

      if (login == "0")	 {

        setState(() {

          gestCpte = "Crécpte";
          urlGestCpte ="https://app2.equipes-rosaire.org/cpte_formcre.php";
          urlMedit='https://app2.equipes-rosaire.org/medit_liste.php';

        });
      print ("++65 : gestionEtat login $login");
      }else{

        setState(() {
          gestCpte = "Modifcpte";
          urlGestCpte =
              "https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login";
          urlMedit='https://app2.equipes-rosaire.org/medit_view.php?login=$login';

        localNotificationService.generate30Notifications(meditationNumber: 1,); //introduire nummedit,

        });
      print ("++77 : gestionEtat login $login");

    }
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

              Center(child: Builder(builder: (context) {//1

                return login!= "0" ? 
                WebView(  
                  initialUrl: urlMedit,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (c){c.loadUrl(urlMedit); }
              )
              :
              WebView(  
                  initialUrl:urlMedit, 
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (c){c.loadUrl(urlMedit); }
              );
              }
              )
              ),



              Center(child: Builder(builder: (context) {//2

                return login != "0" ? 
                
                //Cpte_FormEdit(login)
                WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl:
              'https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login',
                onWebViewCreated: (c){c.loadUrl('https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login'); },
                onPageStarted: (url) async {
                print('++107 : $url login : $login');
                var exp = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(exp)) {
                            login =
                                exp.allMatches(url.toString(), 0).first[0]!;
                          }
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("login", login);

                 gestionEtat(); 
                }
              )

                :

              //Cpte_FormCre() ;

              WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: 'https://app2.equipes-rosaire.org/cpte_formcre.php',
                onWebViewCreated: (c){c.loadUrl('https://app2.equipes-rosaire.org/cpte_formcre.php'); },
                onPageStarted: (url) async {
                var exp = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(exp)) {
                            login =
                                exp.allMatches(url.toString(), 0).first[0]!;
                          }
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("login", login);

                 gestionEtat();                        
                        
                },//onPageStarted
              );
              
            })),

              Center(//3
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/journal.php',
                      onPageStarted: (url) async {
                      })),
              Center(//4
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/msg_form.php',
                      onPageStarted: (url) async {
                      })),

            ],
          ),
        ));
  }
}