import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/gestures.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      home: const SplashPage(),
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
  String filtroSelecionado = 'Todos';

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

  void mostrarJanelaEdicao(BuildContext context, String docId, String enderecoAtual, String precoAtual) {
    final enderecoEditController = TextEditingController(text: enderecoAtual);
    final precoEditController = TextEditingController(text: precoAtual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Dados do Imóvel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enderecoEditController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: precoEditController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CentavosInputFormatter(moeda: true),
                ],
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Alteração'),
                    content: const Text('Deseja salvar as novas informações deste imóvel?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('imoveis')
                              .doc(docId)
                              .update({
                            'endereco': enderecoEditController.text,
                            'preco': precoEditController.text,
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Imóvel atualizado com sucesso!'))
                            );
                          }
                        },
                        child: const Text('Sim, Confirmar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        );
      },
    );
  }

  Widget _carrossel(List<dynamic> imagens) {
    if (imagens.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
      );
    }
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.photo_library, size: 50, color: Colors.blue)),
    );
  }

  Widget _cardImovel(DocumentSnapshot documento) {
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
                      Row(
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('EDITAR'),
                            onPressed: () {
                              mostrarJanelaEdicao(
                                context, 
                                documento.id, 
                                endereco, 
                                preco
                              );
                            },
                          ),
                          const SizedBox(width: 8),
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
                                  await documento.reference.delete();
                                } else {
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
                Image.asset('assets/icon.png', height: 85), 
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
                  itemCount: documentos.length,
                  itemBuilder: (_, i) => _cardImovel(documentos[i]),
                );
              },
            ),
          ),
        ],
      ),
      // O botão principal ficou sozinho e feliz aqui:
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
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
      final List<XFile> selecionadas = await picker.pickMultiImage();
      if (selecionadas.isNotEmpty) {
        setState(() {
          imagens.addAll(selecionadas);
        });
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  void removerImagem(int index) {
    setState(() {
      imagens.removeAt(index);
    });
  }

  Widget previewImagens() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: escolherImagens,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Adicionar Fotos (Selecione várias)'),
        ),
        const SizedBox(height: 10),
        if (imagens.isNotEmpty)
          const Text('Dica: Segure e arraste uma foto para mudar a ordem', 
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        
        SizedBox(
          height: 140,
          child: ReorderableListView(
            scrollDirection: Axis.horizontal,
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final XFile item = imagens.removeAt(oldIndex);
                imagens.insert(newIndex, item);
              });
            },
            children: [
              for (int index = 0; index < imagens.length; index++)
                Container(
                  key: ValueKey(imagens[index].path + index.toString()),
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(imagens[index].path, width: 140, height: 140, fit: BoxFit.cover)
                            : Image.file(File(imagens[index].path), width: 140, height: 140, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => removerImagem(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> salvar() async {
    if (enderecoController.text.isEmpty || precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha os dados da casa')));
      return;
    }

    setState(() => enviando = true);

    try {
      await FirebaseFirestore.instance.collection('imoveis').add({
        'endereco': enderecoController.text,
        'preco': precoController.text,
        'tipo': tipo,
        'ocupado': false,
        'imagens': [], 
        'data_cadastro': DateTime.now(),
      });

      if (mounted) Navigator.pop(context);
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
            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CentavosInputFormatter(moeda: true),
              ],
              decoration: const InputDecoration(labelText: 'Preço'),
            ),
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