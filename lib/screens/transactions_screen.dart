
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  final VoidCallback onChanged;

  const TransactionsScreen({
    super.key,
    required this.onChanged,
  });

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends State<TransactionsScreen> {

  List<TransactionModel> _transactions = [];
  bool _loading = true;

  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  List<TransactionModel> get _filteredTransactions {
    if (_filter == 'all') return _transactions;

    return _transactions
        .where((item) => item.type == _filter)
        .toList();
  }

  Future<void> _openForm({
    TransactionModel? transaction,
  }) async {
    final result = await showModalBottomSheet<TransactionModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return TransactionForm(
          transaction: transaction,
        );
      },
    );

    if (result == null) return;

    if (transaction == null) {
      await DatabaseHelper.instance.insertTransaction(result);
    } else {
      await DatabaseHelper.instance.updateTransaction(result);
    }

    await _loadTransactions();
    widget.onChanged();
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);

    await _loadTransactions();
    widget.onChanged();
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text(
          'Transaksi yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTransaction(id);
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _filterButton('Semua', 'all'),
              const SizedBox(width: 8),
              _filterButton('Masuk', 'income'),
              const SizedBox(width: 8),
              _filterButton('Keluar', 'expense'),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
                  ? const Center(
                      child: Text('Belum ada transaksi.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final item = transactions[index];

                          final isIncome = item.type == 'income';
                          final color = isIncome
                              ? Colors.green
                              : Colors.red;

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    color.withValues(alpha: 0.12),
                                child: Icon(
                                  isIncome
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: color,
                                ),
                              ),

                              title: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                '${item.category} • ${item.date}'
                                '${item.note.isNotEmpty ? '\n${item.note}' : ''}',
                              ),

                              isThreeLine: item.note.isNotEmpty,

                              trailing: SizedBox(
                                width: 125,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isIncome ? '+' : '-'}${_formatCurrency(item.amount)}',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            _openForm(transaction: item);
                                          },
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _confirmDelete(item.id!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
         ),
       ],
      ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF142B4A),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
        ),
    );
  }

  Widget _filterButton(String label, String value) {
    final selected = _filter == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _filter = value;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? const Color(0xFF142B4A)
              : Colors.white,
          foregroundColor: selected
              ? Colors.white
              : const Color(0xFF142B4A),
        ),
        child: Text(label),
      ),
    );
  }
}
