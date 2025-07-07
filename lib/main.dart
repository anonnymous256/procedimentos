import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Classes/Cores.dart';
import 'Classes/Procedimentos.dart';
import 'ListarProcedimentos.dart';
import 'FormProcedimentos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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



// Delegate para busca de procedimentos
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
              procedimento.provedor.toLowerCase().contains(lowercaseQuery) ||
              procedimento.setor.toLowerCase().contains(lowercaseQuery); // Adicionando busca por setor
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
    
    // Definir cor baseada no setor
    Color setorColor;
    IconData setorIcon;
    switch (procedimento.setor) {
      case 'Financeiro':
        setorColor = Colors.green;
        setorIcon = Icons.attach_money;
        break;
      case 'Suporte':
        setorColor = Colors.purple;
        setorIcon = Icons.headset_mic;
        break;
      default:
        setorColor = AppColors.cinza;
        setorIcon = Icons.category;
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
                        Row(
                          children: [
                            Text(
                              procedimento.provedor,
                              style: textTheme.bodyMedium?.copyWith(
                                color: provedorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: setorColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    setorIcon,
                                    size: 12,
                                    color: setorColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    procedimento.setor,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: setorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    
    // Definir cor e ícone baseados no setor
    Color setorColor;
    IconData setorIcon;
    switch (procedimento.setor) {
      case 'Financeiro':
        setorColor = Colors.green;
        setorIcon = Icons.attach_money;
        break;
      case 'Suporte':
        setorColor = Colors.purple;
        setorIcon = Icons.headset_mic;
        break;
      default:
        setorColor = AppColors.cinza;
        setorIcon = Icons.category;
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
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      // Badge do setor
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: setorColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              setorIcon,
                              color: AppColors.textoClaro,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              procedimento.setor,
                              style: const TextStyle(
                                color: AppColors.textoClaro,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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


