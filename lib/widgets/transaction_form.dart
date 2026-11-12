
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionForm({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionForm> createState() =>
      _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String _category = 'Makanan';
  DateTime _date = DateTime.now();

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Hadiah',
    'Bisnis',
    'Lainnya',
  ];

  List<String> get _categories =>
      _type == 'income'
          ? _incomeCategories
          : _expenseCategories;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text =
          transaction.amount.toString();
      _noteController.text = transaction.note;

      _type = transaction.type;
      _category = transaction.category;
      _date = DateTime.parse(transaction.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: int.parse(_amountController.text),
      type: _type,
      category: _category,
      note: _noteController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_date),
    );

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text('Jenis Transaksi'),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      'Pemasukan',
                      'income',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _typeButton(
                      'Pengeluaran',
                      'expense',
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text('Nama Transaksi'),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Makan siang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Nama transaksi wajib diisi'
                        : null,
              ),

              const SizedBox(height: 15),

              const Text('Nominal (Rp)'),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 25000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = int.tryParse(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Masukkan nominal yang valid';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              const Text('Kategori'),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 15),

              const Text('Tanggal'),

              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  DateFormat('dd MMMM yyyy', 'id_ID')
                      .format(_date),
                ),
              ),

              const SizedBox(height: 15),

              const Text('Catatan (Opsional)'),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF142B4A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Simpan Transaksi',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(
    String label,
    String value,
    Color color,
  ) {
    final selected = _type == value;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _type = value;

          if (!_categories.contains(_category)) {
            _category = _categories.first;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? color.withValues(alpha: 0.12)
            : Colors.transparent,
        foregroundColor: color,
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.all(14),
      ),
      child: Text(label),
    );
  }
}
