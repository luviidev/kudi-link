import 'package:flutter/material.dart';

void main() => runApp(const KudiLinkApp());

// ---- App-wide colour palette (matches the design brief) ----
class AppColors {
  static const navy = Color(0xFF002060); // brand / trust
  static const amber = Color(0xFFD4A017); // standout: Apply for Loan
  static const green = Color(0xFF1E7D32); // healthy savings
  static const orange = Color(0xFFE07B00); // repayment action
  static const red = Color(0xFFC62828); // overdue loan
  static const paper = Color(0xFFF4F7FA); // high-contrast background
  static const grey = Color(0xFF5A6B7A);
}

class KudiLinkApp extends StatelessWidget {
  const KudiLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KudiLink Kiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Calibri', scaffoldBackgroundColor: AppColors.paper),
      home: const DashboardScreen(),
    );
  }
}


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _loanBalance = 1150.00;

// Helper: shows a simple confirmation when a button is tapped.
void _onAction(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildInstructionBar(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- ACCOUNTS GROUP (separate from actions) ----
                    _sectionLabel('YOUR ACCOUNTS'),
                    const SizedBox(height: 10),
                    _balanceCard(
                      label: 'Savings Balance',
                      amount: 'GH\u20B5 4,280.00',
                      tag: 'HEALTHY',
                      color: AppColors.green,
                      bg: const Color(0xFFE4F1E6),
                    ),
                    const SizedBox(height: 14),
                    _balanceCard(
                      label: 'Loan Balance',
                      amount: 'GH\u20B5 ${_loanBalance.toStringAsFixed(2)}',
                      tag: _loanBalance > 0 ? 'OVERDUE \u2022 REPAY SOON' : 'PAID OFF',
                      color: _loanBalance > 0 ? AppColors.red : AppColors.green,
                      bg: _loanBalance > 0 ? const Color(0xFFFBE4E4) : const Color(0xFFE4F1E6),
                    ),
                    const SizedBox(height: 24),

                    // ---- ACTIONS GROUP ----
                    _sectionLabel('WHAT WOULD YOU LIKE TO DO?'),
                    const SizedBox(height: 12),
                    _actionButton(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Check Balance',
                      subtitle: 'View savings & loan details',
                      bg: AppColors.green,
                      fg: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BalanceDetailsScreen(
                                    savingsBalance: 4280.00,
                                    loanBalance: _loanBalance,
                                  )),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _actionButton(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Apply for Loan',
                      subtitle: 'Quick approval at your branch',
                      bg: AppColors.amber,
                      fg: AppColors.navy,
                      onTap: () async {
                        // Logic: Check if loan balance exceeds 1000
                        if (_loanBalance > 1000) {
                          _onAction(context,
                              'Action Required: Please repay your GH\u20B5 ${_loanBalance.toStringAsFixed(2)} loan first!');
                        } else {
                          final double? newLoan = await Navigator.push<double>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ApplyLoanScreen()),
                          );

                          if (newLoan != null && newLoan > 0) {
                            setState(() {
                              _loanBalance += newLoan;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _actionButton(
                      context,
                      icon: Icons.payments,
                      title: 'Make Repayment',
                      subtitle: 'Pay down your outstanding loan',
                      bg: AppColors.orange,
                      fg: Colors.white,
                      onTap: () async {
                        final paid = await Navigator.push<double>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RepaymentScreen(initialBalance: _loanBalance)),
                        );

                        if (paid != null && paid > 0) {
                          setState(() {
                            _loanBalance -= paid;
                            if (_loanBalance < 0) _loanBalance = 0;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Header with logo, brand name, and welcome ----
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('K',
                      style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KudiLink',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('Microfinance Self-Service',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Lucid',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Instruction bar ----
  Widget _buildInstructionBar() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Text(
        'Tap any button to continue',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---- Small uppercase section label ----
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.grey,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  // ---- A coloured balance card ----
  Widget _balanceCard({
    required String label,
    required String amount,
    required String tag,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: color),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(tag,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ---- A large tappable action button ----
  Widget _actionButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color bg,
        required Color fg,
        VoidCallback? onTap,
      }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? () => _onAction(context, '$title tapped'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: fg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: fg,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            color: fg.withValues(alpha: 0.9), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Footer ----
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFD7DEE6))),
      ),
      child: const Text(
        'Connected to Central Banking System \u2022 Branch: Teshie-Nungua',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.grey, fontSize: 12),
      ),
    );
  }
}



class BalanceDetailsScreen extends StatelessWidget {
  final double savingsBalance;
  final double loanBalance;

  const BalanceDetailsScreen({
    super.key,
    required this.savingsBalance,
    required this.loanBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Summary',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy),
            ),
            const SizedBox(height: 20),
            _detailSection(
              title: 'Savings Account',
              icon: Icons.savings,
              color: AppColors.green,
              details: [
                _detailRow('Acc No.', 'KL-990-2342'),
                _detailRow('Balance', 'GH\u20B5 ${savingsBalance.toStringAsFixed(2)}'),
                _detailRow('Interest Rate', '4.5% p.a.'),
              ],
            ),
            const SizedBox(height: 24),
            _detailSection(
              title: 'Loan Account',
              icon: Icons.account_balance,
              color: loanBalance > 0 ? AppColors.red : AppColors.green,
              details: [
                _detailRow('Status', loanBalance > 0 ? 'Active' : 'Settled'),
                _detailRow('Outstanding', 'GH\u20B5 ${loanBalance.toStringAsFixed(2)}'),
                _detailRow('Repayment Type', 'Monthly Deductions'),
                _detailRow('Next Due Date', '15th Oct 2023'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Activity',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            _activityTile('Loan Repayment', '-GH\u20B5 200.00', 'Oct 02'),
            _activityTile('Savings Interest', '+GH\u20B5 12.40', 'Sep 30'),
            _activityTile('Mobile Money Deposit', '+GH\u20B5 500.00', 'Sep 28'),
          ],
        ),
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const Divider(height: 24),
          ...details,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.navy)),
        ],
      ),
    );
  }

  Widget _activityTile(String title, String amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amount.startsWith('+') ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  double requestedAmount = 0.0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Basic interest calc for preview
    double totalRepayable = requestedAmount * 1.15; // 15% interest

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Flexible Loan Options',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the amount you wish to borrow. Approval is instant for amounts under GH\u20B5 5,000.',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Requested Amount',
                prefixText: 'GH\u20B5 ',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber, width: 2)),
              ),
              onChanged: (value) {
                setState(() {
                  requestedAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _infoRow('Interest Rate', '15% p.a.'),
                  const Divider(height: 24),
                  _infoRow('Total Repayable', 'GH\u20B5 ${totalRepayable.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _infoRow('Monthly Payment (12 mo)', 'GH\u20B5 ${(totalRepayable / 12).toStringAsFixed(2)}'),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: requestedAmount > 0 && requestedAmount <= 5000
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('GH\u20B5 ${requestedAmount.toStringAsFixed(2)} Loan Approved & Disbursed!'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                      Navigator.pop(context, requestedAmount);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm & Disburse',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 16)),
      ],
    );
  }
}

class RepaymentScreen extends StatefulWidget {
  final double initialBalance;
  const RepaymentScreen({super.key, required this.initialBalance});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  late double currentLoan;
  double repaymentAmount = 0.0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentLoan = widget.initialBalance;
  }

  @override
  Widget build(BuildContext context) {
    double remaining = currentLoan - repaymentAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Repayment'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Current Loan Balance',
                style: TextStyle(fontSize: 16, color: AppColors.grey)),
            Text('GH\u20B5 ${currentLoan.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.red)),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Repayment Amount',
                prefixText: 'GH\u20B5 ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  repaymentAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Balance after payment:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    'GH\u20B5 ${remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: remaining <= 0 ? AppColors.green : AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: repaymentAmount > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Repayment of GH\u20B5 ${repaymentAmount.toStringAsFixed(2)} processed!')),
                      );
                      Navigator.pop(context, repaymentAmount);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm Repayment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}


 
