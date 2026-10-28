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
  static const verdeMuyClaro = Color(0xFFD1F0EE);
  static const campo = Color(0xFFF4FBFA);
  static const borde = Color(0xFFCBE5E2);
  static const tinta = Color(0xFF16302D);
  static const tintaSuave = Color(0xFF5C7A77);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Row(
                children: [
                  const Icon(Icons.health_and_safety_outlined,
                      color: _C.primarioOscuro, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _esEdicion
                          ? 'Editar desparasitación'
                          : 'Nueva desparasitación',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _C.tinta,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // MASCOTA
              _etiqueta('Mascota'),
              const SizedBox(height: 8),
              if (_esEdicion)
                Chip(
                  avatar: const Icon(Icons.pets,
                      size: 16, color: _C.primarioOscuro),
                  label: Text(_mascota?.nombrePet ?? 'Mascota'),
                  backgroundColor: _C.verdeMuyClaro,
                  side: const BorderSide(color: _C.primarioOscuro),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.mascotas.map((m) {
                    final activa = m.id == _mascota?.id;
                    return ChoiceChip(
                      label: Text(m.nombrePet),
                      selected: activa,
                      onSelected: _guardando
                          ? null
                          : (_) => setState(() => _mascota = m),
                      selectedColor: _C.verdeMuyClaro,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: activa ? _C.primarioOscuro : _C.borde,
                      ),
                      labelStyle:
                          const TextStyle(fontSize: 12.5, color: _C.tinta),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // PRODUCTO
              if (widget.productos.isEmpty)
                const Text(
                  'No hay productos en el catálogo todavía.',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                )
              else
                DropdownButtonFormField<ProductoDesparasitante>(
                  initialValue: _producto,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Producto',
                    filled: true,
                    fillColor: _C.campo,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: widget.productos
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.nombre,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged:
                      _guardando ? null : (p) => setState(() => _producto = p),
                ),

              const SizedBox(height: 12),

              // FECHAS
              _campoFecha(
                etiqueta: _fechaAplicacion == null
                    ? 'Fecha de aplicación'
                    : _fmt(_fechaAplicacion!),
                onTap: () => _elegirFecha(
                  actual: _fechaAplicacion,
                  minimo: null,
                  alElegir: (f) => setState(() => _fechaAplicacion = f),
                ),
              ),
              const SizedBox(height: 10),
              _campoFecha(
                etiqueta: _proximaDosis == null
                    ? 'Próxima dosis'
                    : _fmt(_proximaDosis!),
                onTap: () => _elegirFecha(
                  actual: _proximaDosis,
                  minimo: _fechaAplicacion,
                  alElegir: (f) => setState(() => _proximaDosis = f),
                ),
              ),

              const SizedBox(height: 16),

              // ESTADO
              _etiqueta('Estado'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Aplicada', 'Pendiente'].map((e) {
                  final activo = _estado == e;
                  return ChoiceChip(
                    label: Text(e),
                    selected: activo,
                    onSelected:
                        _guardando ? null : (_) => setState(() => _estado = e),
                    selectedColor: _C.verdeMuyClaro,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: activo ? _C.primarioOscuro : _C.borde,
                    ),
                    labelStyle:
                        const TextStyle(fontSize: 12.5, color: _C.tinta),
                  );
                }).toList(),
              ),

              // ERROR
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 12.5, color: Colors.red.shade700),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // BOTONES
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _guardando ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(color: _C.tintaSuave)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primario,
                        foregroundColor: _C.tinta,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_esEdicion ? 'Guardar cambios' : 'Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etiqueta(String texto) => Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _C.tintaSuave,
        ),
      );

  Widget _campoFecha({required String etiqueta, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _guardando ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _C.campo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.borde),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta,
                style: const TextStyle(fontSize: 14, color: _C.tinta)),
            const Icon(Icons.calendar_month_outlined,
                size: 18, color: _C.primarioOscuro),
          ],
        ),
      ),
    );
  }
}