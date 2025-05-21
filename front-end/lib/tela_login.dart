import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello/main.dart';
import 'tela_cadastro.dart'; // Importa a tela de cadastro
import 'tela_alt_senha.dart'; // Importa a tela de alteração de senha

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess; // Função callback para quando o login for bem-sucedido

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _esconderTexto = true;

  void _alternarVisibilidadeTexto() {
    setState(() {
      _esconderTexto = !_esconderTexto;
    });
  }

  // Função que verifica se o login é válido
  void _login(BuildContext context) async {
    try {
      final auth = Provider.of<AuthManager>(context, listen: false);
      await auth.login(_emailController.text, _senhaController.text);
      widget.onLoginSuccess();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  // Função para navegar até a tela de cadastro
  void _navegarParaCadastro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroScreen(
          onCadastroConcluido: () {
            Navigator.pop(context); // Volta para o login após o cadastro
          },
        ),
      ),
    );
  }

  // Função para navegar até a tela de esqueci a senha
  void _navegarParaEsqueciSenha(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TelaAltSenha(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor; // Cor primária do tema (azul de fundo)

    return Scaffold(
      backgroundColor: primaryColor, // Define o fundo azul da tela
      body: SafeArea(
        // Garante que o conteúdo não ultrapasse as bordas seguras do sistema
        child: Center(
          // Centraliza o conteúdo
          child: SingleChildScrollView(
            // Permite rolagem caso o conteúdo ultrapasse a tela
            padding: const EdgeInsets.all(24), // Espaçamento em volta do conteúdo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
              children: [
                // Espaçamento do topo
                const SizedBox(height: 40),

                // IMAGEM NO TOPO DA TELA (PARTE AZUL)
                const CircleAvatar(
                  radius: 60, // raio do círculo
                  backgroundImage: AssetImage('assets/safe-gate-img.png'), // imagem carregada
                  backgroundColor: Colors.transparent, // fundo transparente
                  ),


                const SizedBox(height: 24), // Espaço entre imagem e card

                // CONTAINER BRANCO DO LOGIN
                Card(
                  elevation: 2, // Sombra
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Arredonda as bordas do Card
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32), // Espaçamento interno do card
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TÍTULO LOGIN
                        Text(
                          'LOGIN',
                          style: GoogleFonts.roboto(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32), // Espaço após o título

                        // CAMPO DE EMAIL
                        TextField(
                          controller: _emailController, // Controlador do campo
                          decoration: InputDecoration(
                            labelText: 'Email', // Texto do rótulo
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12), // Borda arredondada
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Espaço entre os campos

                        // CAMPO DE SENHA
                        TextField(
                          controller: _senhaController, // Controlador do campo
                          obscureText: _esconderTexto, // Esconde a senha
                          decoration: InputDecoration(
                            labelText: 'Senha', // Rótulo do campo
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_esconderTexto ? Icons.visibility : Icons.visibility_off),
                              onPressed: _alternarVisibilidadeTexto,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8), // Espaço abaixo do campo

                        // BOTÃO "ESQUECEU A SENHA"
                        Align(
                          alignment: Alignment.centerRight, // Alinha à direita
                          child: TextButton(
                            onPressed: () {
                              _navegarParaEsqueciSenha(context); // Chama função de navegação
                            },
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(color: Colors.blue), // Cor azul no texto
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // BOTÃO DE LOGIN
                        ElevatedButton(
                          onPressed: () => _login(context), // Chama a função de login
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Tamanho do botão
                            backgroundColor: const Color(0xFF007AFF), // Cor de fundo do botão
                            foregroundColor: Colors.white, // Cor do texto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Borda arredondada
                            ),
                          ),
                          child: const Text('Entrar'), // Texto do botão
                        ),
                        const SizedBox(height: 16), // Espaço após o botão

                        // DIVISOR COM "OU"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // BOTÃO DE CRIAR CONTA
                        TextButton(
                          onPressed: () => _navegarParaCadastro(context), // Chama a tela de cadastro
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              color: Colors.blue, // Texto azul
                              fontWeight: FontWeight.bold, // Negrito
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
