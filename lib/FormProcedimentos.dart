import 'package:flutter/material.dart';
import 'Classes/Cores.dart';
import 'Classes/Procedimentos.dart';

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
  String _setor = 'Suporte'; // Valor padrão para setor
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
      _setor = widget.procedimento!.setor;
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
        setor: _setor, // Incluindo o setor
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

                    // Campo Setor
                    Text(
                      'Setor',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.category,
                          color: provedorColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _setor,
                      items: ['Financeiro', 'Suporte'].map((setor) {
                        return DropdownMenuItem(
                          value: setor,
                          child: Text(setor),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _setor = value!;
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