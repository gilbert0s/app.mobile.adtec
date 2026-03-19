import 'package:flutter/material.dart';

void main() {

runApp(const MyApp());

}

class Imovel {

final String imagem;

final String endereco;

final String preco;

final String tipo;

const Imovel({

required this.imagem,

required this.endereco,

required this.preco,

required this.tipo,

});

}

class MyApp extends StatelessWidget {

const MyApp({super.key});

@override

Widget build(BuildContext context) {

return MaterialApp(

debugShowCheckedModeBanner: false,

home: HomePage(),

);

}

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});


@override

State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

final ScrollController _scrollController = ScrollController();

bool mostrarBotao = false;

String filtroSelecionado = 'Todos';

final List<Imovel> todosImoveis = const [

Imovel(

imagem: 'https://picsum.photos/400/200',

endereco: 'Rua Exemplo, 123 - Centro',

preco: 'R\$ 320.000',

tipo: 'Venda',

),

Imovel(

imagem: 'https://picsum.photos/400/201',

endereco: 'Av. Principal, 456 - Jardim',

preco: 'R\$ 1.200/mês',

tipo: 'Aluguel',

),

Imovel(

imagem: 'https://picsum.photos/400/202',

endereco: 'Rua das Palmeiras, 789',

preco: 'R\$ 450.000',

tipo: 'Venda',

),

Imovel(

imagem: 'https://picsum.photos/400/203',

endereco: 'Rua Nova, 321 - Residencial',

preco: 'R\$ 900/mês',

tipo: 'Aluguel',

),

Imovel(

imagem: 'https://picsum.photos/400/204',

endereco: 'Rua Azul, 111',

preco: 'R\$ 600.000',

tipo: 'Venda',

),

Imovel(

imagem: 'https://picsum.photos/400/205',

endereco: 'Av. Verde, 222',

preco: 'R\$ 1.800/mês',

tipo: 'Aluguel',

),

];

List<Imovel> imoveis = [];

@override

void initState() {

super.initState();

imoveis = todosImoveis;

_scrollController.addListener(() {

if (_scrollController.offset > 300) {

setState(() => mostrarBotao = true);

} else {

setState(() => mostrarBotao = false);

}

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

Widget _botaoFiltro(String texto) {

bool ativo = filtroSelecionado == texto;

return ElevatedButton(

onPressed: () => filtrar(texto),

style: ElevatedButton.styleFrom(

backgroundColor: ativo ? Colors.blue : Colors.white,

foregroundColor: ativo ? Colors.white : Colors.blue,

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(20),

),

),

child: Text(texto),

);

}

Widget _cardImovel(Imovel imovel) {

return Container(

margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

decoration: BoxDecoration(

borderRadius: BorderRadius.circular(16),

boxShadow: [

BoxShadow(

color: Colors.black12,

blurRadius: 6,

offset: Offset(0, 3),

),

],

),

child: ClipRRect(

borderRadius: BorderRadius.circular(16),

child: Container(

color: Colors.white,

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

Stack(

children: [

Image.network(

imovel.imagem,

width: double.infinity,

height: 180,

fit: BoxFit.cover,

errorBuilder: (context, error, stackTrace) {

return Container(

height: 180,

color: Colors.grey[300],

child: const Icon(Icons.image, size: 50),

);

},

),

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

imovel.tipo,

style: const TextStyle(

color: Colors.white,

fontSize: 12,

fontWeight: FontWeight.bold,

),

),

),

),

],

),

Padding(

padding: const EdgeInsets.all(12),

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

Text(

imovel.endereco,

style: const TextStyle(

fontSize: 16,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 6),

Text(

imovel.preco,

style: const TextStyle(

fontSize: 15,

color: Colors.green,

fontWeight: FontWeight.w600,

),

),

const SizedBox(height: 10),

SizedBox(

width: double.infinity,

child: ElevatedButton(

onPressed: () {},

style: ElevatedButton.styleFrom(

backgroundColor: Colors.blue,

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(10),

),

),

child: const Text('Tenho interesse'),

),

),

],

),

),

],

),

),

),

);

}

Widget _rodape() {

return Container(

padding: const EdgeInsets.all(20),

color: Colors.grey[200],

child: Column(

children: [

const Text(

'Contato',

style: TextStyle(

fontSize: 16,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 10),

const Text('Telefone: (11) 99999-9999'),

const Text('Email: contato@adtec.com'),

const SizedBox(height: 15),

// BOTÃO WHATSAPP

ElevatedButton.icon(

onPressed: () {},

icon: const Icon(Icons.chat),

label: const Text('Falar no WhatsApp'),

style: ElevatedButton.styleFrom(

backgroundColor: Colors.green,

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(10),

),

),

),

],

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

padding: const EdgeInsets.all(16),

decoration: const BoxDecoration(

color: Colors.blue,

borderRadius: BorderRadius.only(

bottomLeft: Radius.circular(20),

bottomRight: Radius.circular(20),

),

),

child: Column(

children: [

const Text(

'ADTEC',

style: TextStyle(

color: Colors.red,

fontSize: 24,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 12),

Row(

mainAxisAlignment: MainAxisAlignment.spaceEvenly,

children: [

_botaoFiltro('Todos'),

_botaoFiltro('Venda'),

_botaoFiltro('Aluguel'),

],

)

],

),

),

Expanded(

child: ListView.builder(

controller: _scrollController,

itemCount: imoveis.length + 1,

itemBuilder: (context, index) {

if (index == imoveis.length) {

return _rodape();

}

return _cardImovel(imoveis[index]);

},

),

),

],

),

floatingActionButton: mostrarBotao

? FloatingActionButton(

onPressed: () {

_scrollController.animateTo(

0,

duration: const Duration(milliseconds: 500),

curve: Curves.easeInOut,

);

},

child: const Icon(Icons.arrow_upward),

)

: null,

);

}

}