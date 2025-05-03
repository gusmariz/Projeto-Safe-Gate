import 'package:flutter/material.dart';
import 'tela_cadastro.dart'; // Certifique-se de que o caminho esteja correto

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  LoginScreen({super.key, required this.onLoginSuccess});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _login(BuildContext context) {
    final email = _emailController.text;
    final senha = _senhaController.text;

    if (email == 'admin' && senha == '1234') {
      onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas')),
      );
    }
  }

  void _navegarParaCadastro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroScreen(
          onCadastroConcluido: () {
            Navigator.pop(context); // Retorna para o login após o cadastro
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4682B4), // Cor de fundo da tela de login
      body: SafeArea(
        child: Center(
          // Centraliza o conteúdo na tela
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Flex(
              direction: Axis.vertical, // Layout Flexbox vertical
              mainAxisAlignment:
                  MainAxisAlignment.center, // Alinha os itens verticalmente
              children: [
                const SizedBox(height: 40), // Espaço para o topo da tela

                // Contêiner branco que envolve o conteúdo de login
                Container(
                  padding:
                      const EdgeInsets.all(32), // Padding interno do quadrado
                  decoration: BoxDecoration(
                    color: Colors.white, // Cor de fundo do container
                    borderRadius:
                        BorderRadius.circular(16), // Bordas arredondadas
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4), // Sombra suave
                      ),
                    ],
                  ),
                  child: Flex(
                    direction: Axis.vertical, // Flexbox vertical
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título do login
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4682B4), // Cor do título
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Campo de email
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de senha
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _senhaController,
                          obscureText: true,
                          decoration: _inputDecoration('Senha'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Botão "Esqueceu a senha?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Ação para recuperar senha
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(color: Color(0xFF4682B4)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Botão de login
                      ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          backgroundColor:
                              const Color(0xFF4682B4), // Cor de fundo
                          foregroundColor: Colors.white, // Cor do texto
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),

                      // Divisor com "ou"
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'ou',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.black)),
                        ],
                      ),

                      // Botão para criar conta
                      TextButton(
                        onPressed: () => _navegarParaCadastro(context),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: Color(0xFF4682B4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
