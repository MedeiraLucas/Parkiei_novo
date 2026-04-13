import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Cor de fundo escurecida (puxada do Figma)
      backgroundColor: const Color(0xFF333333), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Logo Parkiei
                // Coloque a imagem sem fundo na sua pasta assets e ajuste o caminho abaixo
                Image.asset(
                  'assets/logo.png', 
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder caso a imagem ainda não esteja configurada
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
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A), // Fundo mais escuro
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none, // Remove a linha
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 4. Input de Senha
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    // Ícone do olhinho
                    suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 5. Botão de Entrar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cor vermelha do botão
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.black, // Texto preto igual ao design
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
                
                // 8. Botão do Google
                Center(
                  child: InkWell(
                    onTap: () {
                      // Lógica de login com Google aqui
                    },
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
                        // Usando network image para o G do Google para você testar na hora. 
                        // Depois você pode trocar por um Image.asset local se preferir.
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