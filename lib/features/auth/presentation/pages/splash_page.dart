import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/auth_cubit.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = context.watch<CatalogBloc>().state.catalog.byIds(const [
      'dunes',
      'spirit',
      'neon',
      'orbit',
      'monsoon',
      'sess',
      'signal',
      'moons'
    ]);
    final auth = context.read<AuthCubit>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 40),
            const OneLogo(size: 64),
            const SizedBox(height: 18),
            Text(context.t('splash.tagline'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(context.t('splash.body'),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.ink2, fontSize: 13)),
            Expanded(
              child: ClipRect(
                child: Transform.rotate(
                  angle: -.1,
                  child: Transform.scale(
                    scale: 1.2,
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2 / 3,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 24),
                      children: [for (final i in items) Poster(i.art)],
                    ),
                  ),
                ),
              ),
            ),
            GBtn(context.t('splash.start'), expand: true, onTap: auth.login),
            const SizedBox(height: 10),
            GBtn(context.t('splash.login'),
                expand: true, outline: true, onTap: auth.login),
            const SizedBox(height: 16),
            Text(context.t('splash.partners'),
                style: TextStyle(color: context.ink2, fontSize: 12.5)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final k in const [
                'comcast',
                'xfinity',
                'sky',
                'nbc',
                'peacock'
              ])
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BrandBadge(k, size: 40)),
            ]),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}
