import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/widgets/profile_setup_cards.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class EditConnectionOption extends ConsumerStatefulWidget {
  const EditConnectionOption({
    super.key,
    required this.onPress,
    this.initialConnectionOption,
  });

  final Function(List<String>) onPress;
  final List<String>? initialConnectionOption;

  @override
  ConsumerState<EditConnectionOption> createState() =>
      _EditConnectionOptionState();
}

class _EditConnectionOptionState extends ConsumerState<EditConnectionOption> {
  List<String> _selectedOption = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialConnectionOption != null) {
      _selectedOption = List.from(widget.initialConnectionOption!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metalProps = ref.watch(metalPropertiesProvider);

    return SizedBox(
      height: 600,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const Gap(15),
            const TextView(
              text: "Edit Connection Option",
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 12 / 10,
                ),
                itemCount: metalProps.data!.lookingFor!.length,
                itemBuilder: (BuildContext context, int index) {
                  final model = metalProps.data!.lookingFor![index];
                  return ConnectionOptionsCard(
                    model: model,
                    onTap: () => updateOption(model.title!),
                    selected: _selectedOption.contains(model.title),
                  );
                },
              ),
            ),
            BaseButton(
              buttonText: "Save",
              onPressed: () {
                widget.onPress(_selectedOption);
                Navigator.pop(context);
              },
            ),
            const Gap(23),
          ],
        ),
      ),
    );
  }

  void updateOption(String item) {
    setState(() {
      if (_selectedOption.contains(item)) {
        _selectedOption.remove(item);
      } else if (_selectedOption.length < 2) {
        _selectedOption.add(item);
      }
    });
  }
}

