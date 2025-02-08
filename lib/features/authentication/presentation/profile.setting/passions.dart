import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/shimmer.loading.dart';

import '../../provider/metal.properties.notifier.dart';
import '../widget/passions.card.dart';

class PassionsPage extends ConsumerStatefulWidget {
  const PassionsPage({super.key});
  static const name = 'passions';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PassionsPageState();
}

class _PassionsPageState extends ConsumerState<PassionsPage> {
  final List<String> _seletedPassion = [];

  @override
  Widget build(BuildContext context) {
    debugPrint('Build was called...');
    final metalProps = ref.watch(metalPropertiesProvider);
    debugPrint('metalProps.isLoading: ${metalProps.isLoading}');
    debugPrint('metalProps.data: ${metalProps.data}');

    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'Passions',
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.flame.path,
                title: "Tell us your passions and what interest you most",
                subtitle: "We could add it your profile!"),
            Stack(
              children: [
                ShimmerLoading(
                    isLoading: metalProps.isLoading,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: SizedBox(
                        height: getDeviceHeight(context) * 0.59,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 16 / 6,
                          ),
                          itemCount: metalProps.data?.passions?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            final model =
                                metalProps.data?.passions?[index] ?? Passion();
                            debugPrint("fetching user model: ${model.title}");
                            return PassionsCard(
                              model: model,
                              onTap: () => updateMetal(model.title!),
                              selected: _seletedPassion.contains(model.title),
                            );
                          },
                        ),
                      ),
                    )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: BaseButton(
                    buttonText: "Next",
                    enabled: _seletedPassion.isNotEmpty,
                    onPressed: _onNextPressed,
                  ),
                )
              ],
            )
          ],
        )));
  }

  void updateMetal(String item) {
    setState(() {
      _seletedPassion.contains(item)
          ? _seletedPassion.remove(item)
          : _seletedPassion.add(item);
    });
  }

  void _onNextPressed() {
    final userData = ref.watch(authProvider).data;
    final updated = userData!.copyWith(passion: _seletedPassion);
    ref.read(updateProfileProvider.notifier).updateUserData(updated);
    Navigator.pushNamed(
      context,
      AppRoutes.aboutYouPage,
    );
  }
}
