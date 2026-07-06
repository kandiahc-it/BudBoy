import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budboy/main.dart';
import 'package:budboy/providers/budget_provider.dart';
import 'package:budboy/screens/dashboard_screen.dart';

void main() {
  setUp(() {
    // Set up mock values for SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BudBoy app renders dashboard and initial state', (WidgetTester tester) async {
    // Set a larger viewport size so all elements fit on screen without being clipped or offscreen
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen renders initially with its logo
    expect(find.byIcon(Icons.query_stats_rounded), findsOneWidget);

    // Advance virtual time to allow the typing animation and the 2.5-second minimum delay to complete
    await tester.pump(const Duration(milliseconds: 3000));
    // Settle transition animation
    await tester.pumpAndSettle();

    // Verify that we successfully transitioned to the Dashboard Screen and the title 'BudBoy' exists
    expect(find.text('BudBoy'), findsOneWidget);

    // Verify that the total spend shows $0.00 initially
    expect(find.text('\$0.00'), findsWidgets); // Will find in SummaryCard and custom chart

    // Verify that the empty state illustration text is rendered
    expect(find.text('No spends logged'), findsOneWidget);

    // Verify that the Log Spend FAB exists
    expect(find.text('Log Spend'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('BudBoy app bottom navigation tab switches views', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetProvider(),
        child: const MyApp(),
      ),
    );

    // Bypass splash screen
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify initially on Home tab (BudBoy title visible, Search bar not visible)
    expect(find.text('BudBoy'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    // Tap on Transactions tab button
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Verify we are now on Transactions tab (Spends History title visible, Search bar is visible)
    expect(find.text('Spends History'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Tap on Home tab button
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Verify we are back on Home tab
    expect(find.text('BudBoy'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('BudBoy app Reset Budget works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Mock initial SharedPreferences with one transaction
    SharedPreferences.setMockInitialValues({
      'budboy_transactions': '[{"id":"tx-1","amount":15.0,"category":"Food","isCustomCategory":false,"date":"2026-05-15T12:00:00.000","note":"Lunch"}]',
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetProvider(),
        child: const MyApp(),
      ),
    );

    // Bypass splash screen
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify transaction loaded ($15.00 total spend showing)
    expect(find.text('\$15.00'), findsWidgets);
    expect(find.text('No spends logged'), findsNothing);

    // Reset button should be visible since transactions > 0
    expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

    // Tap reset button to open dialog
    await tester.tap(find.byIcon(Icons.restart_alt_rounded));
    await tester.pumpAndSettle();

    // Dialog should render
    expect(find.text('Reset Budget?'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Tap Reset to confirm deletion
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Dialog closes, transaction count resets, empty state shows
    expect(find.text('Reset Budget?'), findsNothing);
    expect(find.text('No spends logged'), findsOneWidget);
    expect(find.text('\$0.00'), findsWidgets);
  });

  testWidgets('BudBoy app Category focus and Monthly spends navigation works', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Mock initial SharedPreferences with two transactions in different categories and months
    SharedPreferences.setMockInitialValues({
      'budboy_transactions': '['
          '{"id":"tx-1","amount":25.0,"category":"Food","isCustomCategory":false,"date":"2026-05-15T12:00:00.000","note":"Lunch"},'
          '{"id":"tx-2","amount":35.0,"category":"Transport","isCustomCategory":false,"date":"2026-06-10T12:00:00.000","note":"Gas"}'
          ']',
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BudgetProvider(),
        child: const MyApp(),
      ),
    );

    // Bypass splash screen
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify both items loaded: Total spent $60.00 showing
    expect(find.text('\$60.00'), findsWidgets);

    // Category Focus Showcase: tap 'Food' selector card
    await tester.tap(find.text('Food').first);
    await tester.pumpAndSettle();

    // Verify total spent updates to $25.00 (the Food transaction amount)
    expect(find.text('\$25.00'), findsWidgets);
    expect(find.text('\$60.00'), findsNothing);

    // Toggle 'Food' off by tapping again
    await tester.tap(find.text('Food').first);
    await tester.pumpAndSettle();

    // Verify total spent updates back to $60.00
    expect(find.text('\$60.00'), findsWidgets);

    // Monthly Spend: Tap on 'May 2026' card
    await tester.tap(find.text('May 2026'));
    await tester.pumpAndSettle();

    // Verify it switched tabs to Transactions (Spends History title visible, search bar visible)
    expect(find.text('Spends History'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify filtered total is $25.00 (the May transaction subtotal)
    expect(find.text('Filtered Total: \$25.00'), findsOneWidget);
  });
}
