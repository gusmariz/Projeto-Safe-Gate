import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<HistoryItem> itens = [
    HistoryItem("Joãozinho abriu", "13:42", "Terça-feira", "03/05/2025"),
    HistoryItem("Joãozinho fechou", "13:43", "Terça-feira", "03/05/2025"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itens.length,
      itemBuilder: (context, index) {
        return HistoryTile(item: itens[index]);
      },
    );
  }
}

class HistoryItem {
  final String titulo;
  final String hora;
  final String dia;
  final String data;

  HistoryItem(this.titulo, this.hora, this.dia, this.data);
}

class HistoryTile extends StatelessWidget {
  final HistoryItem item;

  const HistoryTile({Key? key, required this.item}) : super(key: key);

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
      ),
    );
  }
}