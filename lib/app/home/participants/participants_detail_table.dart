import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The detail view from Figma (10921:11038).
///
/// The name column is intentionally outside the horizontal scroll view. This
/// keeps it visible while the remaining columns move and keeps both panes
/// aligned because every row has an explicit height.
class ParticipantsDetailTable extends StatefulWidget {
  const ParticipantsDetailTable({
    super.key,
    required this.users,
    required this.onTapUser,
    this.pageSize = 40,
  });

  final List<UserEnreda> users;
  final ValueChanged<UserEnreda> onTapUser;
  final int pageSize;

  @override
  State<ParticipantsDetailTable> createState() =>
      _ParticipantsDetailTableState();
}

class _ParticipantsDetailTableState extends State<ParticipantsDetailTable> {
  // The bright blue outline visible in the Figma canvas is its selection
  // chrome, not part of the product UI. The actual table uses a quiet border;
  // selected rows carry the teal state treatment below.
  static const _border = Color(0xFFE4E2E2);
  static const _gridLine = Color(0xFFE9E9E9);
  static const _headerBackground = Color(0xFFF7F7F7);
  static const _selectedBackground = Color(0xFFF0FBFA);
  static const _selectedBorder = Color(0xFF53C7C4);
  static const _ink = Color(0xFF1B1C1C);

  // Dimensions follow the wide desktop table in the Figma frame.
  static const _nameWidth = 270.0;
  static const _headerHeight = 48.0;
  static const _rowHeight = 108.0;
  static const _columns = <_TableColumn>[
    _TableColumn('ESTADO ITINERARIO', 190),
    _TableColumn('FECHA DE INSCRIPCIÓN', 175),
    _TableColumn('Nº DOCUMENTO PERSONAL', 205),
    _TableColumn('GÉNERO', 125),
    _TableColumn('FECHA DE NACIMIENTO', 180),
    _TableColumn('EDAD', 95),
    _TableColumn('NACIONALIDAD', 155),
    _TableColumn('SITUACIÓN ADMINISTRATIVA', 225),
    _TableColumn('TELÉFONO', 165),
    _TableColumn('TÉCNICA DE REFERENCIA', 225),
    _TableColumn('RECURSOS SOLICITADOS', 320),
    _TableColumn('PROGRAMA ASIGNADO', 205),
    _TableColumn('OBSERVACIONES', 285),
  ];

  static const _chipColors = [
    Color(0xFF054D5E),
    Color(0xFFFFCB77),
    Color(0xFFA7E4E1),
  ];

