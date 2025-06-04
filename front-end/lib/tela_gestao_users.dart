import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello/main.dart';
import 'package:hello/admin_manager.dart';

class TelaGestaoUsers extends StatefulWidget {
  const TelaGestaoUsers({super.key});

  @override
  State<TelaGestaoUsers> createState() => _TelaGestaoUsersState();
}

class _TelaGestaoUsersState extends State<TelaGestaoUsers> {
  late AdminManager adminManager;
  late Future<List<Map<String, dynamic>>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthManager>(context, listen: false);
    adminManager = AdminManager(auth.token!);
    _usuariosFuture = adminManager.fetchUsuarios();
  }

  void _atualizarLista() {
    setState(() {
      _usuariosFuture = adminManager.fetchUsuarios();
    });
  }

  void _confirmarExclusao(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confimar exclusão'),
        content: Text('Deseja realmente excluir o usuário $email'),
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
                  const SnackBar(content: Text('Usuário excluído com sucesso!')),
                );
                _atualizarLista();
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $error')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthManager>(context);

    if (auth.user?['tipo'] != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestão de Usuários')),
        body: const Center(child: Text('Acesso restrito a administradores')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestão de Usuários')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado'));
          }

          final usuarios = snapshot.data!;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(usuario['nome']),
                  subtitle: Text('${usuario['email']} | ${usuario['tipo_usuario']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(usuario['email']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
