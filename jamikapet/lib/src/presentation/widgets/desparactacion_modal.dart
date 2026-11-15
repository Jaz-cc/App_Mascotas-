import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/desparasitacion.dart';
import 'package:jamikapet/src/models/mascota.dart';
import 'package:jamikapet/src/services/desparacitacion_service.dart';

/// Datos validados que devuelve el formulario.
class DesparasitacionFormData {
  final Mascota mascota;
  final ProductoDesparasitante producto;
  final DateTime fechaAplicacion;
  final DateTime proximaDosis;
  final String estado; // 'Aplicada' | 'Pendiente'

  const DesparasitacionFormData({
    required this.mascota,
    required this.producto,
    required this.fechaAplicacion,
    required this.proximaDosis,
    required this.estado,
  });
}

/// Modal para registrar (tratamiento == null) o editar una desparasitación.
///
/// [onSave] se espera con await: el modal muestra el spinner mientras guarda,
/// se cierra solo si termina bien y, si lanza una excepción, muestra el error
/// dentro del mismo modal sin perder lo que el usuario escribió.
class DesparasitacionModal {
  DesparasitacionModal._();

  static Future<void> show(
    BuildContext context, {
    required List<Mascota> mascotas,
    required List<ProductoDesparasitante> productos,
    Mascota? mascotaInicial,
    Desparasitacion? tratamiento,
    required Future<void> Function(DesparasitacionFormData datos) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x990F3D3A),
      builder: (_) => _DesparasitacionDialog(
        mascotas: mascotas,
        productos: productos,
        mascotaInicial: mascotaInicial,
        tratamiento: tratamiento,
        onSave: onSave,
      ),
    );
  }
}

class _C {
  static const primario = Color(0xFF55C8BD);
  static const primarioOscuro = Color(0xFF1F7A70);
  static const verdeClaro = Color(0xFFA9DDD8);
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const campo = Color(0xFFF4FBFA);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
  static const aplicada = Color(0xFF2E9E5B);
  static const pendiente = Color(0xFFC98A2E);
}

class _DesparasitacionDialog extends StatefulWidget {
  final List<Mascota> mascotas;
  final List<ProductoDesparasitante> productos;
  final Mascota? mascotaInicial;
  final Desparasitacion? tratamiento;
  final Future<void> Function(DesparasitacionFormData datos) onSave;

  const _DesparasitacionDialog({
    required this.mascotas,
    required this.productos,
    required this.mascotaInicial,
    required this.tratamiento,
    required this.onSave,
  });

  @override
  State<_DesparasitacionDialog> createState() => _DesparasitacionDialogState();
}

class _DesparasitacionDialogState extends State<_DesparasitacionDialog> {
  Mascota? _mascota;
  ProductoDesparasitante? _producto;
  DateTime? _fechaAplicacion;
  DateTime? _proximaDosis;
  String _estado = 'Aplicada';
  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.tratamiento != null;

  @override
  void initState() {
    super.initState();
    _mascota = widget.mascotaInicial;

    final t = widget.tratamiento;
    if (t != null) {
      // El historial solo trae el nombre del producto, así que se
      // busca en el catálogo por nombre.
      _producto = widget.productos
          .where((p) => p.nombre == t.producto)
          .firstOrNull;
      _fechaAplicacion = t.fechaAplicacion;
      _proximaDosis = t.proximaDosis;
      _estado = t.estado.toLowerCase() == 'pendiente' ? 'Pendiente' : 'Aplicada';
    }
  }

