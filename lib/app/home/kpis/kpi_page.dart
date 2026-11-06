import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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

import 'package:provider/provider.dart';
import '../../services/database.dart';
import 'kpi_models.dart';
import 'kpi_service.dart';
import 'pdf/kpi_report_pdf.dart';
import 'pdf/kpi_report_preview.dart';

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

  late String _selectedFilterId;
  late List<FilterChipItem> _filterItems;

  ParticipantesKpiData? _participantesData;
  bool _isLoadingParticipantes = false;
  RecursosKpiData? _recursosData;
  bool _isLoadingRecursos = false;
  KpiService? _kpiService;

  bool _isResumenExpanded = true;
  bool _isDemograficoExpanded = true;
  bool _isEspecialesExpanded = true;
  bool _isResultadosExpanded = true;
  bool _isRecursosExpanded = true;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initFilters();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text != _searchQuery) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  void _initFilters() {
    final entityName = widget.socialEntity.name.trim();
    final isAllowedGlobal = entityName.toLowerCase() == 'entidad prueba' ||
        entityName.toLowerCase() == 'sic4change';

    final List<FilterChipItem> items = [];

    // 1. Global (solo visible para "Entidad Prueba" y "SIC4Change")
    if (isAllowedGlobal) {
      items.add(const FilterChipItem(id: 'global', label: 'Global'));
    }

    // 2. Nombre de la entidad actual
    final entityFilterId = widget.socialEntity.socialEntityId ?? 'entity';
    items.add(
      FilterChipItem(
        id: entityFilterId,
        label: entityName.isNotEmpty ? entityName : 'Mi Entidad',
      ),
    );

    // 3. Subsidios
    items.add(
      const FilterChipItem(
        id: '529775',
        label: 'Acompañamiento y tecnología',
        prefix: '529775_',
      ),
    );
    items.add(
      const FilterChipItem(
        id: 'seimlab',
        label: 'SEIMLAB',
        prefix: '1/MAC/4/7.2/0080_',
      ),
    );
    items.add(
      const FilterChipItem(
        id: '529760',
        label: 'Empleando sueños',
        prefix: '529760_',
      ),
    );

    _filterItems = items;
    // Por defecto se muestra la entidad actual, aunque "Global" esté disponible
    _selectedFilterId = entityFilterId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_kpiService == null) {
      final database = Provider.of<Database>(context, listen: false);
      _kpiService = KpiService(database);
      _loadData();
      _loadRecursos();
    }
  }

  /// Los recursos no dependen del filtro seleccionado: se cargan una vez.
  Future<void> _loadRecursos() async {
    if (_kpiService == null) return;
    setState(() {
      _isLoadingRecursos = true;
    });

    try {
      final data = await _kpiService!.loadRecursosKpi();
      if (mounted) {
        setState(() {
          _recursosData = data;
          _isLoadingRecursos = false;
        });
      }
    } catch (e, stack) {
      print('Error cargando KPIs de recursos: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoadingRecursos = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (_kpiService == null) return;
    setState(() {
      _isLoadingParticipantes = true;
    });

    try {
      final data = await _kpiService!.loadParticipantesKpi(
        filterId: _selectedFilterId,
        currentSocialEntityId: widget.socialEntity.socialEntityId ?? '',
      );
      if (mounted) {
        setState(() {
          _participantesData = data;
          _isLoadingParticipantes = false;
        });
      }
    } catch (e, stack) {
      print('Error cargando KPIs: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoadingParticipantes = false;
        });
      }
    }
  }

  void _onFilterChanged(String id) {
    if (_selectedFilterId != id) {
      setState(() {
        _selectedFilterId = id;
      });
      _loadData();
    }
  }

  bool get _hasSearchResults =>
      ResumenGeneralSection.hasMatches(_searchQuery) ||
      DesgloseDemograficoSection.hasMatches(_searchQuery) ||
      CategoriasEspecialesSection.hasMatches(_searchQuery) ||
      IndicadoresResultadosSection.hasMatches(_searchQuery) ||
      RecursosSection.hasMatches(_searchQuery);

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

  /// Abre la previsualización en PDF con los datos de la vista seleccionada
  /// en el momento de pulsar el botón.
  void _downloadReport() {
    if (_isLoadingParticipantes || _isLoadingRecursos) {
      Fluttertoast.showToast(
        msg: 'Espera a que terminen de cargarse los indicadores',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: KpiColors.primaryDark,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    final filterLabel = _filterItems
            .where((f) => f.id == _selectedFilterId)
            .map((f) => f.label)
            .firstOrNull ??
        '';

    final filterId = _selectedFilterId;
    final kpiService = _kpiService!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KpiReportPreview(
          loadParticipantes: () => kpiService.loadParticipantesListado(
            filterId: filterId,
            currentSocialEntityId: widget.socialEntity.socialEntityId ?? '',
          ),
          data: KpiReportData(
            filterId: _selectedFilterId,
            filterLabel: filterLabel,
            generatedAt: DateTime.now(),
            participantes: _participantesData,
            recursos: _recursosData,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Contenedor general con esquinas redondeadas, como en el diseño
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Scaffold(
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
                      onFilterChanged: _onFilterChanged,
                      filterItems: _filterItems,
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
                    if (ResumenGeneralSection.hasMatches(_searchQuery)) ...[
                      ResumenGeneralSection(
                        searchQuery: _searchQuery,
                        isExpanded: _isResumenExpanded,
                        onToggle: () {
                          setState(() {
                            _isResumenExpanded = !_isResumenExpanded;
                          });
                        },
                        participantesData: _participantesData,
                        isLoadingParticipantes: _isLoadingParticipantes,
                      ),
                      const SizedBox(height: 36),
                    ],

                    // Sección 2: Desglose Demográfico
                    if (DesgloseDemograficoSection.hasMatches(
                        _searchQuery)) ...[
                      DesgloseDemograficoSection(
                        searchQuery: _searchQuery,
                        isExpanded: _isDemograficoExpanded,
                        onToggle: () {
                          setState(() {
                            _isDemograficoExpanded = !_isDemograficoExpanded;
                          });
                        },
                        users: _participantesData?.users,
                        nivelesCine:
                            _participantesData?.nivelesCine ?? const [],
                        nivelesEstudios:
                            _participantesData?.nivelesEstudios ?? const [],
                        nivelesSinEspecificar:
                            _participantesData?.nivelesSinEspecificar ?? 0,
                        nivelCinePorUsuario:
                            _participantesData?.nivelCinePorUsuario ?? const {},
                        nivelEstudiosPorUsuario:
                            _participantesData?.nivelEstudiosPorUsuario ??
                                const {},
                        nacionalidades:
                            _participantesData?.nacionalidades ?? const [],
                        nacionalidadSinEspecificar:
                            _participantesData?.nacionalidadSinEspecificar ?? 0,
                        discapacidad:
                            _participantesData?.discapacidad ?? const [],
                        totalConInformeInicialCompleto: _participantesData
                                ?.totalConInformeInicialCompleto ??
                            0,
                        discapacidadPorUsuario:
                            _participantesData?.discapacidadPorUsuario ??
                                const {},
                        isLoading: _isLoadingParticipantes,
                      ),
                      const SizedBox(height: 36),
                    ],

                    // Sección 3: Categorías Especiales
                    if (CategoriasEspecialesSection.hasMatches(
                        _searchQuery)) ...[
                      CategoriasEspecialesSection(
                        searchQuery: _searchQuery,
                        isExpanded: _isEspecialesExpanded,
                        onToggle: () {
                          setState(() {
                            _isEspecialesExpanded = !_isEspecialesExpanded;
                          });
                        },
                        condicionesSobrevenidas:
                            _participantesData?.condicionesSobrevenidas ??
                                const [],
                        situacionAdministrativa:
                            _participantesData?.situacionAdministrativa ??
                                const [],
                        totalConInformeInicialCompleto: _participantesData
                                ?.totalConInformeInicialCompleto ??
                            0,
                        competenciasReconocidas:
                            _participantesData?.competenciasReconocidas ??
                                const [],
                        competenciasPorArea:
                            _participantesData?.competenciasPorArea ?? const [],
                        competenciasPorCategoria:
                            _participantesData?.competenciasPorCategoria ??
                                const [],
                        isLoading: _isLoadingParticipantes,
                      ),
                      const SizedBox(height: 36),
                    ],

                    // Sección 4: Indicadores de Resultados
                    if (IndicadoresResultadosSection.hasMatches(
                        _searchQuery)) ...[
                      IndicadoresResultadosSection(
                        searchQuery: _searchQuery,
                        isExpanded: _isResultadosExpanded,
                        onToggle: () {
                          setState(() {
                            _isResultadosExpanded = !_isResultadosExpanded;
                          });
                        },
                        indicadoresClave:
                            _participantesData?.indicadoresClave ?? const [],
                        recorridoResultados:
                            _participantesData?.recorridoResultados ?? const [],
                        resultadosPorSector:
                            _participantesData?.resultadosPorSector ?? const [],
                        isLoading: _isLoadingParticipantes,
                      ),
                      const SizedBox(height: 36),
                    ],

                    // Sección 5: Recursos
                    if (RecursosSection.hasMatches(_searchQuery)) ...[
                      RecursosSection(
                        searchQuery: _searchQuery,
                        isExpanded: _isRecursosExpanded,
                        onToggle: () {
                          setState(() {
                            _isRecursosExpanded = !_isRecursosExpanded;
                          });
                        },
                        data: _recursosData,
                        isLoading: _isLoadingRecursos,
                      ),
                      const SizedBox(height: 36),
                    ],
                    if (!_hasSearchResults)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No hay indicadores que coincidan con "${_searchQuery.trim()}"',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: KpiColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
