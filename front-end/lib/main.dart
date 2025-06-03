import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tela_login.dart';
import 'tela_alt_senha.dart';
import 'tela_historico.dart';

void main() => runApp(const MyApp());

class HistoricoManager extends ChangeNotifier {
  final AuthManager authManager;
  HistoricoManager(this.authManager);

  Future<List<ItemHistorico>> fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('https://projeto-safe-gate-production.up.railway.app/gate/history'),
        headers: {
          'Authorization': 'Bearer ${authManager._token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => ItemHistorico(
                  item['descricao'] ?? 'Ação no portão',
                  _formatTime(item['dt_acao']),
                  _getDiaSemana(DateTime.parse(item['dt_acao']).weekday),
                  _formatDate(item['dt_acao']),
                ))
            .toList();
      } else {
        throw Exception('Falha ao carregar histórico');
      }
    } catch (error) {
      throw Exception('Erro de conexão: $error');
    }
  }

  String _formatTime(String dateTime) {
    final dt = DateTime.parse(dateTime);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateTime) {
    final dt = DateTime.parse(dateTime);
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  final List<ItemHistorico> _historico = [];
  int _aberturas = 0;
  int _fechamentos = 0;
  int _paradas = 0;
  String? _ultimaAcao;

  List<ItemHistorico> get historico => List.from(_historico.reversed);
  int get totalAcoes => _aberturas + _fechamentos + _paradas;
  int get aberturas => _aberturas;
  int get fechamentos => _fechamentos;
  int get paradas => _paradas;

  bool podeRealizarAcao(String novaAcao) {
    return _ultimaAcao == null || _ultimaAcao != novaAcao;
  }

  int getContador(String tipoAcao) {
    switch (tipoAcao.toLowerCase()) {
      case 'abrir':
        return _aberturas;
      case 'fechar':
        return _fechamentos;
      case 'parar':
        return _paradas;
      default:
        return 0;
    }
  }

  Future<void> adicionarAcao(String acao) async {
    if (!podeRealizarAcao(acao)) {
      throw Exception('Ação bloqueada: Portão já $acao');
    }

    if (authManager._token == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final response = await http.post(
        Uri.parse('https://projeto-safe-gate-production.up.railway.app/gate/action'),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer ${authManager._token}',
        },
        body: jsonEncode({'acao': acao, 'descricao': 'Portão $acao'}),
      );

      if (response.statusCode == 200) {
        final now = DateTime.now();
        final item = ItemHistorico(
          'Portão $acao',
          '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          _getDiaSemana(now.weekday),
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
        );

        _historico.add(item);
        _ultimaAcao = acao;

        switch (acao) {
          case 'abrir':
            _aberturas++;
            break;
          case 'fechar':
            _fechamentos++;
            break;
          case 'parar':
            _paradas++;
            break;
        }
        notifyListeners();
      } else {
        throw Exception(
            jsonDecode(response.body)['error'] ?? 'Falha ao executar ação');
      }
    } catch (error) {
      throw Exception('Erro de conexão: $error');
    }
  }

  void removerItem(ItemHistorico item) {
    final index = historico.indexWhere((i) =>
        i.titulo == item.titulo &&
        i.hora == item.hora &&
        i.dia == item.dia &&
        i.data == item.data);

    if (index != -1) {
      final itemRemovido = _historico.removeAt(index);
      final acao = itemRemovido.titulo.replaceAll('Joãozinho', '').trim();

      switch (acao) {
        case 'abrir':
          _aberturas--;
          break;
        case 'fechar':
          _fechamentos--;
          break;
        case 'parar':
          _paradas--;
          break;
      }

      if (_historico.isEmpty) {
        _ultimaAcao = null;
      } else if (_historico.last.titulo.contains(acao)) {
        _ultimaAcao = acao;
      }

      notifyListeners();
    }
  }

  String _getDiaSemana(int weekday) {
    const dias = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return dias[weekday % 7];
  }
}

