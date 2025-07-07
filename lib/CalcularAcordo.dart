import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Classes/Cores.dart';

class CalculadoraAcordoPage extends StatefulWidget {
  const CalculadoraAcordoPage({super.key});

  @override
  State<CalculadoraAcordoPage> createState() => _CalculadoraAcordoPageState();
}

class _CalculadoraAcordoPageState extends State<CalculadoraAcordoPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  
  String _fibraSelecionada = 'JS e Bahia'; // Valor padrão
  int _percentualEntrada = 50; // Valor padrão (50%)
  int _numeroParcelas = 3; // Valor padrão (3 parcelas)
  
  double _valorMensal = 0.0;
  double _valorTotal = 0.0;
  double _valorEntrada = 0.0;
  double _valorRestante = 0.0;
  double _valorParcela = 0.0;

  @override
  void initState() {
    super.initState();
    _valorController.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  void _calcularValores() {
    if (_valorController.text.isEmpty) {
      setState(() {
        _valorMensal = 0.0;
        _valorTotal = 0.0;
        _valorEntrada = 0.0;
        _valorRestante = 0.0;
        _valorParcela = 0.0;
      });
      return;
    }

    // Obter o valor mensal digitado
    _valorMensal = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

    // Calcular o valor total com base na fibra selecionada
    if (_fibraSelecionada == 'JS e Bahia') {
      // JS → valor de 2 meses e 15 dias
      _valorTotal = _valorMensal * 2 + _valorMensal * (15 / 30);
    } else if (_fibraSelecionada == 'JS Paramount') {
      // JS Paramount → valor de 1 mês e 10 dias
      _valorTotal = _valorMensal * 1 + _valorMensal * (10 / 30);
    } else {
      // Bora → valor de 1 mês e 5 dias
      _valorTotal = _valorMensal * 1 + _valorMensal * (5 / 30);
    }

    // Calcular o valor da entrada com base no percentual selecionado
    _valorEntrada = _valorTotal * (_percentualEntrada / 100);

    // Calcular o valor restante a ser parcelado
    _valorRestante = _valorTotal - _valorEntrada;

    // Calcular o valor de cada parcela
    _valorParcela = _valorRestante / _numeroParcelas;

    setState(() {});
  }

  // Método para gerar a mensagem de acordo
  String _gerarMensagemAcordo() {
    String parcelasTexto = _numeroParcelas == 1 ? "parcela única" : "$_numeroParcelas parcelas";
    
    return 
        "Conseguimos viabilizar um acordo para seu plano de fibra no valor total de R\$ ${_valorTotal.toStringAsFixed(2)}.\n\n"
        "Para sua comodidade, oferecemos as seguintes condições:\n"
        "• Entrada de R\$ ${_valorEntrada.toStringAsFixed(2)} (${_percentualEntrada}% do valor)\n"
        "• Saldo restante de R\$ ${_valorRestante.toStringAsFixed(2)} parcelado em $parcelasTexto de R\$ ${_valorParcela.toStringAsFixed(2)}\n\n"
        "O valor das parcelas será diluído nas mensalidades subsequentes, sem comprometer seu orçamento.\n\n"
        "Aguardamos sua confirmação para prosseguirmos com o acordo.";
  }

  // Método para copiar a mensagem e mostrar o diálogo
  void _copiarEMostrarMensagem() {
    final mensagem = _gerarMensagemAcordo();
    
    // Copiar para a área de transferência
    Clipboard.setData(ClipboardData(text: mensagem));
    
    // Mostrar diálogo com a mensagem
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Acordo Gerado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A mensagem abaixo foi copiada para a área de transferência:'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 7, 7, 7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                mensagem,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('FECHAR'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: mensagem));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mensagem copiada novamente!')),
              );
            },
            icon: Icon(Icons.copy),
            label: Text('COPIAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Definir cor baseada na fibra selecionada
    Color fibraColor;
    switch (_fibraSelecionada) {
      case 'JS e Bahia':
        fibraColor = Colors.green;
        break;
      case 'JS Paramount':
        fibraColor = Colors.purple;
        break;
      default:
        fibraColor = AppColors.azulPrincipal;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculadora de Acordo',
          style: TextStyle(
            color: AppColors.textoClaro,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: fibraColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de entrada de dados
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações do Acordo',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: fibraColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Valor mensal
                        Text(
                          'Valor Mensal (R\$)',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _valorController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Ex.: 99,90',
                            prefixIcon: Icon(Icons.attach_money, color: fibraColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, informe o valor mensal';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Seleção de Fibra
                        Text(
                          'Selecione a Fibra',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borda),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFibraOption(
                                      'JS e Bahia',
                                      Colors.green,
                                      Icons.fiber_smart_record,
                                      '2 meses e 15 dias',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildFibraOption(
                                      'Bora',
                                      AppColors.azulPrincipal,
                                      Icons.fiber_new,
                                      '1 mês e 5 dias',
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.borda),
                                  ),
                                ),
                                child: _buildFibraOption(
                                  'JS Paramount',
                                  Colors.purple,
                                  Icons.star,
                                  '1 mês e 10 dias',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Seleção de percentual de entrada
                        Text(
                          'Percentual de Entrada',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [50, 60, 70].map((percentual) {
                            return _buildPercentualButton(
                              percentual,
                              fibraColor,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Seleção de número de parcelas
                        Text(
                          'Número de Parcelas: $_numeroParcelas',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _numeroParcelas.toDouble(),
                          min: 1,
                          max: 6,
                          divisions: 5,
                          activeColor: fibraColor,
                          inactiveColor: fibraColor.withOpacity(0.3),
                          label: _numeroParcelas.toString(),
                          onChanged: (value) {
                            setState(() {
                              _numeroParcelas = value.toInt();
                              _calcularValores();
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => Text('${index + 1}x')),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Seção de resultados
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: fibraColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calculate, color: fibraColor),
                            const SizedBox(width: 8),
                            Text(
                              'Resultados do Acordo',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: fibraColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        
                        // Valor total
                        _buildResultRow(
                          'Valor Total:',
                          'R\$ ${_valorTotal.toStringAsFixed(2)}',
                          fibraColor,
                        ),
                        const SizedBox(height: 12),
                        
                        // Detalhamento do cálculo
                        if (_valorMensal > 0) ...[
                          Text(
                            _fibraSelecionada == 'JS e Bahia'
                                ? 'Cálculo: R\$ ${_valorMensal.toStringAsFixed(2)} × 2 meses + R\$ ${_valorMensal.toStringAsFixed(2)} × (15/30 dias)'
                                : _fibraSelecionada == 'JS Paramount'
                                    ? 'Cálculo: R\$ ${_valorMensal.toStringAsFixed(2)} × 1 mês + R\$ ${_valorMensal.toStringAsFixed(2)} × (10/30 dias)'
                                    : 'Cálculo: R\$ ${_valorMensal.toStringAsFixed(2)} × 1 mês + R\$ ${_valorMensal.toStringAsFixed(2)} × (5/30 dias)',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Valor da entrada
                        _buildResultRow(
                          'Entrada (${ _percentualEntrada}%):',
                          'R\$ ${_valorEntrada.toStringAsFixed(2)}',
                          fibraColor,
                        ),
                        const SizedBox(height: 12),
                        
                        // Valor restante
                        _buildResultRow(
                          'Valor Restante:',
                          'R\$ ${_valorRestante.toStringAsFixed(2)}',
                          fibraColor,
                        ),
                        const SizedBox(height: 12),
                        
                        // Valor da parcela
                        _buildResultRow(
                          'Valor da Parcela ($_numeroParcelas×):',
                          'R\$ ${_valorParcela.toStringAsFixed(2)}',
                          fibraColor,
                          isBold: true,
                          isLarge: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botão para compartilhar ou salvar o acordo
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _valorMensal > 0 ? _copiarEMostrarMensagem : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fibraColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text(
                      'GERAR MENSAGEM DE ACORDO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFibraOption(String nome, Color cor, IconData icone, String descricao) {
    bool isSelected = _fibraSelecionada == nome;
    
    return InkWell(
      onTap: () {
        setState(() {
          _fibraSelecionada = nome;
          _calcularValores();
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? cor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? cor : Colors.transparent,
            width: 2,
          ),
          borderRadius: nome == 'JS Paramount' 
              ? const BorderRadius.vertical(bottom: Radius.circular(12))
              : nome == 'JS e Bahia'
                  ? const BorderRadius.only(topLeft: Radius.circular(12))
                  : const BorderRadius.only(topRight: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              color: cor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              nome,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentualButton(int percentual, Color cor) {
    bool isSelected = _percentualEntrada == percentual;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _percentualEntrada = percentual;
          _calcularValores();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? cor : cor.withOpacity(0.1),
        foregroundColor: isSelected ? Colors.white : cor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        '$percentual%',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color cor, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? cor : null,
          ),
        ),
      ],
    );
  }
}