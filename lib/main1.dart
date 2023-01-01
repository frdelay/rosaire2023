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
    redirection();
  }


  bool? oldIsLogged;

  redirection() async {print("main.dart : redirection");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('login') == null) {
      print("main.dart : SharedPref isLogged false");
      isLogged = false;
      if(oldIsLogged!=isLogged){
      setState(() {
        isLogged = false;
        oldIsLogged=isLogged;
      });
      print("main.dart : SharedPref isLogged false  isLogged = $isLogged  oldIsLogged = $oldIsLogged");
}
    } else {
      login = (prefs.getString('login'))!;
      print("main.dart : SharedPref login = $login");
      isLogged = true;
      if(oldIsLogged!=isLogged){
        setState(() {
          isLogged = true;
          oldIsLogged=isLogged;
        });
        print("main.dart : SharedPref login = $login  isLogged = $isLogged  oldIsLogged = $oldIsLogged");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    redirection();
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("EdR"),
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Medit_Liste(),
                  ));
              redirection();
            },
            child: const Text('ListMéd'),
          ),
          if (isLogged == false)
            TextButton(
              style: style,
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cpte_FormCre(),
                    ));
                redirection();
              },
              child: const Text('CréCpte'),
            )
          else
            TextButton(
              style: style,
              onPressed: () async {
                redirection();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cpte_FormEdit(login),
                    ));
                print('edit : $login');
              },
              child:  Text('edit $login'),
            ),
          TextButton(
            style: style,
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Journal(),
                  ));
              redirection();
            },
            child: const Text('Jal'),
          ),
          TextButton(
            style: style,
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Contact(),
                  ));
              redirection();
            },
            child: const Text('Ctact'),
          ),
        ],
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl:  (isLogged == true ? 'https://app2.equipes-rosaire.org/medit_view.php?login=$login' : 'https://app2.equipes-rosaire.org/medit_liste.php'),
        onWebViewCreated: (controller1) {controller=controller1;},
          onPageFinished: (url) {print('main.dart url : $url');},
      ),
    );
  }
}

class Medit_Liste extends StatefulWidget {
  @override
  State<Medit_Liste> createState() => _Medit_ListeState();
}

class _Medit_ListeState extends State<Medit_Liste> {
    late WebViewController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, les méditations"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/medit_liste.php',
          onWebViewCreated: (controller1) {controller=controller1;},
          onPageFinished: (url) {print('main.dart url : $url');},
        ),
      );
}

class Medit_View extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, les méditations"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/medit_view.php?nummedit=',
        ),
      );
}

class Cpte_FormCre extends StatefulWidget {

  @override
  State<Cpte_FormCre> createState() => _Cpte_FormCreState();
}

class _Cpte_FormCreState extends State<Cpte_FormCre> {
  
  String loginNew="";
  @override
  Widget build(BuildContext context) => Scaffold(
    
        appBar: AppBar(title: Text("Equipes du Rosaire, créer compte"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/cpte_formcre.php',
          onPageStarted: (url) async {
            var exp = RegExp(
              r'(?<=\?login=)[0-9]*',
            );
            if (url.contains(exp)) {
              loginNew = exp.allMatches(url.toString(), 0).first[0]!;
            }
            print('main.dart cpte_formcre : $url loginNew : $loginNew');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("login", loginNew);
          },
        ),
      );
}


class Cpte_FormEdit extends StatelessWidget {

final String loginCFE;
Cpte_FormEdit(this.loginCFE);

  @override


  @override
  
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, modif compte"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/cpte_formedit.php?login=$loginCFE',
          onPageStarted: (url) async {

            print('main.dart cpte_formedit : $url login : $loginCFE');
          },
        ),
      );

}
/*
class Cpte_FormEdit extends StatelessWidget {
  String login = "";
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, modifier compte"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/cpte_formedit.php?login=$login',
        ),
      );
}
*/
class Journal extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, ils méditent"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/journal.php',
        ),
      );
}

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Equipes du Rosaire, contact"),),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/msg_form.php',
        ),
      );
}
