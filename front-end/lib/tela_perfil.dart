import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello/main.dart';
import 'package:provider/provider.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Conta',
          style: GoogleFonts.roboto(),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthManager>(
        builder: (context, auth, child) {
          final user = auth.user ?? {};
          return Container(
            color: primaryColor,
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 48),
                      ),
                      title: Text(
                        user['nome'] ?? 'Usuário',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user['email'] ?? '',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FormularioPerfil(user: user),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FormularioPerfil extends StatefulWidget {
  final Map<String, dynamic> user;

  const FormularioPerfil({super.key, required this.user});

  @override
  State<FormularioPerfil> createState() => _FormularioPerfilState();
}

class _FormularioPerfilState extends State<FormularioPerfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _cpfController;
  late TextEditingController _emailController;
  late TextEditingController _tipoUsuarioController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user['nome'] ?? '');
    _telefoneController = TextEditingController(text: widget.user['telefone'] ?? '');
    _cpfController = TextEditingController(text: widget.user['cpf'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _tipoUsuarioController = TextEditingController(
      text: widget.user['tipo_usuario'] == 'admin' ? 'admin' : 'cliente'
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _tipoUsuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cpfController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'CPF',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefoneController,
            decoration: InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tipoUsuarioController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tipo de Usuário',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _salvarAlteracoes,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar Alterações'),
          )
        ],
      ),
    );
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = Provider.of<AuthManager>(context, listen: false);
        await auth.updateUser({
          'nome': _nomeController.text.isNotEmpty ? _nomeController.text : null,
          'telefone': _telefoneController.text.isNotEmpty ? _telefoneController : null,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}
