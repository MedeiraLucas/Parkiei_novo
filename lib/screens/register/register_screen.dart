
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),

      body: Center(
        child: ElevatedButton(
          onPressed: () {

            Navigator.pushReplacementNamed(
              context,
              '/',
            );

          },
          child: const Text('Cadastrar-se'),
        ),
      ),
    );
  }
}
