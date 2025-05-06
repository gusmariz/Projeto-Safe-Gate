import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tela_cadastro.dart'; // Certifique-se de que o caminho esteja correto
import 'tela_alt_senha.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  LoginScreen({super.key, required this.onLoginSuccess});

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

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

  void _navegarParaEsqueciSenha(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaAltSenha(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor, // Cor de fundo da tela de login
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
                Card(
                  elevation: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.all(32), // Padding interno do quadrado
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Flex(
                      direction: Axis.vertical, // Flexbox vertical
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Título do login
                        Text(
                          'LOGIN',
                          style: GoogleFonts.roboto(
                            fontSize: 32,
                            fontWeight: FontWeight.bold, // Cor do título
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Campo de email
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              // suffixIcon: IconButton(
                              //   icon: Icon(true ? Icons.visibility : Icons.visibility_off),
                              //   onPressed: () {
                              //     SetState(() {

                              //     })
                              //   },
                              // )
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de senha
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _senhaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              // suffixIcon: IconButton(
                              //   icon: Icon(true ? Icons.visibility : Icons.visibility_off),
                              //   onPressed: () {
                              //     SetState(() {

                              //     })
                              //   },
                              // )
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Botão "Esqueceu a senha?"
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _navegarParaEsqueciSenha(context);
                            },
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(color: Colors.blue),
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
                            backgroundColor: primaryColor, // Cor de fundo
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
                            Expanded(child: Divider(thickness: 2)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('ou'),
                            ),
                            Expanded(child: Divider(thickness: 2)),
                          ],
                        ),

                        // Botão para criar conta
                        TextButton(
                          onPressed: () => _navegarParaCadastro(context),
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
