import 'package:flutter/material.dart';
// Importe a tela de admin que vamos criar logo abaixo.
// Ajuste o caminho se necessário:
import '../admin/admin_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar o que o usuário digita
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _fazerLogin() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // VALIDAÇÃO ESTÁTICA PARA O ADMIN
    if (email == 'admin' && password == 'admin') {
      // Se for admin, navega para o painel de administração
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminScreen()),
      );
    } else {
      // Se não for admin, segue o fluxo normal para o mapa
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    // Limpa os controladores quando a tela for destruída
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo.png', 
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'PARKIEI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                
                // 3. Input de E-mail
                TextField(
                  controller: _emailController, // Conectado ao controlador
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none, 
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 4. Input de Senha
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 5. Botão de Entrar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, 
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: _fazerLogin,
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 6. Texto de cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Clique aqui',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7. Divisor "ou entre com"
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ou entre com',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                Center(
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                          height: 24,
                        ),
                      ),
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