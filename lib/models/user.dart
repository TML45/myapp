class User {
  final String? id;
  final String dataDoProcedimento;
  final String procedimento;
  final String observacao;
  final List<String> arquivo;

  const User({
    this.id,
    required this.dataDoProcedimento,
    required this.procedimento,
    required this.observacao,
    required this.arquivo,
  });
}
