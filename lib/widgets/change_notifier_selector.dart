// import 'package:collection/collection.dart';
// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';

// /// Like classic [Selector] but uses [T] value in [builder] not [selector] value
// class ChangeNotifierSelector<T, S> extends StatefulWidget {
//   const ChangeNotifierSelector({
//     required this.selector,
//     required this.builder,
//     super.key,
//   });

//   final S Function(T value) selector;
//   final Widget Function(BuildContext context, T value) builder;

//   @override
//   // ignore: library_private_types_in_public_api
//   _ChangeNotifierSelectorState<T, S> createState() =>
//       _ChangeNotifierSelectorState<T, S>();
// }

// class _ChangeNotifierSelectorState<T, S>
//     extends State<ChangeNotifierSelector<T, S>> {
//   S? value;
//   Widget? cache;
//   Widget? oldWidget;

//   @override
//   Widget build(BuildContext context) {
//     final providerValue = Provider.of<T>(context);
//     final selected = widget.selector(providerValue);

//     final shouldInvalidateCache = oldWidget != widget ||
//         !const DeepCollectionEquality().equals(value, selected);

//     if (shouldInvalidateCache) {
//       value = selected;
//       oldWidget = widget;
//       cache = widget.builder(context, providerValue);
//     }

//     // ignore: avoid-non-null-assertion
//     return cache!;
//   }
// }
