import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Equipes du Rosaire"),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            style: style,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Journal(),
                  ));
            },
            child: const Text('Ils méditent'),
          ),
          TextButton(
            style: style,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Contact(),
                  ));
            },
            child: const Text('Contact'),
          ),
        ],
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: 'https://app2.equipes-rosaire.org/accueil.php?Edit=N',
        onWebViewCreated: (controller) {
          this.controller=controller;
        },
          onPageFinished: (url) {
          var log = url.substring(58);            
          print('site : $url login $log');
          },
      ),
    );
  }
}

class Journal extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Equipes du Rosaire, ils méditent"),
          centerTitle: true,
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://app2.equipes-rosaire.org/journal.php',
        ),
      );
}

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Equipes du Rosaire, contact"),
          centerTitle: true,
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https:///app2.equipes-rosaire.org/msg_form.php',
        ),
      );
}
