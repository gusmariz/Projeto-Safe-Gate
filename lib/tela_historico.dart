import 'package:flutter/material.dart';

class TelaHistorico extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de ações'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListaHistorico(),
    );
  }
}

class ListaHistorico extends StatelessWidget {
  final List<ItemHistorico> itens = [
    ItemHistorico("Joãozinho abriu", "13:42", "Terça-feira", "03/05/2025"),
    ItemHistorico("Joãozinho fechou", "13:43", "Terça-feira", "03/05/2025"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itens.length,
      itemBuilder: (context, index) {
        return ElementoHistorico(item: itens[index]);
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
  final ItemHistorico item;

  const ElementoHistorico({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[500],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
          ),
        ),
        title: Text(
          item.titulo,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text('${item.dia}, ${item.data}'),
            SizedBox(height: 3),
            Text(
              item.hora,
              style: TextStyle(color: Colors.grey[600]),
            )
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}