  final _horizontalController = ScrollController();
  int _sortCol = 0;
  bool _asc = true;
  int _page = 0;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _selectedUserId = _identity(globals.currentParticipant);
  }

  @override
  void didUpdateWidget(covariant ParticipantsDetailTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users.length != widget.users.length) _page = 0;
    _selectedUserId ??= _identity(globals.currentParticipant);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<UserEnreda>.from(widget.users);
    final comparator = _comparators[_sortCol];
    if (comparator != null) {
      sorted.sort(_asc ? comparator : (a, b) => comparator(b, a));
    }

    final total = sorted.length;
    final pageCount = total == 0 ? 1 : ((total - 1) ~/ widget.pageSize) + 1;
    if (_page >= pageCount) _page = pageCount - 1;
    final pageUsers =
        sorted.skip(_page * widget.pageSize).take(widget.pageSize).toList();
    // Keep a usable scroll viewport on narrow screens without giving up the
    // frozen name column.
    final nameWidth =
        MediaQuery.sizeOf(context).width < 650 ? 196.0 : _nameWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableShell(
          nameColumn: _buildNameColumn(pageUsers, width: nameWidth),
          scrollableColumns: _buildScrollableColumns(context, pageUsers),
          contentHeight: _headerHeight + pageUsers.length * _rowHeight,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              StringConst.tableShowing(pageUsers.length, total),
              style: const TextStyle(color: AppColors.greyTxtAlt, fontSize: 12),
            ),
            const Spacer(),
            _PageArrow(
              icon: Icons.arrow_left,
              enabled: _page > 0,
              onTap: () => setState(() => _page--),
            ),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${_page + 1}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' / $pageCount',
                    style: const TextStyle(
                      color: AppColors.greyTxtAlt,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PageArrow(
              icon: Icons.arrow_right,
              enabled: _page < pageCount - 1,
              onTap: () => setState(() => _page++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameColumn(List<UserEnreda> users, {required double width}) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          _HeaderCell(
            label: StringConst.COL_NOMBRE,
            height: _headerHeight,
            sortable: true,
            sortDirection: _sortDirection(0),
            onTap: () => _sortBy(0),
          ),
          for (final user in users)
            _rowCell(
              selected: _isSelected(user),
              onTap: () => _openParticipant(user),
              child: Row(
                children: [
                  _Avatar(user: user),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fullName(user),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.turquoiseBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollableColumns(BuildContext context, List<UserEnreda> users) {
    final contentWidth =
        _columns.fold<double>(0, (sum, column) => sum + column.width);
    return SizedBox(
      height: _headerHeight + users.length * _rowHeight,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                SizedBox(
                  height: _headerHeight,
                  child: Row(
                    children: [
                      for (var i = 0; i < _columns.length; i++)
                        _HeaderCell(
                          label: _columns[i].label,
                          width: _columns[i].width,
                          height: _headerHeight,
                          sortable: _comparators.containsKey(i + 1),
                          sortDirection: _sortDirection(i + 1),
                          onTap: _comparators.containsKey(i + 1)
                              ? () => _sortBy(i + 1)
                              : null,
                        ),
                    ],
                  ),
                ),
                for (final user in users)
                  _rowCell(
                    selected: _isSelected(user),
                    onTap: () => _select(user),
                    horizontalPadding: 0,
                    child: Row(
                      children: [
                        _dataCell(_itineraryState(user), 190),
                        _dataCell(_date(user.createDate), 175),
                        _dataCell(_orDash(user.dni), 205),
                        _dataCell(_orDash(user.gender), 125),
                        _dataCell(_date(user.birthday), 180),
                        _dataCell(_age(user.birthday), 95),
                        _dataCell(_orDash(user.nationality), 155),
                        _dataCell(StringConst.TABLE_SIN_ESPECIFICAR, 225),
                        _dataCell(_orDash(user.phone), 165),
                        SizedBox(
                          width: 225,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child:
                                _TecnicaCell(assignedById: user.assignedById),
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _resourceChips(user),
                          ),
                        ),
                        _dataCell(_programName(user.programId), 205),
                        SizedBox(
                          width: 285,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: const [
                                Expanded(
                                  child: Text(
                                    StringConst.TABLE_ADD_OBSERVACIONES,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.edit_outlined,
                                    size: 15, color: _ink),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataCell(String value, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _ink, fontSize: 12),
        ),
      ),
    );
  }

  Widget _rowCell({
    required Widget child,
    required bool selected,
    required VoidCallback onTap,
    double horizontalPadding = 12,
  }) {
    return SizedBox(
      height: _rowHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.primary010,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? _selectedBackground : AppColors.white,
              border: Border(
                top: BorderSide(
                  color: selected ? _selectedBorder : _gridLine,
                  width: selected ? 1.5 : 1,
                ),
                bottom: BorderSide(
                  color: selected ? _selectedBorder : _gridLine,
                  width: selected ? 1.5 : 1,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        ),
      ),
    );
  }

  void _select(UserEnreda user) {
    setState(() => _selectedUserId = _identity(user));
    globals.currentParticipant = user;
  }

  void _openParticipant(UserEnreda user) {
    _select(user);
    widget.onTapUser(user);
  }

  bool _isSelected(UserEnreda user) => _identity(user) == _selectedUserId;

  void _sortBy(int column) {
    setState(() {
      if (_sortCol == column) {
        _asc = !_asc;
      } else {
        _sortCol = column;
        _asc = true;
      }
      _page = 0;
    });
  }

  _SortDirection? _sortDirection(int column) {
    if (_sortCol != column) return null;
    return _asc ? _SortDirection.ascending : _SortDirection.descending;
  }

  String _programName(String? programId) {
    if (programId == null || programId.isEmpty) {
      return StringConst.TABLE_SIN_ESPECIFICAR;
    }
    try {
      return LocationCache.instance.programs
          .firstWhere((program) => program.programId == programId)
          .name;
    } catch (_) {
      return StringConst.TABLE_SIN_ESPECIFICAR;
    }
  }

  Widget _resourceChips(UserEnreda user) {
    return StreamBuilder<void>(
      stream: LocationCache.instance.resourceUpdates,
      builder: (context, _) => _buildResourceChips(user),
    );
  }

  Widget _buildResourceChips(UserEnreda user) {
    final ids = user.resources;
    final titles = <String>[];
    for (final id in ids) {
      for (final resource in LocationCache.instance.resources) {
        if (resource.resourceId == id) {
          titles.add(resource.title);
          break;
        }
      }
    }
    if (titles.isEmpty) return const Text('—');

    final visible = titles.take(3).toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visible.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 292),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _chipColors[i % _chipColors.length],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                visible[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: i % _chipColors.length == 0
                      ? Colors.white
                      : AppColors.turquoiseBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        if (titles.length > 3)
          const Text(
            '…',
            style: TextStyle(color: AppColors.turquoiseBlue, fontSize: 16),
          ),
      ],
    );
  }

  static final Map<int, int Function(UserEnreda, UserEnreda)> _comparators = {
    0: (a, b) =>
        _fullName(a).toLowerCase().compareTo(_fullName(b).toLowerCase()),
    1: (a, b) => _itineraryState(a).compareTo(_itineraryState(b)),
    2: (a, b) => _epoch(a.createDate).compareTo(_epoch(b.createDate)),
    4: (a, b) => (a.gender ?? '').compareTo(b.gender ?? ''),
    5: (a, b) => _epoch(a.birthday).compareTo(_epoch(b.birthday)),
    6: (a, b) => _epoch(b.birthday).compareTo(_epoch(a.birthday)),
    7: (a, b) => (a.nationality ?? '').compareTo(b.nationality ?? ''),
    12: (a, b) => (a.programId ?? '').compareTo(b.programId ?? ''),
  };

  static DateTime _epoch(DateTime? date) =>
      date ?? DateTime.fromMillisecondsSinceEpoch(0);

  static String _identity(UserEnreda? user) =>
      user?.userId ?? (user == null ? '' : user.email);

  static String _fullName(UserEnreda user) =>
      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

  static String _itineraryState(UserEnreda user) {
    if (user.closureReportId != null && user.closureReportId!.isNotEmpty) {
      return 'Cierre';
    }
    if (user.startDateItinerary != null) {
      return 'Iniciado (${_date(user.startDateItinerary)})';
    }
    if (user.initialReportId != null && user.initialReportId!.isNotEmpty) {
      return 'En evaluación';
    }
    return StringConst.TABLE_NO_INICIADO;
  }

  static String _orDash(String? value) =>
      value == null || value.trim().isEmpty ? '—' : value.trim();

  static String _date(DateTime? date) =>
      date == null ? '—' : '${date.day}/${date.month}/${date.year}';

  static String _age(DateTime? birthday) {
    if (birthday == null) return '—';
    final now = DateTime.now();
    var age = now.year - birthday.year;
    if (now.month < birthday.month ||
        now.month == birthday.month && now.day < birthday.day) {
      age--;
    }
    return '$age años';
  }
}

class _TableColumn {
  const _TableColumn(this.label, this.width);

  final String label;
  final double width;
}

class _TableShell extends StatelessWidget {
  const _TableShell({
    required this.nameColumn,
    required this.scrollableColumns,
    required this.contentHeight,
  });

  final Widget nameColumn;
  final Widget scrollableColumns;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: _ParticipantsDetailTableState._border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameColumn,
          Container(
            width: 1,
            height: contentHeight,
            color: _ParticipantsDetailTableState._gridLine,
          ),
          Expanded(child: scrollableColumns),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.height,
    required this.sortable,
    required this.sortDirection,
    this.width,
    this.onTap,
  });

  final String label;
  final double height;
  final double? width;
  final bool sortable;
  final _SortDirection? sortDirection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      width: width,
      height: height,
      color: _ParticipantsDetailTableState._headerBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.turquoiseBlue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (sortable)
            Icon(
              sortDirection == _SortDirection.ascending
                  ? Icons.arrow_drop_up
                  : sortDirection == _SortDirection.descending
                      ? Icons.arrow_drop_down
                      : Icons.unfold_more,
              size: 14,
              color: AppColors.turquoiseBlue,
            ),
        ],
      ),
    );
    return onTap == null
        ? cell
        : InkWell(onTap: onTap, hoverColor: AppColors.primary010, child: cell);
  }
}

