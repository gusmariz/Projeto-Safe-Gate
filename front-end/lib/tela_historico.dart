import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello/main.dart';
import 'package:provider/provider.dart';

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: primaryColor,
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text(
                  'HISTÓRICO',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.64,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: ListaHistorico(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaHistorico extends StatefulWidget {
  const ListaHistorico({super.key});

  @override
  State<ListaHistorico> createState() => _ListaHistoricoState();
}

class _ListaHistoricoState extends State<ListaHistorico> {
  late Future<List<ItemHistorico>> _futureHistorico;

  @override
  void initState() {
    super.initState();
    _futureHistorico =
        Provider.of<HistoricoManager>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemHistorico>>(
      future: _futureHistorico,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum histórico encontrado'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ElementoHistorico(item: snapshot.data![index]);
          },
        );
      },
    );
  }
}

class ItemHistorico {
  final int id;
  final String titulo;
  final String hora;
  final String dia;
  final String data;

  ItemHistorico(this.id, this.titulo, this.hora, this.dia, this.data);
}

class ElementoHistorico extends StatefulWidget {
  const ElementoHistorico({super.key, required this.item});

  final ItemHistorico item;

  @override
  State<ElementoHistorico> createState() => _ElementoHistoricoState();
}

class _ElementoHistoricoState extends State<ElementoHistorico> {
  bool _mostrarBotaoExcluir = false;

  @override
  Widget build(BuildContext context) {
    final historico = Provider.of<HistoricoManager>(context, listen: false);

    return GestureDetector(
      onTap: () {
        setState(() {
          _mostrarBotaoExcluir = !_mostrarBotaoExcluir;
        });
      },
      child: Card(
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
            '${widget.item.id} - ${widget.item.titulo}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text('${widget.item.dia}, ${widget.item.data}'),
              const SizedBox(height: 3),
              Text(
                widget.item.hora,
                style: TextStyle(color: Colors.grey[600]),
              )
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chevron_right),
              if (_mostrarBotaoExcluir)
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: const Text(
                                'Deseja realmente excluir este registro?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  historico.removerItem(widget.item);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Registro excluído com sucesso'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Excluir',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
