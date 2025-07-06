import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Classe para gerenciar cores do app
class AppColors {
  // Tons principais
  static const Color azulPrincipal = Color(0xFF1E88E5);     // Azul vibrante
  static const Color laranjaPrincipal = Color(0xFFFF7043);  // Laranja suave
  // Tons secundários
  static const Color azulSecundario = Color(0xFF90CAF9);
  static const Color laranjaSecundaria = Color(0xFFFFAB91);
  // Fundo e texto
  static const Color fundo = Color(0xFFF5F5F5);
  static const Color textoEscuro = Color(0xFF212121);
  static const Color textoClaro = Color(0xFFFFFFFF);
  // Neutros
  static const Color cinza = Color(0xFFBDBDBD);
  static const Color borda = Color(0xFFE0E0E0);
}

// Modelo de dados para o procedimento
class Procedimento {
  final String id;
  final String nome;
  final String descricao;
  final List<String> passos;
  final String provedor;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Procedimento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.passos,
    required this.provedor,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'passos': passos,
      'provedor': provedor,
      'dataCriacao': dataCriacao,
      'dataAtualizacao': dataAtualizacao,
    };
  }

  // Criar objeto a partir de um documento do Firestore
  factory Procedimento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Procedimento(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      passos: List<String>.from(data['passos'] ?? []),
      provedor: data['provedor'] ?? '',
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      dataAtualizacao: (data['dataAtualizacao'] as Timestamp).toDate(),
    );
  }
}

// Serviço para gerenciar procedimentos no Firestore
class ProcedimentosService {
  final CollectionReference procedimentosCollection = 
      FirebaseFirestore.instance.collection('procedimentos');

  // Obter lista de procedimentos
  Stream<List<Procedimento>> getProcedimentos() {
    return procedimentosCollection
        .orderBy('dataAtualizacao', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Procedimento.fromFirestore(doc);
      }).toList();
    });
  }

  // Adicionar um novo procedimento
  Future<void> adicionarProcedimento(Procedimento procedimento) {
    return procedimentosCollection.add(procedimento.toMap());
  }

  // Atualizar um procedimento existente
  Future<void> atualizarProcedimento(Procedimento procedimento) {
    return procedimentosCollection.doc(procedimento.id).update(procedimento.toMap());
  }

  // Excluir um procedimento
  Future<void> excluirProcedimento(String id) {
    return procedimentosCollection.doc(id).delete();
  }
}

// Serviço para autenticação de administrador
class AdminAuthService {
  static const String adminPassword = "adminwial";
  static const String adminAuthKey = "admin_authenticated";
  
  // Verificar se a senha está correta
  bool verificarSenha(String senha) {
    return senha == adminPassword;
  }
  
  // Salvar estado de autenticação
  Future<void> salvarAutenticacao(bool autenticado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(adminAuthKey, autenticado);
  }
  
  // Verificar se está autenticado
  Future<bool> isAutenticado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(adminAuthKey) ?? false;
  }
  
  // Fazer logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(adminAuthKey, false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Procedimentos Técnicos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azulPrincipal,
          brightness: Brightness.light,
          primary: AppColors.azulPrincipal,
          secondary: AppColors.laranjaPrincipal,
          tertiary: AppColors.azulSecundario,
          background: AppColors.fundo,
          surface: AppColors.textoClaro,
          onPrimary: AppColors.textoClaro,
          onSecondary: AppColors.textoClaro,
          onBackground: AppColors.textoEscuro,
          onSurface: AppColors.textoEscuro,
        ),
        scaffoldBackgroundColor: AppColors.fundo,
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.textoClaro,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borda),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borda),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2, color: AppColors.azulPrincipal),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azulPrincipal,
          brightness: Brightness.dark,
          primary: AppColors.azulPrincipal,
          secondary: AppColors.laranjaPrincipal,
          tertiary: AppColors.azulSecundario,
          background: const Color(0xFF121212),
          surface: const Color(0xFF1E1E1E),
          onPrimary: AppColors.textoClaro,
          onSecondary: AppColors.textoClaro,
          onBackground: AppColors.textoClaro,
          onSurface: AppColors.textoClaro,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2, color: AppColors.azulPrincipal),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ListaProcedimentosPage(),
    );
  }
}

// Página de listagem de procedimentos
class ListaProcedimentosPage extends StatefulWidget {
  const ListaProcedimentosPage({super.key});

  @override
  State<ListaProcedimentosPage> createState() => _ListaProcedimentosPageState();
}

