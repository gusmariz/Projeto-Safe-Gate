import 'package:flutter/material.dart';

class CadastroScreen extends StatelessWidget {
  final VoidCallback onCadastroConcluido;

  CadastroScreen({super.key, required this.onCadastroConcluido});

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  void _cadastrar(BuildContext context) {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );
    onCadastroConcluido();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4682B4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A6A97),
        title: const Text('Cadastro'),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start, // Alinha no topo
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Cadastro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nomeController,
                decoration: _inputDecoration('Nome'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: _inputDecoration('Senha'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: _inputDecoration('Confirmar Senha'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _cadastrar(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4682B4),
                ),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
