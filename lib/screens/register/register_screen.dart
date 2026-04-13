import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botão de Voltar
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logo Parkiei
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'PARKIEI',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),

              // Campos de Texto
              _buildCustomTextField('Digite seu Nome Completo', TextInputType.name),
              const SizedBox(height: 16),
              
              _buildCustomTextField('Digite seu Melhor E-mail', TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              _buildCustomTextField('Digite seu Telefone', TextInputType.phone),
              const SizedBox(height: 16),
              
              _buildCustomTextField('Digite seu CPF', TextInputType.number),
              const SizedBox(height: 16),

              // Campos de Senha
              _buildCustomTextField('Digite sua Senha', TextInputType.text, isPassword: true),
              const SizedBox(height: 16),

              _buildCustomTextField('Confirme sua Senha', TextInputType.text, isPassword: true),
              const SizedBox(height: 48),

              // Botão Cadastre-se
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onPressed: () {
                  // 1. Mostra a mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Conta criada com sucesso! Faça seu login.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // 2. Volta para a tela de Login
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Texto de rodapé para Voltar ao Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem uma conta? ',
                    style: TextStyle(color: Colors.white54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Entre aqui',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função auxiliar para criar os TextFields com o design padrão
  Widget _buildCustomTextField(String hint, TextInputType keyboardType, {bool isPassword = false}) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        suffixIcon: isPassword 
            ? const Icon(Icons.visibility_off_outlined, color: Colors.white38) 
            : null,
      ),
    );
  }
}