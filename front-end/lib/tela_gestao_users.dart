import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello/main.dart';
import 'package:hello/admin_manager.dart';

class LogEntry {
  final int idLog;
  final int? idUsuario;
  final int? idRegistro;
  final String tipoUsuario;
  final String? tipoAcaoOld;
  final String tipoAcaoNow;
  final String? nomeUsuarioOld;
  final String nomeUsuarioNow;
  final String? telefoneUsuarioOld;
  final String telefoneUsuarioNow;
  final String? dsRegistroOld;
  final String? dsRegistroNow;
  final String? emailUsuarioExcluido;
  final DateTime dtTrigger;

  LogEntry({
    required this.idLog,
    this.idUsuario,
    this.idRegistro,
    required this.tipoUsuario,
    this.tipoAcaoOld,
    required this.tipoAcaoNow,
    this.nomeUsuarioOld,
    required this.nomeUsuarioNow,
    this.telefoneUsuarioOld,
    required this.telefoneUsuarioNow,
    this.dsRegistroOld,
    this.dsRegistroNow,
    this.emailUsuarioExcluido,
    required this.dtTrigger,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      idLog: map['id_log'],
      idUsuario: map['id_usuario'],
      idRegistro: map['id_registro'],
      tipoUsuario: map['tipo_usuario'],
      tipoAcaoOld: map['tipo_acao_old'],
      tipoAcaoNow: map['tipo_acao_now'],
      nomeUsuarioOld: map['nome_usuario_old'],
      nomeUsuarioNow: map['nome_usuario_now'],
      telefoneUsuarioOld: map['telefone_usuario_old'],
      telefoneUsuarioNow: map['telefone_usuario_now'],
      dsRegistroOld: map['ds_registro_old'],
      dsRegistroNow: map['ds_registro_now'],
      emailUsuarioExcluido: map['email_usuario_excluido'],
      dtTrigger: DateTime.parse(map['dt_trigger']),
    );
  }
}

class TelaGestaoUsers extends StatefulWidget {
  const TelaGestaoUsers({super.key});

  @override
  State<TelaGestaoUsers> createState() => _TelaGestaoUsersState();
}

class _TelaGestaoUsersState extends State<TelaGestaoUsers> {
  late AdminManager adminManager;
  late Future<List<Map<String, dynamic>>> _usuariosFuture;
  late Future<List<LogEntry>> _logsFuture;

