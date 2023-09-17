import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  final AsyncCallback onSubmit;
  final Icon icon;
  final String label;

  const LoadingButton({super.key, this.label = 'SAVE', this.icon = const Icon(Icons.save), required this.onSubmit});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        disabledBackgroundColor: Theme.of(context).colorScheme.primary,
        disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      icon: _isLoading
          ? Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 3,
              ),
            )
          : widget.icon,
      label: Text(widget.label),
    );
  }

  Future<void> onSubmit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onSubmit();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
