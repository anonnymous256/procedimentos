import 'package:flutter/material.dart';
import 'Classes/Cores.dart';
import 'Classes/Procedimentos.dart';
import 'Classes/Adminauth.dart';
import 'FormProcedimentos.dart';
import 'main.dart';
import 'CalcularAcordo.dart';
import 'CalcularProporcional.dart'; // Importando a calculadora proporcional

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
  String? _filtroSetor; // Novo filtro para setor
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

  void _mostrarCalculadoraProporcional() {
    showDialog(
      context: context,
      builder: (context) => const CalculadoraProporcionalDialog(),
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
          //Botão de calcular acordo
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalculadoraAcordoPage()),
              );
            },
            tooltip: 'Calculadora de Acordo',
          ),
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
            icon: Icon(
                _isAdmin ? Icons.admin_panel_settings : Icons.lock_outline),
            onPressed: _isAdmin ? _logout : _mostrarDialogoLogin,
            tooltip: _isAdmin ? 'Sair do modo admin' : 'Entrar como admin',
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Filtro por provedor
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Provedor',
                    prefixIcon: const Icon(Icons.business),
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
                    ...['Bora Fibra', 'Bahia Fibra', 'JS Fibra']
                        .map((provedor) {
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

                const SizedBox(height: 16),

                // Filtro por setor
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Setor',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _filtroSetor,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos os Setores'),
                    ),
                    ...['Financeiro', 'Suporte'].map((setor) {
                      return DropdownMenuItem(
                        value: setor,
                        child: Text(setor),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroSetor = value;
                    });
                  },
                ),
              ],
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

                // Aplicar filtros
                var procedimentosFiltrados = procedimentos;

                // Filtro por provedor
                if (_filtroProvedor != null) {
                  procedimentosFiltrados = procedimentosFiltrados
                      .where((p) => p.provedor == _filtroProvedor)
                      .toList();
                }

                // Filtro por setor
                if (_filtroSetor != null) {
                  procedimentosFiltrados = procedimentosFiltrados
                      .where((p) => p.setor == _filtroSetor)
                      .toList();
                }

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
                          _filtroProvedor != null && _filtroSetor != null
                              ? 'Nenhum procedimento para $_filtroProvedor no setor $_filtroSetor'
                              : _filtroProvedor != null
                                  ? 'Nenhum procedimento para $_filtroProvedor'
                                  : _filtroSetor != null
                                      ? 'Nenhum procedimento no setor $_filtroSetor'
                                      : 'Nenhum procedimento cadastrado',
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
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
                                    ? (procedimento) => _procedimentosService
                                        .atualizarProcedimento(procedimento)
                                    : null,
                                onDelete: _isAdmin
                                    ? (id) => _procedimentosService
                                        .excluirProcedimento(id)
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão de calculadora proporcional
          FloatingActionButton(
            heroTag: 'btnCalculadoraProporcional',
            onPressed: _mostrarCalculadoraProporcional,
            backgroundColor: AppColors.azulSecundario,
            tooltip: 'Calculadora Proporcional',
            child: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),
          // Botão de adicionar procedimento (apenas para admin)
          if (_isAdmin)
            FloatingActionButton.extended(
              heroTag: 'btnNovoProcedimento',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProcedimentoFormPage(
                      onSave: (procedimento) => _procedimentosService
                          .adicionarProcedimento(procedimento),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.laranjaPrincipal,
              foregroundColor: AppColors.textoClaro,
              icon: const Icon(Icons.add),
              label: const Text('Novo Procedimento'),
            ),
        ],
      ),
    );
  }
}