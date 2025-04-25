import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O Portão (Miniatura)',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(primaryColor: const Color(0xFF269653))
          : ThemeData.light().copyWith(primaryColor: const Color(0xFF34C759)),
      home: MyHomePage(
        onThemeChanged: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Icon(Icons.star, color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? (Icons.light_mode) : Icons.dark_mode,
                color: Colors.white),
            onPressed: onThemeChanged,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 180,
                  height: 200,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Total de vezes utilizado',
                            style: TextStyle(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // SizedBox(height: 15),
                          Text(
                            '0',
                            style: TextStyle(fontSize: 64),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 65,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.arrow_circle_left),
                                Text('Abrir', style: TextStyle(fontSize: 19.2)),
                                Text('0', style: TextStyle(fontSize: 19.2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 65,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.arrow_circle_right),
                                Text('Fechar',
                                    style: TextStyle(fontSize: 19.2)),
                                Text('0', style: TextStyle(fontSize: 19.2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 65,
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.stop_circle),
                                Text('Parar', style: TextStyle(fontSize: 19.2)),
                                Text('0', style: TextStyle(fontSize: 19.2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Último registro: 13:15 | Quinta-feira | Abril 2025',
                      style: TextStyle(fontSize: 24),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Colors.white),
              label: 'Histórico'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.white), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Colors.white),
              label: 'Configurações'),
        ],
      ),
    );
  }
}
