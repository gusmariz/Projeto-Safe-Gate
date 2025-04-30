import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      title: 'Safe Gate',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(primaryColor: const Color(0xFF002366))
          : ThemeData.light().copyWith(primaryColor: const Color(0xFF4682B4)),
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 300,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
        ),
        elevation: 10,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Olá, Joãozinho!',
                      style: TextStyle(
                        fontSize: 18.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Joãozinho',
                  style: TextStyle(
                    fontSize: 20.8,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                leading: CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person, size: 36),
                ),
                subtitle: Text(
                  'Ver perfil',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Divider(height: 2),
            ListTile(
              leading: Icon(
                Icons.brightness_6,
                color: Colors.grey[700],
              ),
              title: const Text(
                'Tema',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  onThemeChanged();
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.lock,
                color: Colors.grey[700],
              ),
              title: Text(
                'Alterar senha',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {},
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.grey[700],
              ),
              title: Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {},
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red[400],
              ),
              title: Text(
                'Sair',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF002366)
                    : Color(0xFF4682B4),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Total de vezes utilizado',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '0',
                        style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 300,
              height: 225,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2D3748)
                          : Colors.white,
                      elevation: 6,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.arrow_circle_left),
                            Text(
                              'ABRIR',
                              style: GoogleFonts.roboto(
                                fontSize: 25.6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '0',
                              style: GoogleFonts.inter(
                                fontSize: 25.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2D3748)
                          : Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.arrow_circle_right),
                            Text(
                              'FECHAR',
                              style: GoogleFonts.roboto(
                                fontSize: 25.6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '0',
                              style: GoogleFonts.inter(
                                fontSize: 25.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF2D3748)
                          : Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.stop_circle),
                            Text(
                              'PARAR',
                              style: GoogleFonts.roboto(
                                fontSize: 25.6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '0',
                              style: GoogleFonts.inter(
                                fontSize: 25.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF002366)
                  : Color(0xFF4682B4),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  height: 35,
                  child: Center(
                    child: Text(
                      'Último registro: 13:15 | Quinta-feira | 16 Abril 2025',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
    );
  }
}