class AuthManager extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('https://projeto-safe-gate-production.up.railway.app/auth/login'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _user = responseData['user'];
        notifyListeners();
      } else {
        throw Exception(
            jsonDecode(response.body)['error'] ?? 'Credenciais inválidas');
      }
    } catch (error) {
      throw Exception('Erro ao fazer login: $error');
    }
  }

  Future<void> register(Map<String, String> dados) async {
    try {
      final response = await http.post(
        Uri.parse('https://projeto-safe-gate-production.up.railway.app/auth/register'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'nome': dados['nome'],
          'email': dados['email'],
          'senha': dados['senha'],
          'cpf': dados['cpf'],
          'telefone': dados['telefone'],
          'tipo_usuario': 'cliente'
        }),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Erro ao registrar');
      }
    } catch (error) {
      throw Exception('Erro ao registrar: $error');
    }
  }

  Future<void> updateUser(Map<String, String> dados) async {
    try {
      final response = await http.put(
        Uri.parse('https://projeto-safe-gate-production.up.railway.app/auth/update'),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(dados),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar usuário');
      }
    } catch (error) {
      throw Exception('Erro ao atualizar: $error');
    }
  }

  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authManager),
        ChangeNotifierProvider(
          create: (context) => HistoricoManager(authManager),
        ),
      ],
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
          '/telaHistorico': (context) => const TelaHistorico(),
          '/telaAltSenha': (context) => const TelaAltSenha(),
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
    required String acaoTipo,
  }) {
    return Consumer<HistoricoManager>(
      builder: (context, historico, child) {
        final podeExecutar = historico.podeRealizarAcao(acaoTipo);

        return Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          elevation: 6,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: podeExecutar
                ? () async {
                    try {
                      await historico.adicionarAcao(acaoTipo);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erro: ${error.toString()}'),
                        duration: const Duration(seconds: 1),
                      ));
                    }
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Ação bloqueada: Portão já $acaoTipo'),
                      duration: const Duration(seconds: 1),
                    ));
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    Text(
                      '${historico.getContador(acaoTipo)}',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<AuthManager>(
                builder: (context, auth, child) => ListTile(
                  title: Text(
                    auth.user?['nome'] ?? 'Usuário',
                    style: TextStyle(
                      fontSize: 20.8,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 36),
                  ),
                  subtitle: Text(
                    auth.user?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 2),
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
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.lock,
                color: Colors.grey[700],
              ),
              title: const Text(
                'Alterar senha',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/telaAltSenha');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.grey[700],
              ),
              title: const Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/telaHistorico');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red[400],
              ),
              title: const Text(
                'Sair',
                style: TextStyle(
                  fontSize: 20.8,
                ),
              ),
              onTap: () {
                Provider.of<AuthManager>(context, listen: false).logout();
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
                  child: Consumer<HistoricoManager>(
                    builder: (context, historico, child) {
                      return Column(
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
                            '${historico.totalAcoes}',
                            style: GoogleFonts.inter(
                              fontSize: 64,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 300,
              height: 225,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBotaoAcao(
                    context: context,
                    texto: 'ABRIR',
                    icone: Icons.lock_open,
                    acaoTipo: 'abrir',
                  ),
                  _buildBotaoAcao(
                    context: context,
                    texto: 'FECHAR',
                    icone: Icons.lock,
                    acaoTipo: 'fechar',
                  ),
                  _buildBotaoAcao(
                    context: context,
                    texto: 'PARAR',
                    icone: Icons.cancel,
                    acaoTipo: 'parar',
                  ),
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
                padding: const EdgeInsets.all(16),
                child: Consumer<HistoricoManager>(
                  builder: (context, historico, child) {
                    if (historico.historico.isEmpty) {
                      return const SizedBox(
                        height: 35,
                        child: Center(
                          child: Text(
                            'Nenhuma ação registrada',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    final ultimo = historico.historico.first;
                    final acao = ultimo.titulo.replaceAll('Joãozinho', '');

                    return SizedBox(
                      height: 35,
                      child: Center(
                        child: Text(
                          'Último: registro: Portão$acao às ${ultimo.hora} | ${ultimo.dia} | ${ultimo.data}',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
