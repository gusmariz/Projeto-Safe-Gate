import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello/main.dart';
import 'package:provider/provider.dart';

class CadastroScreen extends StatefulWidget {
  final VoidCallback onCadastroConcluido;
  const CadastroScreen({super.key, required this.onCadastroConcluido});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  String? _tipoUsuario;
  bool _tipoUsuarioInvalido = false;

  void _cadastrar(BuildContext context) async {
    setState(() {
      _tipoUsuarioInvalido = _tipoUsuario == null;
    });

    if (_formKey.currentState!.validate() && !_tipoUsuarioInvalido) {
      if (_senhaController.text != _confirmarSenhaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem')),
        );
        return;
      }

      try {
        final auth = Provider.of<AuthManager>(context, listen: false);
        await auth.register({
          'nome': _nomeController.text,
          'email': _emailController.text,
          'senha': _senhaController.text,
          'cpf': _cpfController.text,
          'telefone': _telefoneController.text,
          'tipo_usuario': _tipoUsuario!,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        widget.onCadastroConcluido();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } else {
      if (_tipoUsuario == null) {
        setState(() {});
      }
    }
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      child: Text(
                        'CADASTRO',
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.64,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          buildTextField(_nomeController, 'Nome'),
                          const SizedBox(height: 16),
                          buildTextField(_cpfController, 'CPF'),
                          const SizedBox(height: 16),
                          buildTextField(_telefoneController, 'Telefone'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (!value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (value.length < 8) {
                                return 'Mínimo 8 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmarSenhaController,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: 'Confirmar senha',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12))),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tipo de usuário:',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_tipoUsuarioInvalido)
                            const Text(
                              'Selecione o tipo de usuário',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Radio<String>(
                                value: 'cliente',
                                groupValue: _tipoUsuario,
                                activeColor: const Color(0xFF007AFF),
                                onChanged: (value) {
                                  setState(() {
                                    _tipoUsuario = value!;
                                  });
                                },
                              ),
                              Text('Cliente', style: GoogleFonts.roboto()),
                              const SizedBox(width: 20),
                              Radio<String>(
                                value: 'admin',
                                groupValue: _tipoUsuario,
                                activeColor: const Color(0xFF007AFF),
                                onChanged: (value) {
                                  setState(() {
                                    _tipoUsuario = value!;
                                  });
                                },
                              ),
                              Text('Admin', style: GoogleFonts.roboto()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _cadastrar(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cadastrar'),
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
      ),
    );
  }
}
