import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tela_historico.dart';
import 'tela_login.dart';
import 'tela_alt_senha.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class HistoricoManager extends ChangeNotifier {
  final List<ItemHistorico> _historico = [];

  List<ItemHistorico> get historico => _historico;

  void adicionarAcao(String acao) {
    final now = DateTime.now();
    final item = ItemHistorico("Joãzinho $acao", "${now.hour}:${now.minute.toString().padLeft(2, '0')}", _getDiaSemana(now.weekday), "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}",);
    _historico.add(item);
    notifyListeners();
  }

  String _getDiaSemana(int weekday) {
    const dias = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
    return dias[weekday % 7];
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final historicoManager = HistoricoManager();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => historicoManager,
      child: MaterialApp(
        title: 'SafeGate',
        debugShowCheckedModeBanner: false,
        theme: _isDarkMode
            ? ThemeData.dark().copyWith(primaryColor: const Color(0xFF002366))
            : ThemeData.light().copyWith(primaryColor: const Color(0xFF4682B4)),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(
                onLoginSuccess: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
          '/home': (context) => MyHomePage(
                isDarkMode: _isDarkMode,
                onThemeChanged: () {
                  setState(
                    () {
                      _isDarkMode = !_isDarkMode;
                    },
                  );
                },
              ),
          '/telaHistorico': (context) => TelaHistorico(),
          '/telaAltSenha': (context) => TelaAltSenha(),
        },
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

  Widget _buildBotaoAcao({
    required BuildContext context,
    required String texto,
    required IconData icone,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icone),
                Text(
                  texto,
                  style: GoogleFonts.roboto(
                    fontSize: 25.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<HistoricoManager>(
                  builder: (context, historico, child) {
                    final count = historico.historico
                        .where((item) => item.titulo.contains(texto))
                        .length;
                    return Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 25.6,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historico = Provider.of<HistoricoManager>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'SafeGate',
          style: GoogleFonts.workSans(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
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
              onTap: () {
                Navigator.pushNamed(context, '/telaAltSenha');
              },
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
              onTap: () {
                Navigator.pushNamed(context, '/telaHistorico');
              },
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
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
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
                color: Theme.of(context).primaryColor,
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
                  _buildBotaoAcao(
                      context: context,
                      texto: 'ABRIR',
                      icone: Icons.lock_open,
                      onPressed: () {
                        historico.adicionarAcao('abriu');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Portão aberto!'),
                          duration: Duration(seconds: 2),
                        ),);
                      },),
                  _buildBotaoAcao(
                      context: context,
                      texto: 'FECHAR',
                      icone: Icons.lock,
                      onPressed: () {
                        historico.adicionarAcao('fechou');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Portão fechado!'),
                          duration: Duration(seconds: 2),
                        ),);
                      },),
                  _buildBotaoAcao(
                      context: context,
                      texto: 'PARAR',
                      icone: Icons.cancel,
                      onPressed: () {
                        historico.adicionarAcao('parou');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Portão parado!'),
                          duration: Duration(seconds: 2),
                        ),);
                      },),
                ],
              ),
            ),
            Card(
              color: Theme.of(context).primaryColor,
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
