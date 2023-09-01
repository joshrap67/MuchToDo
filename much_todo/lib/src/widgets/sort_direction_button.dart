import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/enums.dart';

class SortDirectionButton extends StatefulWidget {
  final SortDirection sortDirection;
  final ValueChanged<SortDirection> onChange;

  const SortDirectionButton({super.key, required this.sortDirection, required this.onChange});

  @override
  State<SortDirectionButton> createState() => _SortDirectionButtonState();
}

class _SortDirectionButtonState extends State<SortDirectionButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.sortDirection == SortDirection.descending
          ? const Icon(Icons.arrow_downward_sharp)
          : const Icon(Icons.arrow_upward_sharp),
      tooltip: widget.sortDirection == SortDirection.descending ? 'Descending' : 'Ascending',
      onPressed: () {
        if (widget.sortDirection == SortDirection.descending) {
          widget.onChange(SortDirection.ascending);
        } else {
          widget.onChange(SortDirection.descending);
        }
        setState(() {});
      },
    );
  }
}
