import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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
      backgroundColor: Colors.blue[900],
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
                style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// HOME (SISTEMA INTERNO) ////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool mostrarBotao = false;
  String filtroSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        mostrarBotao = _scrollController.offset > 300;
      });
    });
  }

  void filtrar(String tipo) {
    setState(() {
      filtroSelecionado = tipo;
    });
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
  }

  //////////////////// CARROSSEL ////////////////////

  Widget _carrossel(List<dynamic> imagens) {
    if (imagens.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
      );
    }
    // TODO: Na Fase das fotos, vamos arrumar para puxar da internet
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.photo_library, size: 50, color: Colors.blue)),
    );
  }

  //////////////////// CARD COM AÇÕES DO FIREBASE ////////////////////

  Widget _cardImovel(DocumentSnapshot documento) {
    // Pegando os dados e o ID do documento no Firebase
    Map<String, dynamic> imovel = documento.data() as Map<String, dynamic>;
    String endereco = imovel['endereco'] ?? 'Sem endereço';
    String preco = imovel['preco'] ?? 'R\$ 0,00';
    String tipo = imovel['tipo'] ?? 'Venda';
    bool ocupado = imovel['ocupado'] ?? false;
    List<dynamic> imagens = imovel['imagens'] ?? [];

    return Container(
      margin: const EdgeInsets.all(12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  _carrossel(imagens),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tipo == 'Venda' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tipo.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
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
                  Text(endereco, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(preco, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            ocupado ? Icons.cancel : Icons.check_circle,
                            color: ocupado ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(ocupado ? 'Ocupado' : 'Disponível'),
                        ],
                      ),
                      // Botão para a atendente atualizar o banco de dados
                      ElevatedButton(
                        onPressed: () async {
                          bool? confirmar = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Atualizar Sistema'),
                              content: Text(
                                tipo == 'Venda'
                                    ? 'Marcar este imóvel como VENDIDO e remover da lista?'
                                    : ocupado
                                        ? 'O inquilino saiu? Marcar como DISPONÍVEL?'
                                        : 'Alugado? Marcar como OCUPADO?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            if (tipo == 'Venda') {
                              // Se vendeu, apaga do Firebase
                              await documento.reference.delete();
                            } else {
                              // Se alugou, inverte o status de ocupado
                              await documento.reference.update({'ocupado': !ocupado});
                            }
                          }
                        },
                        child: Text(
                          tipo == 'Venda' ? 'Vendido' : ocupado ? 'Liberar' : 'Alugar',
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

  //////////////////// UI ////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const Text('ADTEC', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _botaoFiltro('Todos'),
                    _botaoFiltro('Venda'),
                    _botaoFiltro('Aluguel'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('imoveis').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum imóvel cadastrado.'));
                }
                var documentos = snapshot.data!.docs;
                if (filtroSelecionado != 'Todos') {
                  documentos = documentos.where((doc) {
                    return (doc.data() as Map<String, dynamic>)['tipo'] == filtroSelecionado;
                  }).toList();
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: documentos.length,
                  itemBuilder: (_, i) => _cardImovel(documentos[i]),
                );
              },
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
              onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
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
        backgroundColor: ativo ? Colors.red : Colors.white,
        foregroundColor: ativo ? Colors.white : Colors.black,
      ),
      child: Text(texto),
    );
  }
}

//////////////////// CADASTRO (SALVANDO NO FIREBASE) ////////////////////

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final picker = ImagePicker();
  List<XFile> imagens = [];
  final enderecoController = TextEditingController();
  final precoController = TextEditingController();
  String tipo = 'Venda';
  bool enviando = false;

  Future<void> escolherImagens() async {
    try {
      final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
      if (imagem != null) {
        setState(() => imagens.add(imagem));
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
                  ? Image.network(img.path, width: 160, fit: BoxFit.cover)
                  : Image.file(File(img.path), width: 160, fit: BoxFit.cover),
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

  Future<void> salvar() async {
    if (enderecoController.text.isEmpty || precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha os dados da casa')));
      return;
    }

    setState(() => enviando = true);

    try {
      // Enviando os textos para o banco de dados!
      await FirebaseFirestore.instance.collection('imoveis').add({
        'endereco': enderecoController.text,
        'preco': precoController.text,
        'tipo': tipo,
        'ocupado': false,
        'imagens': [], // Placeholder para as fotos na Fase 3
        'data_cadastro': DateTime.now(),
      });

      if (mounted) Navigator.pop(context); // Fecha a tela após salvar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      setState(() => enviando = false);
    }
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
            TextField(controller: enderecoController, decoration: const InputDecoration(labelText: 'Endereço')),
            TextField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço')),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: tipo,
              isExpanded: true,
              items: ['Venda', 'Aluguel'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => tipo = value!),
            ),
            const SizedBox(height: 20),
            enviando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: salvar,
                    child: const Text('Salvar no Sistema'),
                  ),
          ],
        ),
      ),
    );
  }
}