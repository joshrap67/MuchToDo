import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/utils.dart';

class MoneyInput extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final ValueChanged<double?> onChange;
  final double? amount;
  final bool showClear;
  final Widget? prefixIcon;

  const MoneyInput(
      {super.key,
      this.hintText,
      this.labelText,
      required this.onChange,
      this.amount,
      this.prefixIcon,
      this.showClear = false});

  @override
  State<MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<MoneyInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(symbol: '');
    _controller.text = widget.amount != null ? formatter.format(widget.amount!.toStringAsFixed(2)) : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amount == null) {
      // hack. But if the input is cleared from a parent, the controller will still have old value
      _controller.text = '';
    }
    return TextFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon,
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: _controller.text.isNotEmpty && widget.showClear
            ? IconButton(
                onPressed: () {
                  setState(() {
                    hideKeyboard();
                    _controller.clear();
                    widget.onChange(null);
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
      inputFormatters: [CurrencyTextInputFormatter(locale: 'en', symbol: '', enableNegative: false)],
      keyboardType: TextInputType.number,
      controller: _controller,
      onChanged: (amount) {
        double? estimatedCost = double.tryParse(_controller.text.toString().replaceAll(',', ''));
        widget.onChange(estimatedCost);
      },
    );
  }
}
