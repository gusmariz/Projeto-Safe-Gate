import 'package:flutter/material.dart';
import 'package:hello/main.dart';
import 'package:provider/provider.dart';

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de ações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListaHistorico(),
    );
  }
}

class ListaHistorico extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final historico = Provider.of<HistoricoManager>(context);

    return ListView.builder(
      itemCount: historico.historico.length,
      itemBuilder: (context, index) {
        return ElementoHistorico(item: historico.historico[index]);
      },
    );
  }
}

class ItemHistorico {
  final String titulo;
  final String hora;
  final String dia;
  final String data;

  ItemHistorico(this.titulo, this.hora, this.dia, this.data);
}

class ElementoHistorico extends StatelessWidget {
  const ElementoHistorico({super.key, required this.item});
  
  final ItemHistorico item;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person, size: 36),
        ),
        title: Text(
          item.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text('${item.dia}, ${item.data}'),
            const SizedBox(height: 3),
            Text(
              item.hora,
              style: TextStyle(color: Colors.grey[600]),
            )
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}