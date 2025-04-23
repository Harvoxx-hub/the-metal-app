import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String? text;

  const LoadingState({
    Key? key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                text!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
