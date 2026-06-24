import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Agora usamos uma LISTA para permitir múltiplos estacionamentos!
  final List<Map<String, String>> _estacionamentos = [
    {
      'nome': 'Parkiei Central - Lucas',
      'endereco': 'Rua do Príncipe, 150 - Centro',
      'vagas': '30 Vagas',
      'valorHora': 'R\$ 12,00',
    }
  ];

  // ==========================================
  // FORMULÁRIO: ADICIONAR NOVO
  // ==========================================
  void _mostrarDialogAdicionar() {
    final nomeController = TextEditingController();
    final enderecoController = TextEditingController();
    final vagasController = TextEditingController();
    final valorHoraController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B3B3B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Novo Estacionamento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nomeController, 'Nome do Estacionamento'),
                const SizedBox(height: 12),
                _buildTextField(enderecoController, 'Endereço'),
                const SizedBox(height: 12),
                _buildTextField(vagasController, 'Quantidade de Vagas'),
                const SizedBox(height: 12),
                _buildTextField(valorHoraController, 'Valor por Hora'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                // Adiciona o novo item na lista
                setState(() {
                  _estacionamentos.add({
                    'nome': nomeController.text.isNotEmpty ? nomeController.text : 'Sem Nome',
                    'endereco': enderecoController.text.isNotEmpty ? enderecoController.text : 'Sem Endereço',
                    'vagas': vagasController.text.isNotEmpty ? vagasController.text : 'N/A',
                    'valorHora': valorHoraController.text.isNotEmpty ? valorHoraController.text : 'R\$ 0,00',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estacionamento adicionado com sucesso!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2B3D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // FORMULÁRIO: EDITAR EXISTENTE
  // ==========================================
  void _mostrarDialogEditar(int index) {
    // Carrega os dados atuais do estacionamento selecionado
    final est = _estacionamentos[index];
    final nomeController = TextEditingController(text: est['nome']);
    final enderecoController = TextEditingController(text: est['endereco']);
    final vagasController = TextEditingController(text: est['vagas']);
    final valorHoraController = TextEditingController(text: est['valorHora']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B3B3B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Editar Estacionamento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nomeController, 'Nome do Estacionamento'),
                const SizedBox(height: 12),
                _buildTextField(enderecoController, 'Endereço'),
                const SizedBox(height: 12),
                _buildTextField(vagasController, 'Quantidade de Vagas'),
                const SizedBox(height: 12),
                _buildTextField(valorHoraController, 'Valor por Hora'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                // Atualiza os dados na lista
                setState(() {
                  _estacionamentos[index] = {
                    'nome': nomeController.text,
                    'endereco': enderecoController.text,
                    'vagas': vagasController.text,
                    'valorHora': valorHoraController.text,
                  };
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estacionamento atualizado!'), backgroundColor: Colors.blue),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2B3D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // CONFIRMAÇÃO: EXCLUIR
  // ==========================================
  void _mostrarDialogExcluir(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3B3B3B),
          title: const Text('Excluir Estacionamento', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Tem certeza que deseja remover este estacionamento? Esta ação não pode ser desfeita.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                // Remove o item da lista
                setState(() {
                  _estacionamentos.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estacionamento removido!'), backgroundColor: Colors.red),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  // Input padronizado
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 32,
        ),
        centerTitle: true,
        actions: [
          const Center(
            child: Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Bem-vindo,',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                        Text(
                          'Lucas Medeira',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botão chama a função de Adicionar Novo
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _mostrarDialogAdicionar,
                  icon: const Icon(Icons.add_business),
                  label: const Text(
                    'Adicionar Novo Estacionamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2B3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'Meus Estacionamentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Se a lista estiver vazia, avisa. Se não, desenha os cards.
              _estacionamentos.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Nenhum estacionamento cadastrado.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true, // Importante para usar ListView dentro de ScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _estacionamentos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildEstacionamentoCard(index, _estacionamentos[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Recebe o index e os dados do estacionamento
  Widget _buildEstacionamentoCard(int index, Map<String, String> est) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B3B3B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      est['nome']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      est['endereco']!,
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                    onPressed: () => _mostrarDialogEditar(index),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: () => _mostrarDialogExcluir(index),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 24),

          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.garage, color: Colors.greenAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '100% Coberto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car, color: Colors.blueAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    est['vagas']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.access_time, color: Colors.orangeAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '06:00 às 23:00',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabela de Preços',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPrecoRow('Valor por Hora', est['valorHora']!),
                _buildPrecoRow('Pacote Semanal', 'R\$ 150,00'),
                _buildPrecoRow('Pacote Mensal', 'R\$ 450,00'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}