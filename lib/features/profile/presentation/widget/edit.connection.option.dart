import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/countries.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/presentation/widgets/profile_setup_cards.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class EditConnectionOption extends ConsumerStatefulWidget {
  const EditConnectionOption(
      {super.key, required this.onPress, this.initialConnectionOption});

  final Function(List<String>) onPress;
  final List<String>? initialConnectionOption;

  @override
  ConsumerState<EditConnectionOption> createState() =>
      _EditConnectionOptionState();
}

class _EditConnectionOptionState extends ConsumerState<EditConnectionOption> {
  List<String> _seletedOption = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialConnectionOption != null) {
      _seletedOption = widget.initialConnectionOption!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);

    return Container(
      height: 600,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(children: [
          const Gap(15),
          const TextView(
            text: "Edit Connection Option",
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // You can adjust the number of columns here
                crossAxisSpacing: 10.0,

                mainAxisSpacing: 10.0,
                childAspectRatio: 12 / 10,
              ),
              itemCount: metalProps.data!.lookingFor!.length,
              itemBuilder: (BuildContext context, int index) {
                final model = metalProps.data!.lookingFor![index];
                return ConnectionOptionsCard(
                  model: model,
                  onTap: () => updateMetal(model.title!),
                  selected: _seletedOption.contains(model.title),
                );
              },
            ),
          ),
          BaseButton(
              buttonText: "Save",
              onPressed: () {
                widget.onPress(_seletedOption);
                Navigator.pop(context);
              }),
          const Gap(23),
        ]),
      ),
    );
  }

  void updateMetal(String item) {
    setState(() {
      _seletedOption.contains(item)
          ? _seletedOption.remove(item)
          : _seletedOption.length < 2
              ? _seletedOption.add(item)
              : null;
    });
  }
}
