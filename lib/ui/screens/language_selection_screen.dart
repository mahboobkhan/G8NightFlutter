import 'package:flutter/material.dart';
import 'package:g8night/core/locale/locale_controller.dart';
import 'package:g8night/ui/widgets/gradient_background.dart';
import 'package:g8night/core/localization/l.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? _selected;

  List<_LangOption> _options(BuildContext context) {
    return <_LangOption>[
      _LangOption(locale: const Locale('en', 'US'), label: L.t('englishUS')),
      _LangOption(locale: const Locale('en', 'GB'), label: L.t('englishUK')),
      _LangOption(locale: const Locale('de'), label: L.t('german')),
      _LangOption(locale: const Locale('hi'), label: L.t('hindi')),
      _LangOption(locale: const Locale('ru'), label: L.t('russian')),
      _LangOption(locale: const Locale('ar'), label: L.t('arabic')),
    ];
  }

  Future<void> _apply() async {
    final Locale? choice = _selected;
    if (choice == null) return;
    await LocaleController.instance.setLocale(choice);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final String title = L.t('languageSelectTitle');
    final List<_LangOption> items = _options(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(title),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final _LangOption opt = items[index];
                    final bool selected = _selected == opt.locale;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(opt.label),
                      onSelected: (_) => setState(() => _selected = opt.locale),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: items.length,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                  child: Text(L.t('continueBtn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  final Locale locale;
  final String label;
  const _LangOption({required this.locale, required this.label});
}


