import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/budget_provider.dart';
import '../utils/theme.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/budget_chart.dart';
import '../widgets/category_chip.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to group transactions by calendar date
  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final dateKey = _getDateKey(tx.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }

  Future<void> _pickDateRange(
    BuildContext context,
    BudgetProvider provider,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: provider.selectedDateRangeFilter,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              onSurface: isDark
                  ? AppTheme.darkTextPrimary
                  : AppTheme.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      provider.setDateRangeFilter(picked);
    }
  }

  Widget _buildTransactionsHeader(
    BuildContext context,
    BudgetProvider provider,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spends History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Analyze & Filter Spends',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                provider.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nights_stay_rounded,
                color: provider.isDarkMode ? Colors.amber : AppTheme.primary,
              ),
              onPressed: () => provider.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavBarItem(
              index: 0,
              label: 'Home',
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
              isDark: isDark,
            ),
            const SizedBox(width: 40),
            _buildNavBarItem(
              index: 1,
              label: 'Transactions',
              activeIcon: Icons.receipt_long_rounded,
              inactiveIcon: Icons.receipt_long_outlined,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppTheme.primary;
    final inactiveColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : inactiveColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return IndexedStack(
            index: _currentIndex,
            children: [
              _HomeTab(
                provider: provider,
                onViewAllPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
              _TransactionsTab(
                provider: provider,
                searchController: _searchController,
                groupTransactionsByDate: _groupTransactionsByDate,
                pickDateRange: (context) => _pickDateRange(context, provider),
                buildHeader: (context, isDarkVal) =>
                    _buildTransactionsHeader(context, provider, isDarkVal),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddExpenseSheet(),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Log Spend',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final BudgetProvider provider;
  final VoidCallback onViewAllPressed;

  const _HomeTab({required this.provider, required this.onViewAllPressed});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _selectedHomeCategory;

  Future<void> _showClearBudgetDialog(BuildContext context, BudgetProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text('Reset Budget?'),
            ],
          ),
          content: const Text(
            'This will permanently delete all transaction history to start a new budget. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await provider.clearAllTransactions();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget reset successfully! Start logging new spends.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByMonth(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final monthKey = DateTime(tx.date.year, tx.date.month);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(tx);
    }
    return grouped;
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BudBoy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Track • Filter • Grow',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (widget.provider.transactions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _showClearBudgetDialog(context, widget.provider),
                    tooltip: 'Reset Budget',
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    widget.provider.isDarkMode
                        ? Icons.wb_sunny_rounded
                        : Icons.nights_stay_rounded,
                    color: widget.provider.isDarkMode ? Colors.amber : AppTheme.primary,
                  ),
                  onPressed: () => widget.provider.toggleTheme(),
                  tooltip: 'Toggle Theme',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShowcaseSelector(BuildContext context, bool isDark) {
    final categories = ['Food', 'Transport', 'Stationery', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Showcase Category Focus',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedHomeCategory == cat;
              final color = AppTheme.getCategoryColor(cat);
              final icon = AppTheme.getCategoryIcon(cat);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedHomeCategory = null;
                      } else {
                        _selectedHomeCategory = cat;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 95,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : (isDark ? AppTheme.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? color : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? Colors.white : color)
                                : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown(BuildContext context, BudgetProvider provider, bool isDark) {
    final monthlyData = _groupTransactionsByMonth(provider.transactions);
    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            'Monthly Spend Summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (sortedMonths.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: Text(
                'No data available to compile monthly breakdown.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sortedMonths.length,
            itemBuilder: (context, index) {
              final monthDateTime = sortedMonths[index];
              final txs = monthlyData[monthDateTime]!;
              final monthTotal = txs.fold(0.0, (sum, tx) => sum + tx.amount);
              final monthLabel = DateFormat('MMMM yyyy').format(monthDateTime);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () {
                    final startOfMonth = DateTime(monthDateTime.year, monthDateTime.month, 1);
                    final nextMonth = DateTime(monthDateTime.year, monthDateTime.month + 1, 1);
                    final endOfMonth = nextMonth.subtract(const Duration(seconds: 1));

                    provider.setDateRangeFilter(DateTimeRange(start: startOfMonth, end: endOfMonth));
                    widget.onViewAllPressed();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.05 : 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${txs.length} transactions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '\$${monthTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, double> chartBreakdown;
    double summaryTotalSpent;
    int summaryLogCount;

    if (_selectedHomeCategory == null) {
      chartBreakdown = widget.provider.categoryBreakdown;
      summaryTotalSpent = widget.provider.totalSpent;
      summaryLogCount = widget.provider.transactions.length;
    } else {
      final amount = widget.provider.categoryBreakdown[_selectedHomeCategory!] ?? 0.0;
      chartBreakdown = amount > 0 ? { _selectedHomeCategory!: amount } : {};
      summaryTotalSpent = amount;
      summaryLogCount = widget.provider.transactions
          .where((tx) => tx.category == _selectedHomeCategory)
          .length;
    }

    final recentTxs = List<Transaction>.from(widget.provider.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTxsToShow = recentTxs.take(3).toList();

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SummaryCard(
                    totalSpent: summaryTotalSpent,
                    transactionCount: summaryLogCount,
                  ),
                  const SizedBox(height: 16),
                  BudgetChart(
                    categoryData: chartBreakdown,
                    totalAmount: summaryTotalSpent,
                  ),
                ],
              ),
            ),
          ),
          if (widget.provider.transactions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: _buildCategoryShowcaseSelector(context, isDark),
              ),
            ),
          if (widget.provider.transactions.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildMonthlyBreakdown(context, widget.provider, isDark),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Spends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.provider.transactions.isNotEmpty)
                    TextButton(
                      onPressed: widget.onViewAllPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.provider.transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 32,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No spends logged',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final tx = recentTxsToShow[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4.0,
                  ),
                  child: TransactionCard(
                    transaction: tx,
                    onDelete: () => widget.provider.deleteTransaction(tx.id),
                  ),
                );
              }, childCount: recentTxsToShow.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  final BudgetProvider provider;
  final TextEditingController searchController;
  final Map<String, List<Transaction>> Function(List<Transaction>)
  groupTransactionsByDate;
  final Future<void> Function(BuildContext) pickDateRange;
  final Widget Function(BuildContext, bool) buildHeader;

  const _TransactionsTab({
    required this.provider,
    required this.searchController,
    required this.groupTransactionsByDate,
    required this.pickDateRange,
    required this.buildHeader,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTxs = provider.filteredTransactions;
    final groupedTxs = groupTransactionsByDate(filteredTxs);
    final filterCategories = ['All', ...provider.allCategories];

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: buildHeader(context, isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrations & Search',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (provider.selectedCategoryFilter != null ||
                          provider.selectedDateRangeFilter != null ||
                          provider.searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            provider.clearFilters();
                            searchController.clear();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar Widget
                  TextField(
                    controller: searchController,
                    onChanged: (value) => provider.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search notes or categories...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: provider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Chips Filter
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filterCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filterCategories[index];
                        final isSelected =
                            (cat == 'All' &&
                                provider.selectedCategoryFilter == null) ||
                            (provider.selectedCategoryFilter == cat);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryChip(
                            category: cat,
                            isSelected: isSelected,
                            onTap: () {
                              if (cat == 'All') {
                                provider.setCategoryFilter(null);
                              } else {
                                provider.setCategoryFilter(cat);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => pickDateRange(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: provider.selectedDateRangeFilter != null
                            ? AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                            : (isDark ? AppTheme.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: provider.selectedDateRangeFilter != null
                              ? AppTheme.primary
                              : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                          width: provider.selectedDateRangeFilter != null
                              ? 1.5
                              : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: provider.selectedDateRangeFilter != null
                                    ? AppTheme.primary
                                    : (isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.lightTextSecondary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                provider.selectedDateRangeFilter == null
                                    ? 'Filter by Date Range (All Time)'
                                    : '${DateFormat('MMM d, yyyy').format(provider.selectedDateRangeFilter!.start)} - ${DateFormat('MMM d, yyyy').format(provider.selectedDateRangeFilter!.end)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      provider.selectedDateRangeFilter != null
                                      ? (isDark
                                            ? Colors.white
                                            : AppTheme.primary)
                                      : (isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.lightTextPrimary),
                                ),
                              ),
                            ],
                          ),
                          if (provider.selectedDateRangeFilter != null)
                            GestureDetector(
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  provider.setDateRangeFilter(null);
                                });
                              },
                              child: const Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (filteredTxs.isNotEmpty)
                    Text(
                      'Filtered Total: \$${provider.filteredTotalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (filteredTxs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No spends logged',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Log a spend using the + button below or try resetting filters.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final dateKey = groupedTxs.keys.elementAt(index);
                final txsForDate = groupedTxs[dateKey]!;
                final dayTotal = txsForDate.fold(
                  0.0,
                  (sum, tx) => sum + tx.amount,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                          Text(
                            'Total: \$${dayTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...txsForDate.map((tx) {
                        return TransactionCard(
                          transaction: tx,
                          onDelete: () => provider.deleteTransaction(tx.id),
                        );
                      }),
                    ],
                  ),
                );
              }, childCount: groupedTxs.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
