import 'package:flutter/material.dart';

class TelaAltSenha extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alterar Senha'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MudarSenhaForm(),
      ),
    );
  }
}

class MudarSenhaForm extends StatefulWidget {

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
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_esconderSenhaAtual ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _esconderSenhaAtual = !_esconderSenhaAtual;
                  });
                },
              )
            ),
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor, insira sua senha atual';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _novaSenhaContreller,
            obscureText: _esconderNovaSenha,
            decoration: InputDecoration(
              labelText: 'Nova senha',
              prefixIcon: Icon(Icons.lock_outline),
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
          SizedBox(height: 16),
          TextFormField(
            controller: _confirmarSenhaController,
            obscureText: _esconderConfirmarSenha,
            decoration: InputDecoration(
              labelText: 'Confirmar nova senha',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_esconderConfirmarSenha ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _esconderConfirmarSenha = !_esconderConfirmarSenha;
                  });
                },
              )
            ),
            validator: (valor) {
              if (valor != _novaSenhaContreller.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _mudarSenha();
              }
            },
            child: Text('Alterar Senha'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _mudarSenha() {
    // Implementa a lógica para alterar a senha
    // Mostra o feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Senha alterada com sucesso!')),
    );

    // Volta para a tela anterior após o processo concluído
    Navigator.pop(context);
  }
}