  String _modoVisualizacao = 'Usuários'; // alterna entre 'Usuários' e 'Logs'

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthManager>(context, listen: false);
    adminManager = AdminManager(auth.token!);
    _usuariosFuture = adminManager.fetchUsuarios();
    _logsFuture = adminManager.fetchLogs();
  }

  void _atualizarListaUsuarios() {
    setState(() {
      _usuariosFuture = adminManager.fetchUsuarios();
    });
  }

  void _confirmarExclusao(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o usuário $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await adminManager.deleteUsuario(email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Usuário excluído com sucesso!')),
                );
                _atualizarListaUsuarios();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $error')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthManager>(context);
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (auth.user?['tipo'] != 'admin') {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Administração'),
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Acesso restrito a administradores',
                style: GoogleFonts.roboto(fontSize: 18),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Administração'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _modoVisualizacao,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.grey[700],
              style: TextStyle(color: Colors.white), // Texto quando fechado
              selectedItemBuilder: (BuildContext context) {
                return ['Usuários', 'Logs'].map((String value) {
                  return Text(
                    value,
                    style: TextStyle(color: Colors.white), // Texto selecionado
                  );
                }).toList();
              },
              items: ['Usuários', 'Logs'].map((modo) {
                return DropdownMenuItem<String>(
                  value: modo,
                  child: Text(
                    modo,
                    style: TextStyle(color: Colors.white), // Texto dos itens
                  ),
                );
              }).toList(),
              onChanged: (novoValor) {
                setState(() {
                  _modoVisualizacao = novoValor!;
                });
              },
            ),
          ),
        ],
      ),
      body: _modoVisualizacao == 'Usuários'
          ? _buildListaUsuarios()
          : _buildListaLogs(),
    );
  }

  Widget _buildListaUsuarios() {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usuariosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white : primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro: ${snapshot.error}',
                  style: GoogleFonts.roboto(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Nenhum usuário encontrado',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final usuario = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]!.withOpacity(0.3)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                    ),
                  ),
                  title: Text(
                    usuario['nome'],
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${usuario['email']} | ${usuario['tipo_usuario']}',
                    style: GoogleFonts.roboto(),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[400],
                    ),
                    onPressed: () => _confirmarExclusao(usuario['email']),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListaLogs() {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<LogEntry>>(
      future: _logsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white : primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar logs',
                  style: GoogleFonts.roboto(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Nenhum log encontrado',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final log = snapshot.data![index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLogColor(log.tipoAcaoNow, isDarkMode),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: _getLogIcon(log.tipoAcaoNow),
                    title: Text(
                      _getTituloLog(log),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getTextColor(log.tipoAcaoNow, isDarkMode),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _getSubtituloLog(log),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _getTextColor(log.tipoAcaoNow, isDarkMode),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(log.dtTrigger),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: _getTextColor(log.tipoAcaoNow, isDarkMode),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: _getTextColor(log.tipoAcaoNow, isDarkMode),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getLogColor(String tipoAcao, bool isDarkMode) {
    if (isDarkMode) {
      switch (tipoAcao) {
        case 'INSERT':
          return Colors.green[900]!.withOpacity(0.3);
        case 'UPDATE':
          return Colors.blue[900]!.withOpacity(0.3);
        case 'DELETE':
          return Colors.red[900]!.withOpacity(0.3);
        default:
          return Colors.grey[900]!.withOpacity(0.3);
      }
    } else {
      switch (tipoAcao) {
        case 'INSERT':
          return Colors.green.withOpacity(0.1);
        case 'UPDATE':
          return Colors.blue.withOpacity(0.1);
        case 'DELETE':
          return Colors.red.withOpacity(0.1);
        default:
          return Colors.grey.withOpacity(0.1);
      }
    }
  }

  Color _getTextColor(String tipoAcao, bool isDarkMode) {
    if (isDarkMode) {
      switch (tipoAcao) {
        case 'INSERT':
          return Colors.green[200]!;
        case 'UPDATE':
          return Colors.blue[200]!;
        case 'DELETE':
          return Colors.red[200]!;
        default:
          return Colors.grey[200]!;
      }
    } else {
      switch (tipoAcao) {
        case 'INSERT':
          return Colors.green[800]!;
        case 'UPDATE':
          return Colors.blue[800]!;
        case 'DELETE':
          return Colors.red[800]!;
        default:
          return Colors.grey[800]!;
      }
    }
  }

  Widget _getLogIcon(String tipoAcao) {
    switch (tipoAcao) {
      case 'INSERT':
        return Icon(Icons.add_circle, color: Colors.green[800]);
      case 'UPDATE':
        return Icon(Icons.edit, color: Colors.blue[800]);
      case 'DELETE':
        return Icon(Icons.delete, color: Colors.red[800]);
      default:
        return Icon(Icons.history, color: Colors.grey[800]);
    }
  }

  String _getTituloLog(LogEntry log) {
    switch (log.tipoAcaoNow) {
      case 'INSERT':
        return 'Novo ${log.tipoUsuario}: ${log.nomeUsuarioNow}';
      case 'UPDATE':
        return 'Atualização: ${log.nomeUsuarioNow}';
      case 'DELETE':
        return 'Exclusão: ${log.emailUsuarioExcluido ?? "Registro"}';
      default:
        return 'Ação desconhecida';
    }
  }

  String _getSubtituloLog(LogEntry log) {
    if (log.tipoAcaoNow == 'UPDATE') {
      return 'De: ${log.nomeUsuarioOld ?? "N/A"} | Para: ${log.nomeUsuarioNow}';
    }
    return 'ID: ${log.idLog} | Tipo: ${log.tipoUsuario}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
