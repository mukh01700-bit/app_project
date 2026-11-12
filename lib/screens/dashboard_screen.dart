
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../core/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _summary = {
    'income': 0,
    'expense': 0,
    'balance': 0,
  };

  List<TransactionModel> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final summary = await DatabaseHelper.instance.getSummary();
    final transactions =
        await DatabaseHelper.instance.getTransactions();

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _recent = transactions.take(5).toList();
      _loading = false;
    });
  }

  String _currency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Berikut ringkasan keuanganmu.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Saldo',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _currency(_summary['balance']!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 15),
                  const Text(
                    'Saldo keseluruhan',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Pemasukan',
                    _summary['income']!,
                    Icons.trending_up,
                    AppTheme.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    'Pengeluaran',
                    _summary['expense']!,
                    Icons.trending_down,
                    AppTheme.expense,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Smart Insight',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _summary['expense'] == 0
                          ? 'Mulai catat pengeluaran untuk mendapatkan analisis keuangan.'
                          : 'Total pengeluaranmu adalah ${_currency(_summary['expense']!)}. Pantau pengeluaran agar tetap sesuai anggaran.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Transaksi Terbaru',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_recent.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Text('Belum ada transaksi.'),
                ),
              )
            else
              ..._recent.map((item) {
                final income = item.type == 'income';

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      income
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: income ? Colors.green : Colors.red,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.category),
                    trailing: Text(
                      '${income ? '+' : '-'}${_currency(item.amount)}',
                      style: TextStyle(
                        color: income ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    int amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            _currency(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
