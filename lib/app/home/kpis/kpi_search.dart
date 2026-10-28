import 'package:flutter/material.dart';
import 'widgets/section_header.dart';

/// Normaliza un texto para la búsqueda: minúsculas y sin tildes.
String normalizeKpiSearch(String raw) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final ch in raw.trim().toLowerCase().split('')) {
    final idx = from.indexOf(ch);
    buffer.write(idx >= 0 ? to[idx] : ch);
  }
  return buffer.toString();
}

/// Títulos de las tarjetas de una sección que coinciden con [query].
/// Con la búsqueda vacía, o si coincide el título de la sección, se devuelven
/// todas. [aliases] permite buscar una tarjeta por textos que muestra dentro
/// (p. ej. los indicadores de la tarjeta "Indicadores clave").
List<String> kpiMatchingCards(
  String query,
  String sectionTitle,
  List<String> cardTitles, {
  Map<String, List<String>> aliases = const {},
}) {
  final q = normalizeKpiSearch(query);
  if (q.isEmpty || normalizeKpiSearch(sectionTitle).contains(q))
    return cardTitles;
  return cardTitles.where((title) {
    final texts = [title, ...?aliases[title]];
    return texts.any((t) => normalizeKpiSearch(t).contains(q));
  }).toList();
}

/// Resultado de búsqueda de una sección: cabecera + tarjetas coincidentes
/// apiladas a ancho completo.
class KpiSearchResults extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> cards;
  final VoidCallback onToggle;

  const KpiSearchResults({
    Key? key,
    required this.sectionTitle,
    required this.cards,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: sectionTitle,
          cardCount: cards.length,
          isExpanded: true,
          onToggle: onToggle,
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          cards[i],
        ],
      ],
    );
  }
}
