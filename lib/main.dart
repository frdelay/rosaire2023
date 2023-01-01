//https://stackoverflow.com/questions/59324921/flutter-dart-how-to-make-data-load-on-the-first-tab-when-launching-application



import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'notification.dart';

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
  //late final LocalNotificationService localNotificationService;

  //bool isLogged = false;
  String login = "";

  @override
  void initState() {
    super.initState();  

    //localNotificationService = LocalNotificationService();
    //localNotificationService.init();

    gestionEtat();
  }

  


                          
  bool? oldIsLogged;
  String gestCpte = "Crécpte";
  String urlGestCpte = "https://app2.equipes-rosaire.org/cpte_formcre.php";
  String urlMedit ="";

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
      print ("++72 : gestionEtat login $login");
      }else{

        setState(() {
          gestCpte = "Modifcpte";
          urlGestCpte =
              "https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login";
          urlMedit='https://app2.equipes-rosaire.org/medit_view.php?login=$login';

        //localNotificationService.generate30Notifications(meditationNumber: 1,); //introduire nummedit,

        });
      print ("++84 : gestionEtat login $login");

    }
  }


  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car), text: "EdR"),
                Tab(icon: Icon(Icons.directions_transit), text: "Medit"),
                Tab(icon: Icon(Icons.directions_bike), text: "$gestCpte"),
                Tab(icon: Icon(Icons.directions), text: "Journal"),
                Tab(icon: Icon(Icons.alarm), text: "Contact"),

              ],
            ),
            title: Text('Equipes du Rosaire'),
          ),
          body: TabBarView(
            children: [

              Center(
                  child: WebView(
                      initialUrl:
                          'https://app2.equipes-rosaire.org/bonjour.php',
                      onPageStarted: (url) async {
                        print('++115 : $url ($login)');
                      })),

              Center(child: Builder(builder: (context) {

                return login!= "0" ? 
                WebView(  
                  initialUrl: urlMedit,
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageStarted: (url) async {
                    print('++105 : $url ($login)');
              }
              )
              :
              WebView(  
                  initialUrl:urlMedit, 
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageStarted: (url) async {
                    print('++113 : $url ($login)');
              }
              );
              }
              )
              ),


              Center(child: Builder(builder: (context) {

                return login != "0" ? 
                
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

            ],
          ),
        ));
  }
}