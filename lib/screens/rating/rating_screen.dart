import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  final String parkingName;

  const RatingScreen({super.key, required this.parkingName});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final Color backgroundColor = const Color(0xFF2C2C2C);
  final Color appBarColor = const Color(0xFF1A1A1A);
  final Color cardColor = const Color(0xFF555555);
  final Color textColor = Colors.white;

  int _notaSelecionada = 0;
  final TextEditingController _comentarioController = TextEditingController();

  final String enderecoFicticio = "Rua do Príncipe, 450 - Centro";
  final String precoFicticio = "R\$ 12,00 / hora";
  final String horarioFicticio = "07:00 às 23:00";

  // ALTERADO: Status agora são apenas 'livre' ou 'ocupada'
  final List<Map<String, String>> vagasFicticias = [
    {'vaga': 'A1', 'status': 'livre'},
    {'vaga': 'A2', 'status': 'ocupada'},
    {'vaga': 'A3', 'status': 'ocupada'}, // Era reservada, virou ocupada
    {'vaga': 'A4', 'status': 'livre'},
    {'vaga': 'B1', 'status': 'ocupada'},
    {'vaga': 'B2', 'status': 'ocupada'},
    {'vaga': 'B3', 'status': 'livre'},
    {'vaga': 'B4', 'status': 'ocupada'}, // Era reservada, virou ocupada
  ];

  void _mostrarDialogAvaliacao() {
    setState(() {
      _notaSelecionada = 0;
      _comentarioController.clear();
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF3B3B3B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Avaliar Estacionamento',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Que nota você dá para este local?', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _notaSelecionada ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            _notaSelecionada = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _comentarioController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Deixe um comentário...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avaliação enviada com sucesso!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2B3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF2B3D), size: 24), // Vermelho igual ao logo
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ALTERADO: Lógica de cores simplificada (Apenas verde ou vermelho)
  Color _getCorVaga(String status) {
    if (status == 'livre') {
      return const Color(0xFF4CAF50); // Verde vibrante do seu design
    } else {
      return const Color(0xFFD32F2F); // Vermelho vibrante do seu design
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Image.asset('assets/logo.png', height: 32),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(icon: Icon(Icons.person_outline, color: textColor), onPressed: () {}),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.parkingName,
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  Icon(Icons.star_half, color: Colors.amber, size: 28),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/600x300/555555/FFFFFF?text=Foto+da+Fachada'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // INFORMAÇÕES GERAIS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B3B3B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações Gerais',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildInfoRow(Icons.location_on, enderecoFicticio),
                    _buildInfoRow(Icons.attach_money, precoFicticio),
                    _buildInfoRow(Icons.access_time, horarioFicticio),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DISPONIBILIDADE DE VAGAS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B3B3B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponibilidade de Vagas',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // ALTERADO: Legenda agora contém apenas 'Livre' e 'Ocupada'
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildLegendaVaga(const Color(0xFF4CAF50), 'Livre'),
                        const SizedBox(width: 32),
                        _buildLegendaVaga(const Color(0xFFD32F2F), 'Ocupada'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: vagasFicticias.length,
                      itemBuilder: (context, index) {
                        final vaga = vagasFicticias[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: _getCorVaga(vaga['status']!),
                            borderRadius: BorderRadius.circular(12), // Deixei levemente mais arredondado igual ao print
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            vaga['vaga']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _mostrarDialogAvaliacao,
                  icon: const Icon(Icons.rate_review),
                  label: const Text(
                    'Avaliar Estacionamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Recomendações',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade800, height: 1),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: Colors.grey, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usuário Teste ${index + 1}',
                                  style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Ótimo atendimento, local seguro!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendaVaga(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}