enum _SortDirection { ascending, descending }

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(
            color: enabled ? AppColors.primaryColor : AppColors.greyBorder,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primaryColor : AppColors.greyBorder,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final UserEnreda user;

  @override
  Widget build(BuildContext context) {
    final photo = user.photo ?? '';
    final initials =
        '${user.firstName?.isNotEmpty == true ? user.firstName![0] : ''}'
                '${user.lastName?.isNotEmpty == true ? user.lastName![0] : ''}'
            .toUpperCase();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: photo.isEmpty ? const Color(0xFFAB1F8C) : AppColors.white,
        border: Border.all(color: AppColors.primary020),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo.isEmpty
          ? Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.turquoiseBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }
}

class _TecnicaCell extends StatelessWidget {
  const _TecnicaCell({required this.assignedById});

  final String? assignedById;

  @override
  Widget build(BuildContext context) {
    if (assignedById == null || assignedById!.isEmpty) {
      return const Text(StringConst.TABLE_SIN_ASIGNAR);
    }
    final database = Provider.of<Database>(context, listen: false);
    return FutureBuilder<UserEnreda?>(
      future: LocationCache.instance.getUser(database, assignedById!),
      builder: (context, snapshot) {
        final technician = snapshot.data;
        if (technician == null) {
          return const Text(StringConst.TABLE_SIN_ASIGNAR);
        }
        final name =
            '${technician.firstName ?? ''} ${technician.lastName ?? ''}'.trim();
        return Text(
          name.isEmpty ? StringConst.TABLE_SIN_ASIGNAR : name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ParticipantsDetailTableState._ink,
            fontSize: 12,
          ),
        );
      },
    );
  }
}
