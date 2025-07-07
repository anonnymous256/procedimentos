import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo de dados para o procedimento
class Procedimento {
  final String id;
  final String nome;
  final String descricao;
  final List<String> passos;
  final String provedor;
  final String setor; // Novo campo para setor
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Procedimento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.passos,
    required this.provedor,
    required this.setor, // Adicionado o setor como parâmetro obrigatório
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
      'setor': setor, // Incluindo o setor no Map
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
      setor: data['setor'] ?? 'Suporte', // Valor padrão para documentos antigos
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