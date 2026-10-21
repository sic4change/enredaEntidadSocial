import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/socialEntity.dart';
import '../../models/userEnreda.dart';
import 'kpi_colors.dart';
import 'widgets/kpi_header.dart';
import 'widgets/section_navigation.dart';
import 'widgets/resumen_general_section.dart';
import 'widgets/desglose_demografico_section.dart';
import 'widgets/categorias_especiales_section.dart';
import 'widgets/indicadores_resultados_section.dart';
import 'widgets/recursos_section.dart';

class KpiPage extends StatefulWidget {
  final SocialEntity socialEntity;
  final UserEnreda? user;

  const KpiPage({
    Key? key,
    required this.socialEntity,
    this.user,
  }) : super(key: key);

  @override
  State<KpiPage> createState() => _KpiPageState();
}

class _KpiPageState extends State<KpiPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilterId = 'sic4change';

  bool _isResumenExpanded = true;
  bool _isDemograficoExpanded = true;
  bool _isEspecialesExpanded = true;
  bool _isResultadosExpanded = true;
  bool _isRecursosExpanded = true;

  bool get _allExpanded =>
      _isResumenExpanded &&
      _isDemograficoExpanded &&
      _isEspecialesExpanded &&
      _isResultadosExpanded &&
      _isRecursosExpanded;

  void _expandAll() {
    setState(() {
      _isResumenExpanded = true;
      _isDemograficoExpanded = true;
      _isEspecialesExpanded = true;
      _isResultadosExpanded = true;
      _isRecursosExpanded = true;
    });
  }

  void _collapseAll() {
    setState(() {
      _isResumenExpanded = false;
      _isDemograficoExpanded = false;
      _isEspecialesExpanded = false;
      _isResultadosExpanded = false;
      _isRecursosExpanded = false;
    });
  }

  void _downloadReport() {
    Fluttertoast.showToast(
      msg: 'Generando informe de indicadores en PDF...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: KpiColors.primaryDark,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KpiColors.pageBackground,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera y Filtros
                  KpiHeader(
                    selectedFilterId: _selectedFilterId,
                    onFilterChanged: (id) {
                      setState(() {
                        _selectedFilterId = id;
                      });
                    },
                    searchController: _searchController,
                    onDownloadReport: _downloadReport,
                  ),
                  const SizedBox(height: 28),

                  // Navegación de secciones (Desplegar / Plegar todo)
                  SectionNavigation(
                    allExpanded: _allExpanded,
                    onExpandAll: _expandAll,
                    onCollapseAll: _collapseAll,
                  ),
                  const SizedBox(height: 24),

                  // Sección 1: Resumen General
                  ResumenGeneralSection(
                    isExpanded: _isResumenExpanded,
                    onToggle: () {
                      setState(() {
                        _isResumenExpanded = !_isResumenExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Sección 2: Desglose Demográfico
                  DesgloseDemograficoSection(
                    isExpanded: _isDemograficoExpanded,
                    onToggle: () {
                      setState(() {
                        _isDemograficoExpanded = !_isDemograficoExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Sección 3: Categorías Especiales
                  CategoriasEspecialesSection(
                    isExpanded: _isEspecialesExpanded,
                    onToggle: () {
                      setState(() {
                        _isEspecialesExpanded = !_isEspecialesExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Sección 4: Indicadores de Resultados
                  IndicadoresResultadosSection(
                    isExpanded: _isResultadosExpanded,
                    onToggle: () {
                      setState(() {
                        _isResultadosExpanded = !_isResultadosExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Sección 5: Recursos
                  RecursosSection(
                    isExpanded: _isRecursosExpanded,
                    onToggle: () {
                      setState(() {
                        _isRecursosExpanded = !_isRecursosExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
