import 'package:flutter/material.dart';
import 'package:hello/main.dart';
import 'package:provider/provider.dart';

class TelaAltSenha extends StatelessWidget {
  const TelaAltSenha({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: primaryColor,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: MudarSenhaForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MudarSenhaForm extends StatefulWidget {
  const MudarSenhaForm({super.key});

  @override
  _MudarSenhaFormState createState() => _MudarSenhaFormState();
}

class _MudarSenhaFormState extends State<MudarSenhaForm> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaContreller = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _esconderSenhaAtual = true;
  bool _esconderNovaSenha = true;
  bool _esconderConfirmarSenha = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _senhaAtualController,
            obscureText: _esconderSenhaAtual,
            decoration: InputDecoration(
                labelText: 'Senha atual',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _esconderSenhaAtual
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _esconderSenhaAtual = !_esconderSenhaAtual;
                    });
                  },
                )),
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor, insira sua senha atual';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _novaSenhaContreller,
            obscureText: _esconderNovaSenha,
            decoration: InputDecoration(
              labelText: 'Nova senha',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _esconderNovaSenha ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _esconderNovaSenha = !_esconderNovaSenha;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma nova senha';
              }
              if (value.length < 8) {
                return 'A senha deve ter pelo menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmarSenhaController,
            obscureText: _esconderConfirmarSenha,
            decoration: InputDecoration(
                labelText: 'Confirmar nova senha',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _esconderConfirmarSenha
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _esconderConfirmarSenha = !_esconderConfirmarSenha;
                    });
                  },
                )),
            validator: (valor) {
              if (valor != _novaSenhaContreller.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _mudarSenha();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Alterar Senha'),
          ),
        ],
      ),
    );
  }

  void _mudarSenha() async {
    // Implementa a lógica para alterar a senha
    // Mostra o feedback para o usuário
    if (_formKey.currentState!.validate()) {
      try {
        final auth = Provider.of<AuthManager>(context, listen: false);
        await auth.updateUser({
          'senha': _novaSenhaContreller.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
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
