import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../settings/controllers/settings_controller.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  double price = 399900;
  double depositPercent = 10;
  double rate = 12.5;
  int termMonths = 72;
  double balloonPercent = 20;
  double fuelPrice = 23.5;
  double litresPer100km = 8.1;
  double hybridLitresPer100km = 5.2;
  double kmPerMonth = 1200;
  bool _rateInitialised = false;

  final formatter = NumberFormat.currency(symbol: 'R');

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    settings.whenData((value) {
      if (!_rateInitialised) {
        rate = value.defaultInterestRate;
        _rateInitialised = true;
      }
    });

    final instalment = _calculateMonthlyPayment();
    final runningCost = _calculateRunningCost(litresPer100km);
    final hybridCost = _calculateRunningCost(hybridLitresPer100km);

    return Scaffold(
      appBar: AppBar(title: const Text('Finance calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NumberSlider(
            label: 'Price',
            value: price,
            min: 200000,
            max: 800000,
            step: 1000,
            onChanged: (value) => setState(() => price = value),
            formatter: formatter,
          ),
          _NumberSlider(
            label: 'Deposit %',
            value: depositPercent,
            min: 0,
            max: 40,
            step: 1,
            onChanged: (value) => setState(() => depositPercent = value),
          ),
          _NumberSlider(
            label: 'Rate % (APR)',
            value: rate,
            min: 5,
            max: 18,
            step: 0.1,
            onChanged: (value) => setState(() => rate = value),
          ),
          _NumberSlider(
            label: 'Term (months)',
            value: termMonths.toDouble(),
            min: 12,
            max: 84,
            step: 12,
            onChanged: (value) => setState(() => termMonths = value.round()),
          ),
          _NumberSlider(
            label: 'Balloon %',
            value: balloonPercent,
            min: 0,
            max: 40,
            step: 1,
            onChanged: (value) => setState(() => balloonPercent = value),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated monthly instalment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    formatter.format(instalment),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Running cost per month: ${formatter.format(runningCost)} (petrol) vs ${formatter.format(hybridCost)} (hybrid)',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final summary = _buildSummary(instalment, runningCost, hybridCost);
                      _shareSummary(context, summary);
                    },
                    icon: const Icon(Icons.whatsapp),
                    label: const Text('Insert into chat'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Running cost assumptions', style: Theme.of(context).textTheme.titleMedium),
          _NumberSlider(
            label: 'Fuel price (R/l)',
            value: fuelPrice,
            min: 15,
            max: 35,
            step: 0.5,
            onChanged: (value) => setState(() => fuelPrice = value),
          ),
          _NumberSlider(
            label: 'Litres/100km',
            value: litresPer100km,
            min: 5,
            max: 12,
            step: 0.1,
            onChanged: (value) => setState(() => litresPer100km = value),
          ),
          _NumberSlider(
            label: 'Hybrid litres/100km',
            value: hybridLitresPer100km,
            min: 3,
            max: 8,
            step: 0.1,
            onChanged: (value) => setState(() => hybridLitresPer100km = value),
          ),
          _NumberSlider(
            label: 'Km per month',
            value: kmPerMonth,
            min: 500,
            max: 3000,
            step: 50,
            onChanged: (value) => setState(() => kmPerMonth = value),
          ),
        ],
      ),
    );
  }

  double _calculateMonthlyPayment() {
    final priceAfterDeposit = price * (1 - depositPercent / 100);
    final balloonValue = price * (balloonPercent / 100);
    final principal = priceAfterDeposit - balloonValue;
    final monthlyRate = rate / 12 / 100;
    if (monthlyRate == 0) {
      final basePayment = principal / termMonths;
      final balloonPayment = balloonValue / termMonths;
      return basePayment + balloonPayment;
    }
    final payment =
        (principal * monthlyRate) / (1 - math.pow(1 + monthlyRate, -termMonths));
    final balloonPayment = balloonValue * monthlyRate;
    return payment + balloonPayment;
  }

  double _calculateRunningCost(double litres) {
    return (litres / 100) * kmPerMonth * fuelPrice;
  }

  String _buildSummary(
    double instalment,
    double runningCost,
    double hybridCost,
  ) {
    return 'Estimate: ${formatter.format(instalment)} p/m over $termMonths months. Petrol running cost ${formatter.format(runningCost)} vs Hybrid ${formatter.format(hybridCost)}. Subject to bank approval.';
  }

  void _shareSummary(BuildContext context, String summary) {
    Share.share(summary, subject: 'Finance estimate');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estimate shared. Subject to bank approval.')),
    );
  }
}

class _NumberSlider extends StatelessWidget {
  const _NumberSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.formatter,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final NumberFormat? formatter;

  @override
  Widget build(BuildContext context) {
    final display = formatter?.format(value) ?? value.toStringAsFixed(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: $display'),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / step).round(),
              label: display,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
