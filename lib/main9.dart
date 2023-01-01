import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isLogged = false;
  String login = "";

  @override
  void initState() {
    super.initState();
    gestionEtat();
  }


                          
  bool? oldIsLogged;
  String gestCpte = "Crécpte";
  String urlGestCpte = "https://app2.equipes-rosaire.org/cpte_formcre.php";
  gestionEtat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('login') == null)  {
      if (oldIsLogged != isLogged) {
        setState(() {
          isLogged = false;
          oldIsLogged = isLogged;
        });
      }
    } else {
      login = (prefs.getString('login'))!;
      isLogged = true;
      if (oldIsLogged != isLogged) {
        setState(() {
          isLogged = true;
          login = (prefs.getString('login'))!;
          oldIsLogged = isLogged;
          gestCpte = "Modifcpte";
          urlGestCpte =
              "https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login";
        });

      }
    }
  }


  @override
  Widget build(BuildContext context) {

      print("++71 : isLogged = $isLogged  login = $login");


    return DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_transit), text: "Medit"),
                Tab(icon: Icon(Icons.directions_bike), text: "$gestCpte"),
                Tab(icon: Icon(Icons.directions), text: "Journal"),
                Tab(icon: Icon(Icons.alarm), text: "Contact"),
                Tab(icon: Icon(Icons.directions_car), text: "EdR"),
              ],
            ),
            title: Text('Equipes du Rosaire'),
          ),
          body: TabBarView(
            children: [
              Center(
                  child: WebView(
                      initialUrl:"https://app2.equipes-rosaire.org/medit_view.php?login=$login",
                      onPageStarted: (url) async {
                        print('++94 : $url ($login)');
                        gestionEtat();

                      })),


              Center(child: Builder(builder: (context) {

                return isLogged == true ? 
                
                //Cpte_FormEdit(login)
                WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl:
              'https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login',
              onPageStarted: (url) async {
                print('++107 : $url login : $login');
                var exp = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(exp)) {
                            login =
                                exp.allMatches(url.toString(), 0).first[0]!;
                          }
                  print('++120 : $url loginCre : $login');
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
                onPageStarted: (url) async {
                var exp = RegExp(r'(?<=\?login=)[0-9]*',);
                  if (url.contains(exp)) {
                            login =
                                exp.allMatches(url.toString(), 0).first[0]!;
                          }
                  print('++127 : $url loginNew : $login');
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("login", login);

                 gestionEtat();                        
                        
                },//onPageStarted
              );
              
            })),

              Center(
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/journal.php',
                      onPageStarted: (url) async {
                        print('++105 : $url ($login)');
                      })),
              Center(
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/msg_form.php',
                      onPageStarted: (url) async {
                        print('++110 :  $url ($login)');
                      })),
              Center(
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/bonjour.php',
                      onPageStarted: (url) async {
                        print('++115 : $url ($login)');
                      })),
            ],
          ),
        ));
  }
}