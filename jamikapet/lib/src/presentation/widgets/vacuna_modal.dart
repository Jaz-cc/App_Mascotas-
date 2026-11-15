import 'package:flutter/material.dart';

class VacunaUpdateModal extends StatefulWidget {
  final DateTime? fechaInicial;
  final String estadoInicial;
  final String observacionesIniciales;
  final DateTime? proximaDosisInicial;

  final Future<void> Function(
    DateTime fecha,
    String estado,
    String observaciones,
    DateTime? proximaDosis,
  ) onGuardar;

  const VacunaUpdateModal({
    super.key,
    this.fechaInicial,
    this.estadoInicial = 'No aplicada',
    this.observacionesIniciales = '',
    this.proximaDosisInicial,
    required this.onGuardar,
  });

  static Future<bool?> show(
    BuildContext context, {
    DateTime? fechaInicial,
    String estadoInicial = 'No aplicada',
    String observacionesIniciales = '',
    DateTime? proximaDosisInicial,
    required Future<void> Function(
      DateTime fecha,
      String estado,
      String observaciones,
      DateTime? proximaDosis,
    ) onGuardar,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x990F3D3A),
      builder: (_) => VacunaUpdateModal(
        fechaInicial: fechaInicial,
        estadoInicial: estadoInicial,
        observacionesIniciales: observacionesIniciales,
        proximaDosisInicial: proximaDosisInicial,
        onGuardar: onGuardar,
      ),
    );
  }

  @override
  State<VacunaUpdateModal> createState() => _VacunaUpdateModalState();
}

class _VacunaUpdateModalState extends State<VacunaUpdateModal> {
  // Paleta (misma de las demás pantallas)
  static const Color turquesa = Color(0xFF55C8BD);
  static const Color turquesaOscuro = Color(0xFF1F7A70);
  static const Color verdeMuyClaro = Color(0xFFD1F0EE);
  static const Color campo = Color(0xFFF4FBFA);
  static const Color borde = Color(0xFFCBE5E2);
  static const Color tinta = Color(0xFF16302D);
  static const Color tintaSuave = Color(0xFF5C7A77);

  late DateTime fecha;
  DateTime? proximaDosis;
  late String estado;
  late TextEditingController observacionesController;

  bool guardando = false;
  String? error;

  final List<String> estados = [
    'No aplicada',
    'Aplicada',
    'Próxima dosis',
  ];

  // Color e ícono de cada estado (iguales a los de la pantalla de vacunas)
  static const Map<String, Color> _colorEstado = {
    'No aplicada': Color(0xFFC94F4F),
    'Aplicada': Color(0xFF2E9E5B),
    'Próxima dosis': Color(0xFF2E7BC9),
  };

  static const Map<String, IconData> _iconoEstado = {
    'No aplicada': Icons.error_outline_rounded,
    'Aplicada': Icons.shield_outlined,
    'Próxima dosis': Icons.schedule_rounded,
  };

  @override
  void initState() {
    super.initState();

    fecha = widget.fechaInicial ?? DateTime.now();
    proximaDosis = widget.proximaDosisInicial;

    estado = estados.contains(widget.estadoInicial)
        ? widget.estadoInicial
        : 'No aplicada';

    observacionesController = TextEditingController(
      text: widget.observacionesIniciales,
    );
  }

  @override
  void dispose() {
    observacionesController.dispose();
    super.dispose();
  }

  String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Future<void> seleccionarProximaDosis() async {
    final base = DateTime(fecha.year, fecha.month, fecha.day);
    final minima = base.add(const Duration(days: 1));
    final inicial = proximaDosis != null && proximaDosis!.isAfter(base)
        ? proximaDosis!
        : minima;

    final seleccionada = await _abrirCalendario(
      inicial: inicial,
      primera: minima,
      ayuda: 'Fecha de la próxima dosis',
    );

    if (seleccionada != null && mounted) {
      setState(() {
        proximaDosis = seleccionada;
        error = null;
      });
    }
  }

