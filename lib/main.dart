import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PageWidget(),
    ));

class CanalWidget {
  static const _canal = MethodChannel('widget/maj');

  static Future<int> mettreAJour({
    required double valeur,
    String? titre,
    String? unite,
    double? seuil,
  }) async {
    final n = await _canal.invokeMethod<int>('mettreAJour', {
      'valeur': valeur,
      'titre': titre,
      'unite': unite,
      'seuil': seuil,
    });
    return n ?? 0;
  }

  static Future<int> nombreWidgets() async =>
      await _canal.invokeMethod<int>('nombreWidgets') ?? 0;

  static Future<bool> epingler() async =>
      await _canal.invokeMethod<bool>('epingler') ?? false;
}

class PageWidget extends StatefulWidget {
  const PageWidget({super.key});

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  double _valeur = 34;
  double _seuil = 38;
  int _nbWidgets = 0;
  bool _chargement = false;

  @override
  void initState() {
    super.initState();
    _compter();
  }

  Future<void> _compter() async {
    try {
      final n = await CanalWidget.nombreWidgets();
      if (mounted) setState(() => _nbWidgets = n);
    } on PlatformException catch (e) {
      _message('Erreur : ${e.message}');
    }
  }

  void _message(String texte) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  Future<void> _envoyer() async {
    setState(() => _chargement = true);
    try {
      final n = await CanalWidget.mettreAJour(
        titre: 'Ruche · température',
        valeur: _valeur,
        unite: '°C',
        seuil: _seuil,
      );

      if (!mounted) return;
      setState(() => _nbWidgets = n);

      _message(n == 0
          ? 'Aucun widget sur l’écran d’accueil'
          : 'Envoyé à $n widget(s)');
    } on PlatformException catch (e) {
      _message('Erreur : ${e.message}');
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _epingler() async {
    try {
      final ok = await CanalWidget.epingler();
      if (!mounted) return;

      if (ok) {
        _message('Demande d’ajout du widget envoyée');
      } else {
        _message('Ajout non disponible. Ajoute le widget depuis l’écran d’accueil.');
      }

      await _compter();
    } on PlatformException catch (e) {
      _message('Erreur : ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrôle du widget'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _compter,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.widgets, size: 32),
              title: const Text('Widgets installés'),
              subtitle: Text('Nombre : $_nbWidgets'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _epingler,
            icon: const Icon(Icons.add_to_home_screen),
            label: const Text('Ajouter le widget'),
          ),
          const SizedBox(height: 28),
          Text(
            'Température : ${_valeur.toStringAsFixed(1)} °C',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Slider(
            value: _valeur,
            min: 20,
            max: 50,
            divisions: 60,
            label: '${_valeur.toStringAsFixed(1)} °C',
            onChanged: (v) => setState(() => _valeur = v),
          ),
          const SizedBox(height: 20),
          Text(
            'Seuil d’alerte : ${_seuil.toStringAsFixed(1)} °C',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _seuil,
            min: 20,
            max: 50,
            divisions: 30,
            label: '${_seuil.toStringAsFixed(1)} °C',
            onChanged: (v) => setState(() => _seuil = v),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _chargement ? null : _envoyer,
            icon: const Icon(Icons.send),
            label: Text(_chargement ? 'Envoi...' : 'Envoyer au widget'),
          ),
        ],
      ),
    );
  }
}
