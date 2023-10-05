// import 'package:flentoapp/data/models/card_management/card_management_model.dart';
// import 'package:flentoapp/res/colors/cr_colors.dart';
// import 'package:flentoapp/widgets/slidable_list_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// typedef TapCardCallback = void Function(CardManagementModel card);
// typedef DeleteCardCallback = void Function(
//   CardManagementModel card,
//   SlidableController? controller,
// );

// class CardItem extends StatelessWidget {
//   const CardItem({
//     required this.card,
//     this.onDelete,
//     this.onTap,
//     super.key,
//   });

//   final CardManagementModel card;
//   final TapCardCallback? onTap;
//   final DeleteCardCallback? onDelete;

//   @override
//   Widget build(BuildContext context) {
//     return SlidableListTile(
//       actionColor: CRColors.wRed,
//       actionIcon: Icons.delete,
//       title: card.getLast4PresentString(),
//       trailingIcon: card.isDefault ? const Icon(Icons.check) : null,
//       onTap: () => onTap?.call(card),
//       onActionTap: _onDelete,
//     );
//   }

//   void _onDelete(context) {
//     final controller = Slidable.of(context);
//     onDelete?.call(card, controller);
//   }
// }
