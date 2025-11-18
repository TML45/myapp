import 'package:flutter/material.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                title: 'Self Record Health Tracker',
                content:
                    'Versão: 1.0.0\n\nEste aplicativo foi desenvolvido para ajudar os usuários a acompanhar seu histórico de saúde, armazenando informações importantes de forma prática e acessível.',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Desenvolvido por',
                content:
                    'Tiago Segato\nTássio Melo Linhares\nGabriel Victor Vieira\nJafah Barboza\nSérgio',
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Contato',
                content:
                    'Email: suporte@selfrecord.com\nTelefone: (61) 99999-9999',
                icon: Icons.contact_mail_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