  String _fmt(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
      '${f.month.toString().padLeft(2, '0')}/${f.year}';

  Future<void> _elegirFecha({
    required DateTime? actual,
    required DateTime? minimo,
    required ValueChanged<DateTime> alElegir,
  }) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual ?? minimo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) alElegir(fecha);
  }

  String? _validar() {
    if (_mascota == null) return 'Selecciona una mascota.';
    if (_producto == null) return 'Selecciona un producto.';
    if (_fechaAplicacion == null) return 'Selecciona la fecha de aplicación.';
    if (_proximaDosis == null) return 'Selecciona la fecha de la próxima dosis.';
    if (_proximaDosis!.isBefore(_fechaAplicacion!)) {
      return 'La próxima dosis no puede ser anterior a la fecha de aplicación.';
    }
    return null;
  }

  Future<void> _guardar() async {
    final problema = _validar();
    if (problema != null) {
      setState(() => _error = problema);
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await widget.onSave(
        DesparasitacionFormData(
          mascota: _mascota!,
          producto: _producto!,
          fechaAplicacion: _fechaAplicacion!,
          proximaDosis: _proximaDosis!,
          estado: _estado,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================
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
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _encabezado(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MASCOTA
                      _etiqueta('Mascota'),
                      const SizedBox(height: 10),
                      _selectorMascota(),

                      const SizedBox(height: 22),

                      // PRODUCTO + FECHAS
                      _etiqueta('Tratamiento'),
                      const SizedBox(height: 10),
                      _selectorProducto(),
                      const SizedBox(height: 12),
                      _campoFecha(
                        icono: Icons.event_available_rounded,
                        etiqueta: 'Fecha de aplicación',
                        valor: _fechaAplicacion,
                        onTap: () => _elegirFecha(
                          actual: _fechaAplicacion,
                          minimo: null,
                          alElegir: (f) =>
                              setState(() => _fechaAplicacion = f),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _campoFecha(
                        icono: Icons.event_repeat_rounded,
                        etiqueta: 'Próxima dosis',
                        valor: _proximaDosis,
                        onTap: () => _elegirFecha(
                          actual: _proximaDosis,
                          minimo: _fechaAplicacion,
                          alElegir: (f) => setState(() => _proximaDosis = f),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ESTADO
                      _etiqueta('Estado'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _opcion(
                              texto: 'Aplicada',
                              icono: Icons.shield_outlined,
                              activa: _estado == 'Aplicada',
                              color: _C.aplicada,
                              onTap: () => setState(() => _estado = 'Aplicada'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _opcion(
                              texto: 'Pendiente',
                              icono: Icons.schedule_rounded,
                              activa: _estado == 'Pendiente',
                              color: _C.pendiente,
                              onTap: () =>
                                  setState(() => _estado = 'Pendiente'),
                            ),
                          ),
                        ],
                      ),

                      // ERROR
                      if (_error != null) ...[
                        const SizedBox(height: 16),
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
                                  _error!,
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

  // ===============================================================
  // ENCABEZADO
  // ===============================================================
  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF8F6), Colors.white],
        ),
        border: Border(bottom: BorderSide(color: _C.borde)),
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
                colors: [_C.primario, _C.primarioOscuro],
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
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _esEdicion ? 'Editar desparasitación' : 'Nueva desparasitación',
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                color: _C.tinta,
              ),
            ),
          ),
          Material(
            color: _C.verdeMuyClaro,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _guardando ? null : () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, size: 20, color: _C.tinta),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // MASCOTA
  // ===============================================================
  Widget _selectorMascota() {
    if (_esEdicion) {
      // En edición la mascota no se puede cambiar
      return Align(
        alignment: Alignment.centerLeft,
        child: _opcion(
          texto: _mascota?.nombrePet ?? 'Mascota',
          icono: Icons.pets,
          activa: true,
          color: _C.primarioOscuro,
          onTap: null,
          compacta: true,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.mascotas.map((m) {
        return _opcion(
          texto: m.nombrePet,
          icono: Icons.pets,
          activa: m.id == _mascota?.id,
          color: _C.primarioOscuro,
          onTap: () => setState(() => _mascota = m),
          compacta: true,
        );
      }).toList(),
    );
  }

  // ===============================================================
  // PRODUCTO
  // ===============================================================
  Widget _selectorProducto() {
    if (widget.productos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'No hay productos en el catálogo todavía.',
          style: TextStyle(fontSize: 13, color: Colors.red),
        ),
      );
    }

    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: ancho),
        );

    return DropdownButtonFormField<ProductoDesparasitante>(
      initialValue: _producto,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: _C.primarioOscuro),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: _C.tinta,
      ),
      decoration: InputDecoration(
        labelText: 'Producto',
        labelStyle: const TextStyle(color: _C.tintaSuave, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: _C.primarioOscuro,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: const Icon(Icons.medication_outlined,
            color: _C.primarioOscuro, size: 22),
        filled: true,
        fillColor: _C.campo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: borde(_C.borde),
        enabledBorder: borde(_C.borde),
        focusedBorder: borde(_C.primarioOscuro, 1.6),
        disabledBorder: borde(_C.borde),
      ),
      items: widget.productos
          .map(
            (p) => DropdownMenuItem(
              value: p,
              child: Text(p.nombre, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _guardando ? null : (p) => setState(() => _producto = p),
    );
  }

  // ===============================================================
  // CAMPO DE FECHA
  // ===============================================================
  Widget _campoFecha({
    required IconData icono,
    required String etiqueta,
    required DateTime? valor,
    required VoidCallback onTap,
  }) {
    final elegida = valor != null;

    return Material(
      color: elegida ? Colors.white : _C.campo,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _guardando ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: elegida ? _C.primarioOscuro : _C.borde,
              width: elegida ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icono, size: 22, color: _C.primarioOscuro),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiqueta,
                      style: TextStyle(
                        fontSize: elegida ? 11.5 : 14.5,
                        fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
                        color: _C.tintaSuave,
                      ),
                    ),
                    if (elegida) ...[
                      const SizedBox(height: 2),
                      Text(
                        _fmt(valor),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _C.tinta,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.calendar_month_outlined,
                  size: 20, color: _C.primarioOscuro),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // OPCIÓN SELECCIONABLE (sin palomita)
  // Seleccionada: relleno con degradado, texto blanco y sombra.
  // ===============================================================
  Widget _opcion({
    required String texto,
    required IconData icono,
    required bool activa,
    required Color color,
    required VoidCallback? onTap,
    bool compacta = false,
  }) {
    return Semantics(
      button: true,
      selected: activa,
      label: texto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(compacta ? 24 : 16),
          gradient: activa
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.78), color],
                )
              : null,
          color: activa ? null : Colors.white,
          border: Border.all(
            color: activa ? Colors.transparent : _C.borde,
          ),
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
            borderRadius: BorderRadius.circular(compacta ? 24 : 16),
            onTap: (_guardando || onTap == null) ? null : onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compacta ? 18 : 14,
                vertical: compacta ? 11 : 14,
              ),
              child: Row(
                mainAxisSize: compacta ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icono,
                    size: 17,
                    color: activa ? Colors.white : color,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      texto,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                        color: activa ? Colors.white : _C.tinta,
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

  // ===============================================================
  // BOTONES
  // ===============================================================
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
              onPressed: _guardando ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: _C.tintaSuave,
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
              opacity: _guardando ? 0.75 : 1,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_C.primario, _C.primarioOscuro],
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
                    onTap: _guardando ? null : _guardar,
                    child: Center(
                      child: _guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _esEdicion ? 'Guardar cambios' : 'Guardar',
                              style: const TextStyle(
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
              color: _C.primario,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _C.tintaSuave,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
}