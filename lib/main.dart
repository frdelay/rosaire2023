import 'package:flutter/material.dart';
import 'package:web_view/param.dart';
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

  int login = 0;
  int user = 0;
  String prenom="";
  String gestCpte = "";
  String urlGestCpte = "";
  String urlMedit='';
  int nMedit=0;


  @override
  void initState() {
    super.initState();  

    localNotificationService = LocalNotificationService();
    localNotificationService.init();

    gestionEtat();
  }



  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

if ((prefs.getInt('login') == null)||	(prefs.getInt('login') == 0))
{

        setState(() {
          gestCpte = "Crécpte";
          urlGestCpte ="https://app2.equipes-rosaire.org/cpte_cre.php?cre=start";
          urlMedit='https://app2.equipes-rosaire.org/medit_liste.php';
        });
      print ("++ main 60 : gestionEtat login = $login, user = $user, prenom = $prenom");


      }else{

        login = prefs.getInt('login')!;
        user= prefs.getInt('user')!;

        setState(() {

          nMedit=d+user-2;//nMedit = numéro de la médition du jour

          gestCpte = "Modifcpte";
          urlGestCpte =
              "https://app2.equipes-rosaire.org/cpte_edit.php?login=$login";
          urlMedit='https://app2.equipes-rosaire.org/medit_view.php?login=$login&n=$nMedit';


        localNotificationService.generate30Notifications(meditationNumber: nMedit, prenom: prenom); //introduire nummedit,
        });
      print ("++ main 82 : gestionEtat login = $login, user = $user, prenom = $prenom");

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

                return login!= 0 ? 
                WebView(  
                  initialUrl: urlMedit,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (c){c.loadUrl(urlMedit); },
                  onPageStarted: (url){print("++ main 116 url : $url");}
                  
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

                return login != 0 ? 
                
                //Cpte_FormEdit(login)
                WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl:urlGestCpte,
                onWebViewCreated: (c){c.loadUrl(urlGestCpte); },
                 onPageStarted: (url) async {
                print('++ main 142 : $url login : $login');
                //extracton des variables utilisées par les notification
                var expl = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(expl)) {login = int.parse(expl.allMatches(url.toString(), 0).first[0]!);}
                var expu = RegExp(r'(?<=\&u=)[0-9]*',);
                  if (url.contains(expu)) {user = int.parse(expu.allMatches(url.toString(), 0).first[0]!); } 
                var expp = RegExp(r'(?<=\&p=)[a-zA-Z]*',);
                  if (url.contains(expp)) {prenom = expp.allMatches(url.toString(), 0).first[0]!;}

                //deconnexion
                if (url.contains("cre=start")) {login=0; user= 0;prenom = "";}

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("login", login);
                  prefs.setInt( "user", user);
                  prefs.setString( "prenom", prenom);
                  print("++ main 154 : editlogin = $login    u = $user  p= $prenom");

                 gestionEtat(); 
                }
              )

                :

              //Cpte_FormCre() ;

              WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl:urlGestCpte,
                onWebViewCreated: (c){c.loadUrl(urlGestCpte); }, 
                onPageStarted: (url) async {
                var expl = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(expl)) {login = int.parse(expl.allMatches(url.toString(), 0).first[0]!);}
                var expu = RegExp(r'(?<=\&u=)[0-9]*',);
                  if (url.contains(expu)) {user = int.parse(expu.allMatches(url.toString(), 0).first[0]!); } 
                var expp = RegExp(r'(?<=\&p=)[a-zA-Z]*',);
                  if (url.contains(expp)) {prenom = expp.allMatches(url.toString(), 0).first[0]!;}

                //deconnexion
                if (url.contains("cre=start")) {login=0; user= 0;prenom = "";}
          
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("login", login); 
                  prefs.setInt( "user", user);
                  prefs.setString( "prenom", prenom);
                  print("++ main 180 : url = $url crelogin = $login  u = $user  p= $prenom");

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