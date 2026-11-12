
class TransactionModel {
  final int? id;
  final String title;
  final int amount;
  final String type;
  final String category;
  final String note;
  final String date;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note = '',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return TransactionModel(
      id: map['id'] as int,
      title: map['title'] as String,
      amount: map['amount'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
      note: map['note'] as String,
      date: map['date'] as String,
    );
  }
}
