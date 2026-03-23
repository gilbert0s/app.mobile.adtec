import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

//////////////////// MODEL ////////////////////

class Imovel {
  final List<String> imagens;
  final String endereco;
  final String preco;
  final String tipo;
  bool ocupado;

  Imovel({
    required this.imagens,
    required this.endereco,
    required this.preco,
    required this.tipo,
    this.ocupado = false,
  });
}

//////////////////// APP ////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FadeTransition(
          opacity: controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.house, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'ADTEC',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// HOME ////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  bool mostrarBotao = false;
  String filtroSelecionado = 'Todos';

  final List<Imovel> todosImoveis = [
    Imovel(
      imagens: [],
      endereco: 'Rua Bela Vista, 120',
      preco: 'R\$ 350.000',
      tipo: 'Venda',
    ),
    Imovel(
      imagens: [],
      endereco: 'Av. Central, 455',
      preco: 'R\$ 1.200/mês',
      tipo: 'Aluguel',
    ),
  ];

  List<Imovel> imoveis = [];

  @override
  void initState() {
    super.initState();
    imoveis = todosImoveis;

    _scrollController.addListener(() {
      setState(() {
        mostrarBotao = _scrollController.offset > 300;
      });
    });
  }

  void filtrar(String tipo) {
    setState(() {
      filtroSelecionado = tipo;

      if (tipo == 'Todos') {
        imoveis = todosImoveis;
      } else {
        imoveis =
            todosImoveis.where((i) => i.tipo == tipo).toList();
      }
    });
  }

  void adicionarImovel(Imovel novo) {
    setState(() {
      todosImoveis.add(novo);
      filtrar(filtroSelecionado);
    });
  }

  //////////////////// CARROSSEL ////////////////////

  Widget _carrossel(List<String> imagens) {
    if (imagens.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 50),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: PageView(
        children: imagens.map((path) {
          return kIsWeb
              ? Image.network(path,
                  width: double.infinity,
                  fit: BoxFit.cover)
              : Image.file(File(path),
                  width: double.infinity,
                  fit: BoxFit.cover);
        }).toList(),
      ),
    );
  }

  //////////////////// CARD ////////////////////

  Widget _cardImovel(Imovel imovel) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _carrossel(imovel.imagens),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: imovel.tipo == 'Venda'
                            ? Colors.green
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        imovel.tipo.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(imovel.endereco,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(imovel.preco,
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            imovel.ocupado
                                ? Icons.cancel
                                : Icons.check_circle,
                            color: imovel.ocupado
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(imovel.ocupado
                              ? 'Ocupado'
                              : 'Disponível'),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          bool? confirmar = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: Text(
                                imovel.tipo == 'Venda'
                                    ? 'Tem certeza? Essa ação é irreversível.'
                                    : imovel.ocupado
                                        ? 'Marcar como disponível?'
                                        : 'Marcar como ocupado?',
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar')),
                                ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Confirmar')),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            setState(() {
                              if (imovel.tipo == 'Venda') {
                                todosImoveis.remove(imovel);
                              } else {
                                imovel.ocupado =
                                    !imovel.ocupado;
                              }
                              filtrar(filtroSelecionado);
                            });
                          }
                        },
                        child: Text(
                          imovel.tipo == 'Venda'
                              ? 'Vendido'
                              : imovel.ocupado
                                  ? 'Disponível'
                                  : 'Ocupado',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //////////////////// NAV ////////////////////

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroPage(onSalvar: adicionarImovel),
      ),
    );
  }

  //////////////////// UI ////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'ADTEC',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _botaoFiltro('Todos'),
                    _botaoFiltro('Venda'),
                    _botaoFiltro('Aluguel'),
                  ],
                ),
              ],
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: imoveis.length,
              itemBuilder: (_, i) => _cardImovel(imoveis[i]),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (mostrarBotao)
            FloatingActionButton(
              heroTag: 'top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: abrirCadastro,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _botaoFiltro(String texto) {
    bool ativo = filtroSelecionado == texto;

    return ElevatedButton(
      onPressed: () => filtrar(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: ativo ? Colors.blue : Colors.white,
        foregroundColor: ativo ? Colors.white : Colors.blue,
      ),
      child: Text(texto),
    );
  }
}

//////////////////// CADASTRO ////////////////////

class CadastroPage extends StatefulWidget {
  final Function(Imovel) onSalvar;

  const CadastroPage({super.key, required this.onSalvar});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final picker = ImagePicker();

  List<XFile> imagens = [];
  final enderecoController = TextEditingController();
  final precoController = TextEditingController();

  String tipo = 'Venda';

 Future<void> escolherImagens() async {
  try {
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagem != null) {
      setState(() {
        imagens.add(imagem);
      });
    }
  } catch (e) {
    print("Erro: $e");
  }
}

  Widget previewImagens() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...imagens.map((img) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: kIsWeb
                  ? Image.network(img.path,
                      width: 160, fit: BoxFit.cover)
                  : Image.file(File(img.path),
                      width: 160, fit: BoxFit.cover),
            );
          }),

          GestureDetector(
            onTap: escolherImagens,
            child: Container(
              width: 120,
              color: Colors.grey[300],
              child: const Icon(Icons.add_a_photo, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  void salvar() {
    if (enderecoController.text.isEmpty ||
        precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha tudo')),
      );
      return;
    }

    final novo = Imovel(
      imagens: imagens.map((e) => e.path).toList(),
      endereco: enderecoController.text,
      preco: precoController.text,
      tipo: tipo,
    );

    widget.onSalvar(novo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Imóvel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            previewImagens(),
            const SizedBox(height: 12),
            TextField(
              controller: enderecoController,
              decoration:
                  const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: precoController,
              decoration:
                  const InputDecoration(labelText: 'Preço'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: tipo,
              isExpanded: true,
              items: ['Venda', 'Aluguel']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  tipo = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvar,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}