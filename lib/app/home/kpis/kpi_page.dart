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

import 'package:provider/provider.dart';
import '../../services/database.dart';
import 'kpi_models.dart';
import 'kpi_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initFilters();
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
    items.add(
      FilterChipItem(
        id: widget.socialEntity.socialEntityId ?? 'entity',
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
    // Si la entidad es SIC4Change o Entidad Prueba, preseleccionamos la primera opción o la entidad
    _selectedFilterId = items.first.id;
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
                  ResumenGeneralSection(
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

                  // Sección 2: Desglose Demográfico
                  DesgloseDemograficoSection(
                    isExpanded: _isDemograficoExpanded,
                    onToggle: () {
                      setState(() {
                        _isDemograficoExpanded = !_isDemograficoExpanded;
                      });
                    },
                    users: _participantesData?.users,
                    nivelesCine: _participantesData?.nivelesCine ?? const [],
                    nivelesEstudios: _participantesData?.nivelesEstudios ?? const [],
                    nivelesSinEspecificar: _participantesData?.nivelesSinEspecificar ?? 0,
                    isLoading: _isLoadingParticipantes,
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
                    discapacidad: _participantesData?.discapacidad ?? const [],
                    condicionesSobrevenidas: _participantesData?.condicionesSobrevenidas ?? const [],
                    situacionAdministrativa: _participantesData?.situacionAdministrativa ?? const [],
                    totalConInformeInicialCompleto: _participantesData?.totalConInformeInicialCompleto ?? 0,
                    competenciasReconocidas: _participantesData?.competenciasReconocidas ?? const [],
                    competenciasPorArea: _participantesData?.competenciasPorArea ?? const [],
                    competenciasPorCategoria: _participantesData?.competenciasPorCategoria ?? const [],
                    nacionalidades: _participantesData?.nacionalidades ?? const [],
                    nacionalidadSinEspecificar: _participantesData?.nacionalidadSinEspecificar ?? 0,
                    isLoading: _isLoadingParticipantes,
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
                    indicadoresClave: _participantesData?.indicadoresClave ?? const [],
                    isLoading: _isLoadingParticipantes,
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
                    data: _recursosData,
                    isLoading: _isLoadingRecursos,
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