class _ListaProcedimentosPageState extends State<ListaProcedimentosPage> {
  final ProcedimentosService _procedimentosService = ProcedimentosService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  bool _isAdmin = false;
  String? _filtroProvedor;
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final isAdmin = await _adminAuthService.isAutenticado();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  void _mostrarDialogoLogin() {
    final senhaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso de Administrador'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Digite a senha de administrador para acessar as funcionalidades de edição.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite a senha';
                  }
                  if (!_adminAuthService.verificarSenha(value)) {
                    return 'Senha incorreta';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _adminAuthService.salvarAutenticacao(true);
                Navigator.pop(context);
                setState(() {
                  _isAdmin = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Acesso de administrador concedido!'),
                    backgroundColor: AppColors.azulPrincipal,
                  ),
                );
              }
            },
            child: const Text('ENTRAR'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _adminAuthService.logout();
    setState(() {
      _isAdmin = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você saiu do modo administrador'),
        backgroundColor: AppColors.cinza,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Procedimentos Técnicos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        actions: [
          // Botão de busca
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProcedimentosSearchDelegate(
                  _procedimentosService, 
                  _isAdmin,
                ),
              );
            },
          ),
          // Botão de admin
          IconButton(
            icon: Icon(_isAdmin ? Icons.admin_panel_settings : Icons.lock_outline),
            onPressed: _isAdmin ? _logout : _mostrarDialogoLogin,
            tooltip: _isAdmin ? 'Sair do modo admin' : 'Entrar como admin',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por provedor
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filtrar por Provedor',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _filtroProvedor,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos os Provedores'),
                ),
                ...['Bora Fibra', 'Bahia Fibra', 'JS Fibra'].map((provedor) {
                  return DropdownMenuItem(
                    value: provedor,
                    child: Text(provedor),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroProvedor = value;
                });
              },
            ),
          ),
          
          // Lista de procedimentos
          Expanded(
            child: StreamBuilder<List<Procedimento>>(
              stream: _procedimentosService.getProcedimentos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar procedimentos: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final procedimentos = snapshot.data ?? [];
                
                // Aplicar filtro por provedor se selecionado
                final procedimentosFiltrados = _filtroProvedor != null
                    ? procedimentos.where((p) => p.provedor == _filtroProvedor).toList()
                    : procedimentos;

                if (procedimentosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.engineering_outlined,
                          size: 80,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filtroProvedor != null
                              ? 'Nenhum procedimento para $_filtroProvedor'
                              : 'Nenhum procedimento cadastrado',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isAdmin)
                          Text(
                            'Clique no botão + para adicionar',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: procedimentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final procedimento = procedimentosFiltrados[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProcedimentoCard(
                        procedimento: procedimento,
                        isAdmin: _isAdmin,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhesProcedimentoPage(
                                procedimento: procedimento,
                                isAdmin: _isAdmin,
                                onEdit: _isAdmin
                                    ? (procedimento) => _procedimentosService.atualizarProcedimento(procedimento)
                                    : null,
                                onDelete: _isAdmin
                                    ? (id) => _procedimentosService.excluirProcedimento(id)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProcedimentoFormPage(
                      onSave: (procedimento) => _procedimentosService.adicionarProcedimento(procedimento),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.laranjaPrincipal,
              foregroundColor: AppColors.textoClaro,
              icon: const Icon(Icons.add),
              label: const Text('Novo Procedimento'),
            )
          : null,
    );
  }
}

// Delegate para busca de procedimentos
class ProcedimentosSearchDelegate extends SearchDelegate<String> {
  final ProcedimentosService _procedimentosService;
  final bool _isAdmin;

  ProcedimentosSearchDelegate(this._procedimentosService, this._isAdmin);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Digite para buscar procedimentos'),
      );
    }

    final lowercaseQuery = query.toLowerCase();

    return StreamBuilder<List<Procedimento>>(
      stream: _procedimentosService.getProcedimentos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        final procedimentos = snapshot.data ?? [];
        final resultados = procedimentos.where((procedimento) {
          return procedimento.nome.toLowerCase().contains(lowercaseQuery) ||
              procedimento.descricao.toLowerCase().contains(lowercaseQuery) ||
              procedimento.provedor.toLowerCase().contains(lowercaseQuery);
        }).toList();

        if (resultados.isEmpty) {
          return const Center(
            child: Text('Nenhum procedimento encontrado'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resultados.length,
          itemBuilder: (context, index) {
            final procedimento = resultados[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProcedimentoCard(
                procedimento: procedimento,
                isAdmin: _isAdmin,
                onTap: () {
                  close(context, procedimento.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesProcedimentoPage(
                        procedimento: procedimento,
                        isAdmin: _isAdmin,
                        onEdit: _isAdmin
                            ? (procedimento) => _procedimentosService.atualizarProcedimento(procedimento)
                            : null,
                        onDelete: _isAdmin
                            ? (id) => _procedimentosService.excluirProcedimento(id)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Widget de card para mostrar procedimento na lista
class ProcedimentoCard extends StatelessWidget {
  final Procedimento procedimento;
  final VoidCallback onTap;
  final bool isAdmin;

  const ProcedimentoCard({
    super.key,
    required this.procedimento,
    required this.onTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Definir cor baseada no provedor
    Color provedorColor;
    switch (procedimento.provedor) {
      case 'Bora Fibra':
        provedorColor = AppColors.azulPrincipal;
        break;
      case 'Bahia Fibra':
        provedorColor = AppColors.laranjaPrincipal;
        break;
      case 'JS Fibra':
        provedorColor = Colors.green;
        break;
      default:
        provedorColor = AppColors.cinza;
    }

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: provedorColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: provedorColor,
                    foregroundColor: AppColors.textoClaro,
                    child: const Icon(Icons.engineering),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          procedimento.nome,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: provedorColor,
                          ),
                        ),
                        Text(
                          procedimento.provedor,
                          style: textTheme.bodyMedium?.copyWith(
                            color: provedorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: provedorColor),
                ],
              ),
            ),
            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    procedimento.descricao,
                    style: textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${procedimento.passos.length} passos',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isAdmin)
                        Chip(
                          backgroundColor: AppColors.azulSecundario.withOpacity(0.2),
                          label: Text(
                            'Admin',
                            style: TextStyle(
                              color: AppColors.azulPrincipal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          avatar: Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.azulPrincipal,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de detalhes do procedimento
class DetalhesProcedimentoPage extends StatelessWidget {
  final Procedimento procedimento;
  final bool isAdmin;
  final Function(Procedimento)? onEdit;
  final Function(String)? onDelete;

  const DetalhesProcedimentoPage({
    super.key,
    required this.procedimento,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Definir cor baseada no provedor
    Color provedorColor;
    switch (procedimento.provedor) {
      case 'Bora Fibra':
        provedorColor = AppColors.azulPrincipal;
        break;
      case 'Bahia Fibra':
        provedorColor = AppColors.laranjaPrincipal;
        break;
      case 'JS Fibra':
        provedorColor = Colors.green;
        break;
      default:
        provedorColor = AppColors.cinza;
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Detalhes do Procedimento',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: provedorColor,
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProcedimentoFormPage(
                          procedimento: procedimento,
                          onSave: onEdit!,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: Text(
                          'Deseja realmente excluir o procedimento "${procedimento.nome}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCELAR'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete!(procedimento.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'EXCLUIR',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com nome e descrição
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: provedorColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: provedorColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge do provedor
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.business,
                          color: AppColors.textoClaro,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          procedimento.provedor,
                          style: const TextStyle(
                            color: AppColors.textoClaro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    procedimento.nome,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    procedimento.descricao,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Atualizado em: ${_formatarData(procedimento.dataAtualizacao)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Passos do procedimento
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_numbered,
                            color: provedorColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Passos do Procedimento',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: provedorColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: procedimento.passos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: provedorColor,
                                  foregroundColor: colorScheme.onPrimary,
                                  child: Text('${index + 1}'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    procedimento.passos[index],
                                    style: textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}

// Página de formulário para cadastro/edição de procedimento
class ProcedimentoFormPage extends StatefulWidget {
  final Procedimento? procedimento;
  final Function(Procedimento) onSave;

  const ProcedimentoFormPage({
    super.key,
    this.procedimento,
    required this.onSave,
  });

  @override
  State<ProcedimentoFormPage> createState() => _ProcedimentoFormPageState();
}

class _ProcedimentoFormPageState extends State<ProcedimentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _passoController = TextEditingController();
  final List<String> _passos = [];
  String _provedor = 'Bora Fibra'; // Valor padrão
  int? _editingIndex;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.procedimento != null) {
      _isEditing = true;
      _nomeController.text = widget.procedimento!.nome;
      _descricaoController.text = widget.procedimento!.descricao;
      _passos.addAll(widget.procedimento!.passos);
      _provedor = widget.procedimento!.provedor;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _passoController.dispose();
    super.dispose();
  }

  void _adicionarPasso() {
    if (_passoController.text.trim().isEmpty) return;

    setState(() {
      if (_editingIndex != null) {
        _passos[_editingIndex!] = _passoController.text;
        _editingIndex = null;
      } else {
        _passos.add(_passoController.text);
      }
      _passoController.clear();
    });
  }

  void _editarPasso(int index) {
    setState(() {
      _passoController.text = _passos[index];
      _editingIndex = index;
    });
  }

  void _excluirPasso(int index) {
    setState(() {
      _passos.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _passoController.clear();
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });
  }

  void _moverPasso(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _passos.removeAt(oldIndex);
      _passos.insert(newIndex, item);
    });
  }

  void _salvarProcedimento() {
    if (_formKey.currentState!.validate()) {
      if (_passos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione pelo menos um passo ao procedimento'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final agora = DateTime.now();
      final procedimento = Procedimento(
        id: _isEditing ? widget.procedimento!.id : DateTime.now().toString(),
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        passos: List.from(_passos),
        provedor: _provedor,
        dataCriacao: _isEditing ? widget.procedimento!.dataCriacao : agora,
        dataAtualizacao: agora,
      );

      widget.onSave(procedimento);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Definir cor baseada no provedor selecionado
    Color provedorColor;
    switch (_provedor) {
      case 'Bora Fibra':
        provedorColor = AppColors.azulPrincipal;
        break;
      case 'Bahia Fibra':
        provedorColor = AppColors.laranjaPrincipal;
        break;
      case 'JS Fibra':
        provedorColor = Colors.green;
        break;
      default:
        provedorColor = AppColors.cinza;
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Procedimento' : 'Novo Procedimento',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: provedorColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de informações básicas
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: provedorColor),
                        const SizedBox(width: 8),
                        Text(
                          'Informações Básicas',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: provedorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo Provedor
                    Text(
                      'Provedor',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.business,
                          color: provedorColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _provedor,
                      items: ['Bora Fibra', 'Bahia Fibra', 'JS Fibra'].map((provedor) {
                        return DropdownMenuItem(
                          value: provedor,
                          child: Text(provedor),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _provedor = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Nome
                    Text(
                      'Nome do Procedimento',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Instalação de ONU',
                        prefixIcon: Icon(
                          Icons.engineering_outlined,
                          color: provedorColor,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o nome do procedimento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Descrição
                    Text(
                      'Descrição',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: InputDecoration(
                        hintText:
                            'Descreva brevemente o objetivo do procedimento',
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: provedorColor,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe uma descrição';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Seção de passos
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: AppColors.laranjaPrincipal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Passos do Procedimento',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.laranjaPrincipal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo para adicionar passo
                    Text(
                      _editingIndex != null
                          ? 'Editar Passo ${_editingIndex! + 1}'
                          : 'Adicionar Passo',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passoController,
                            decoration: InputDecoration(
                              hintText: 'Descreva o passo a ser realizado',
                              prefixIcon: _editingIndex != null
                                  ? CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppColors.laranjaPrincipal,
                                      foregroundColor: AppColors.textoClaro,
                                      child: Text('${_editingIndex! + 1}'),
                                    )
                                  : Icon(
                                      Icons.add_task,
                                      color: AppColors.laranjaPrincipal,
                                    ),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _adicionarPasso,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.laranjaPrincipal,
                            foregroundColor: AppColors.textoClaro,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Icon(
                            _editingIndex != null ? Icons.check : Icons.add,
                          ),
                        ),
                      ],
                    ),

                    // Lista de passos adicionados
                    if (_passos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Passos Adicionados',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _passos.length,
                          onReorder: _moverPasso,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            return Card(
                              key: Key('passo_$index'),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: _editingIndex == index
                                  ? AppColors.laranjaSecundaria.withOpacity(0.2)
                                  : colorScheme.surface,
                              elevation: _editingIndex == index ? 3 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: _editingIndex == index
                                    ? BorderSide(
                                        color: AppColors.laranjaPrincipal,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _editingIndex == index
                                      ? AppColors.laranjaPrincipal
                                      : AppColors.laranjaPrincipal.withOpacity(0.7),
                                  foregroundColor: AppColors.textoClaro,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  _passos[index],
                                  style: textTheme.bodyLarge,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.laranjaPrincipal,
                                      ),
                                      onPressed: () => _editarPasso(index),
                                      tooltip: 'Editar passo',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _excluirPasso(index),
                                      tooltip: 'Excluir passo',
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(
                                        Icons.drag_handle,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _salvarProcedimento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provedorColor,
                    foregroundColor: AppColors.textoClaro,
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(
                    'SALVAR PROCEDIMENTO',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoClaro,
                    ),
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