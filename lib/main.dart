import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DiscountApp());
}

class DiscountApp extends StatelessWidget {
  const DiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator de reducere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DiscountCalculatorPage(),
    );
  }
}

class DiscountCalculatorPage extends StatefulWidget {
  const DiscountCalculatorPage({super.key});

  @override
  State<DiscountCalculatorPage> createState() => _DiscountCalculatorPageState();
}

class _DiscountCalculatorPageState extends State<DiscountCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _percentController = TextEditingController();

  static const _currencies = ['MDL', 'EUR', 'USD', 'RON'];
  String _currency = _currencies.first;

  double? _discountAmount;
  double? _finalPrice;

  @override
  void dispose() {
    _priceController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String? _validatePrice(String? value) {
    final price = _parse(value ?? '');
    if (price == null) return 'Introduceți un preț valid';
    if (price < 0) return 'Prețul nu poate fi negativ';
    return null;
  }

  String? _validatePercent(String? value) {
    final percent = _parse(value ?? '');
    if (percent == null) return 'Introduceți un procent valid';
    if (percent < 0 || percent > 100) return 'Procentul trebuie să fie între 0 și 100';
    return null;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _discountAmount = null;
        _finalPrice = null;
      });
      return;
    }

    final price = _parse(_priceController.text)!;
    final percent = _parse(_percentController.text)!;
    final discount = price * percent / 100;

    setState(() {
      _discountAmount = discount;
      _finalPrice = price - discount;
    });
  }

  void _reset() {
    _formKey.currentState!.reset();
    _priceController.clear();
    _percentController.clear();
    setState(() {
      _discountAmount = null;
      _finalPrice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator de reducere'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [numberFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Preț inițial',
                    prefixIcon: Icon(Icons.sell_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePrice,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _percentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [numberFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Procentul reducerii',
                    suffixText: '%',
                    prefixIcon: Icon(Icons.percent),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePercent,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Valuta:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _currency,
                      items: _currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _currency = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculează'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Resetează'),
                ),
                const SizedBox(height: 16),
                if (_finalPrice != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valoarea reducerii: ${_discountAmount!.toStringAsFixed(2)} $_currency',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Preț final: ${_finalPrice!.toStringAsFixed(2)} $_currency',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
