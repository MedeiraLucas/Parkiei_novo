
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'PARKEI',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                );
              },
              child: const Text('Entrar'),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/register',
                );
              },
              child: const Text(
                'Não tem uma conta? Clique aqui',
              ),
            ),

          ],
        ),
      ),
    );
  }
}
