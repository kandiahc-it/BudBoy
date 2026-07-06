import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class BudgetProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isDarkMode = true;

  // Predefined default categories
  final List<String> _defaultCategories = ['Food', 'Transport', 'Stationery'];

  // Filters state
  String? _selectedCategoryFilter;
  DateTimeRange? _selectedDateRangeFilter;
  String _searchQuery = '';

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  List<String> get defaultCategories => _defaultCategories;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  DateTimeRange? get selectedDateRangeFilter => _selectedDateRangeFilter;
  String get searchQuery => _searchQuery;

  BudgetProvider() {
    _loadTransactions();
  }

  // Load transactions and settings from SharedPreferences
  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('budboy_dark_mode') ?? true;
      final String? transactionsJson = prefs.getString('budboy_transactions');
      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions = decoded
            .map((item) => Transaction.fromMap(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save transactions to SharedPreferences
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _transactions.map((tx) => tx.toMap()).toList(),
      );
      await prefs.setString('budboy_transactions', encoded);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Toggle and save theme state
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('budboy_dark_mode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme state: $e');
    }
  }

  // Get all unique categories (default + any custom ones created by the user)
  List<String> get allCategories {
    final customCategories = _transactions
        .where((tx) => tx.isCustomCategory)
        .map((tx) => tx.category)
        .toSet()
        .toList();

    // Sort custom categories alphabetically
    customCategories.sort();

    return [..._defaultCategories, ...customCategories, 'Other'];
  }

  // Filter and search transactions
  List<Transaction> get filteredTransactions {
    return _transactions.where((tx) {
      // Category filter
      if (_selectedCategoryFilter != null &&
          tx.category != _selectedCategoryFilter) {
        return false;
      }

      // Date range filter
      if (_selectedDateRangeFilter != null) {
        final start = _selectedDateRangeFilter!.start;
        final end = _selectedDateRangeFilter!.end.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        );
        if (tx.date.isBefore(start) || tx.date.isAfter(end)) {
          return false;
        }
      }

      // Search notes/category query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final noteMatch = tx.note.toLowerCase().contains(query);
        final categoryMatch = tx.category.toLowerCase().contains(query);
        if (!noteMatch && !categoryMatch) {
          return false;
        }
      }

      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date)); // Sort newest first
  }

  // Get total amount spent overall
  double get totalSpent {
    return _transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Get total spent on filtered transactions
  double get filteredTotalSpent {
    return filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Get breakdown of spending by category (for chart / lists)
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var tx in _transactions) {
      breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
    }
    return breakdown;
  }

  // Get breakdown of filtered spending by category
  Map<String, double> get filteredCategoryBreakdown {
    final Map<String, double> breakdown = {};
    for (var tx in filteredTransactions) {
      breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
    }
    return breakdown;
  }

  // Add a new transaction
  void addTransaction(
    double amount,
    String category,
    String note,
    DateTime date,
    bool isCustom,
  ) {
    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      isCustomCategory: isCustom,
      date: date,
      note: note,
    );
    _transactions.add(newTx);
    notifyListeners();
    _saveTransactions();
  }

  // Delete a transaction
  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
    _saveTransactions();
  }

  // Clear all transactions to start a new budget
  Future<void> clearAllTransactions() async {
    _transactions.clear();
    notifyListeners();
    await _saveTransactions();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategoryFilter = null;
    _selectedDateRangeFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Filter setters
  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _selectedDateRangeFilter = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