  Future<DateTime?> _abrirCalendario({
    required DateTime inicial,
    required DateTime primera,
    required String ayuda,
  }) {
    return showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primera,
      lastDate: DateTime(2100),
      helpText: ayuda,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: turquesa,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Seleccionar fecha de la vacuna',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: turquesaOscuro,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null && mounted) {
      setState(() {
        fecha = seleccionada;
        // La próxima dosis siempre va después de la aplicación.
        if (proximaDosis != null && !proximaDosis!.isAfter(fecha)) {
          proximaDosis = null;
        }
        error = null;
      });
    }
  }

  Future<void> guardar() async {
    final aplicada = estado == 'Aplicada';

    if (aplicada &&
        proximaDosis != null &&
        !proximaDosis!.isAfter(fecha)) {
      setState(() {
        error = 'La próxima dosis debe ser posterior a la fecha de aplicación.';
      });
      return;
    }

    setState(() {
      guardando = true;
      error = null;
    });

    try {
      await widget.onGuardar(
        fecha,
        estado,
        observacionesController.text.trim(),
        aplicada ? proximaDosis : null,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'No se pudieron guardar los cambios. '
            'Verifica tu conexión e inténtalo nuevamente.';
        guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Entrada animada: escala + fade
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, valor, child) => Opacity(
        opacity: valor,
        child: Transform.scale(scale: 0.94 + (0.06 * valor), child: child),
      ),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _encabezado(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      _etiqueta(
                        estado == 'Próxima dosis'
                            ? 'Fecha en que toca la vacuna'
                            : 'Fecha de la vacuna',
                      ),
                      const SizedBox(height: 10),
                      _campoFecha(),

                      const SizedBox(height: 24),

                      // Estado
                      _etiqueta('Estado de la vacuna'),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          for (final item in estados) ...[
                            _opcionEstado(item),
                            if (item != estados.last)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),

                      // Próxima dosis (solo si ya se aplicó)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: estado == 'Aplicada'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _etiqueta('Fecha de la próxima dosis'),
                                  const SizedBox(height: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text(
                                      'Opcional. Te enviaremos un recordatorio '
                                      'un día antes y el mismo día.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        color: tintaSuave,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _campoProximaDosis(),
                                ],
                              )
                            : const SizedBox(width: double.infinity),
                      ),

                      const SizedBox(height: 24),

                      // Observaciones
                      _etiqueta('Observaciones'),
                      const SizedBox(height: 10),
                      _campoObservaciones(),

                      // Error
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _botones(),
            ],
          ),
        ),
      ),
    );
  }

  // Próxima dosis
  Widget _campoProximaDosis() {
    final tieneFecha = proximaDosis != null;

    return Material(
      color: tieneFecha ? verdeMuyClaro.withValues(alpha: 0.45) : campo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: guardando ? null : seleccionarProximaDosis,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
          constraints: const BoxConstraints(minHeight: 54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tieneFecha ? turquesaOscuro : borde,
              width: tieneFecha ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: tieneFecha ? turquesaOscuro : tintaSuave,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tieneFecha
                      ? formatearFecha(proximaDosis!)
                      : 'Sin próxima dosis',
                  style: TextStyle(
                    fontSize: tieneFecha ? 16 : 14.5,
                    fontWeight: tieneFecha ? FontWeight.w800 : FontWeight.w500,
                    color: tieneFecha ? tinta : tintaSuave,
                  ),
                ),
              ),
              if (tieneFecha)
                IconButton(
                  tooltip: 'Quitar fecha',
                  visualDensity: VisualDensity.compact,
                  onPressed: guardando
                      ? null
                      : () => setState(() => proximaDosis = null),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: tintaSuave,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: tintaSuave,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Encabezado
  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF8F6), Colors.white],
        ),
        border: Border(bottom: BorderSide(color: borde)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [turquesa, turquesaOscuro],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D1F7A70),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.vaccines_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Actualizar vacuna',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: tinta,
              ),
            ),
          ),
          Material(
            color: verdeMuyClaro,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: guardando ? null : () => Navigator.pop(context, false),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, size: 20, color: tinta),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fecha
  Widget _campoFecha() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: guardando ? null : seleccionarFecha,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: turquesaOscuro, width: 1.4),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: turquesaOscuro,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatearFecha(fecha),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: tinta,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: turquesaOscuro,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Estado (opciones sin palomita)
  Widget _opcionEstado(String item) {
    final activa = estado == item;
    final color = _colorEstado[item] ?? turquesaOscuro;

    return Semantics(
      button: true,
      selected: activa,
      label: item,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: activa
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.78), color],
                )
              : null,
          color: activa ? null : Colors.white,
          border: Border.all(color: activa ? Colors.transparent : borde),
          boxShadow: [
            BoxShadow(
              color: activa
                  ? color.withValues(alpha: 0.35)
                  : const Color(0x0F0F3D3A),
              blurRadius: activa ? 12 : 6,
              offset: Offset(0, activa ? 5 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: guardando
                ? null
                : () => setState(() {
                      estado = item;
                      error = null;
                    }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    _iconoEstado[item],
                    size: 20,
                    color: activa ? Colors.white : color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                        color: activa ? Colors.white : tinta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Observaciones
  Widget _campoObservaciones() {
    OutlineInputBorder bordeCampo(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: ancho),
        );

    return TextField(
      controller: observacionesController,
      enabled: !guardando,
      maxLines: 4,
      maxLength: 500,
      style: const TextStyle(fontSize: 14.5, color: tinta),
      decoration: InputDecoration(
        hintText: 'Escribe alguna observación...',
        hintStyle: const TextStyle(color: tintaSuave, fontSize: 14),
        alignLabelWithHint: true,
        filled: true,
        fillColor: campo,
        counterStyle: const TextStyle(color: tintaSuave, fontSize: 11.5),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 55),
          child: Icon(Icons.notes, color: turquesaOscuro),
        ),
        contentPadding: const EdgeInsets.all(14),
        border: bordeCampo(borde),
        enabledBorder: bordeCampo(borde),
        disabledBorder: bordeCampo(borde),
        focusedBorder: bordeCampo(turquesaOscuro, 1.6),
      ),
      onChanged: (_) {
        if (error != null) {
          setState(() => error = null);
        }
      },
    );
  }

  // Botones
  Widget _botones() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAF4F2))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: guardando ? null : () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: tintaSuave,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: guardando ? 0.75 : 1,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [turquesa, turquesaOscuro],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x551F7A70),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: guardando ? null : guardar,
                    child: Center(
                      child: guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String texto) => Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: turquesa,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: tintaSuave,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
}