import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Classes/Cores.dart';

class CalculadoraProporcionalDialog extends StatefulWidget {
  const CalculadoraProporcionalDialog({super.key});

  @override
  State<CalculadoraProporcionalDialog> createState() => _CalculadoraProporcionalDialogState();
}

class _CalculadoraProporcionalDialogState extends State<CalculadoraProporcionalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _diasController = TextEditingController();
  
  double _valorMensal = 0.0;
  int _diasUtilizados = 0;
  double _valorProporcional = 0.0;

  @override
  void initState() {
    super.initState();
    // Adiciona listeners para atualizar automaticamente os cálculos
    _valorController.addListener(_calcularProporcional);
    _diasController.addListener(_calcularProporcional);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _diasController.dispose();
    super.dispose();
  }

  void _calcularProporcional() {
    // Verifica se os campos têm valores válidos
    if (_valorController.text.isEmpty || _diasController.text.isEmpty) {
      setState(() {
        _valorProporcional = 0.0;
      });
      return;
    }

    // Converte os valores
    final valorMensal = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;
    final diasUtilizados = int.tryParse(_diasController.text) ?? 0;
    
    // Verifica se os dias estão no intervalo válido
    if (diasUtilizados <= 0 || diasUtilizados > 90) {
      setState(() {
        _valorProporcional = 0.0;
      });
      return;
    }
    
    // Calcula o valor proporcional
    setState(() {
      _valorMensal = valorMensal;
      _diasUtilizados = diasUtilizados;
      _valorProporcional = _valorMensal * (_diasUtilizados / 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.azulPrincipal),
                  const SizedBox(width: 10),
                  Text(
                    'Calculadora Proporcional',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulPrincipal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Calcule o valor proporcional aos dias utilizados',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Divider(height: 20),
              
              // Campos de entrada
              Text(
                'Valor Mensal do Plano (R\$)',
                style: textTheme.titleSmall,
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
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.azulPrincipal),
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
                onChanged: (_) => _calcularProporcional(),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Quantidade de Dias Utilizados',
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diasController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Ex.: 15',
                  prefixIcon: Icon(Icons.date_range, color: AppColors.azulPrincipal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a quantidade de dias';
                  }
                  final dias = int.tryParse(value);
                  if (dias == null || dias <= 0 || dias > 90) {
                    return 'Informe um valor entre 1 e 90';
                  }
                  return null;
                },
                onChanged: (_) => _calcularProporcional(),
              ),
              const SizedBox(height: 20),
              
              // Resultado do cálculo
              if (_valorMensal > 0 && _diasUtilizados > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.azulPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.azulPrincipal.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado do Cálculo',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulPrincipal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildResultRow('Valor Mensal:', 'R\$ ${_valorMensal.toStringAsFixed(2)}'),
                      const SizedBox(height: 5),
                      _buildResultRow('Dias Utilizados:', '$_diasUtilizados dias'),
                      const SizedBox(height: 5),
                      _buildResultRow('Valor Diário:', 'R\$ ${(_valorMensal / 30).toStringAsFixed(2)}'),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor Proporcional:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'R\$ ${_valorProporcional.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.azulPrincipal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('FECHAR'),
                  ),
                  if (_valorMensal > 0 && _diasUtilizados > 0) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final texto = 'Cálculo Proporcional:\n'
                            'Valor Mensal: R\$ ${_valorMensal.toStringAsFixed(2)}\n'
                            'Dias Utilizados: $_diasUtilizados dias\n'
                            'Valor Proporcional: R\$ ${_valorProporcional.toStringAsFixed(2)}';
                        
                        Clipboard.setData(ClipboardData(text: texto));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Resultado copiado para a área de transferência')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulSecundario,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text('COPIAR'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}