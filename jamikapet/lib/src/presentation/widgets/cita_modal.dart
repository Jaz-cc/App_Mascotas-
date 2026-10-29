import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/consulta.dart';
import 'package:jamikapet/src/models/mascota.dart';

/// Datos validados del formulario. La mascota viaja como objeto;
/// al guardar se usa solo `mascota.id`.
class CitaFormData {
  final Mascota mascota;
  final String veterinario;
  final String correo;
  final String motivo;
  final DateTime fecha;
  final String hora; // HH:mm
  final String estado;
  final String? notas;

  const CitaFormData({
    required this.mascota,
    required this.veterinario,
    required this.correo,
    required this.motivo,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.notas,
  });
}

/// Modal para registrar (cita == null) o editar una cita veterinaria.
///
/// [onSave] se espera con await: el modal muestra un loader en el botón,
/// se cierra solo si todo sale bien y, si falla, muestra el error dentro.
class CitaModal {
  CitaModal._();

  static Future<void> show(
    BuildContext context, {
    required List<Mascota> mascotas,
    Consulta? cita,
    required Future<void> Function(CitaFormData datos) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CitaForm(mascotas: mascotas, cita: cita, onSave: onSave),
    );
  }
}

class _CitaForm extends StatefulWidget {
  final List<Mascota> mascotas;
  final Consulta? cita;
  final Future<void> Function(CitaFormData datos) onSave;

  const _CitaForm({
    required this.mascotas,
    required this.cita,
    required this.onSave,
  });

  @override
  State<_CitaForm> createState() => _CitaFormState();
}

class _CitaFormState extends State<_CitaForm> {
  static const Color turquesa = Color(0xFF4FC3B8);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _veterinario;
  late final TextEditingController _correo;
  late final TextEditingController _motivo;
  late final TextEditingController _notas;

  Mascota? _mascota;
  late DateTime _fecha;
  late TimeOfDay _hora;
  late String _estado;

  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.cita != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cita;

    _veterinario = TextEditingController(text: c?.veterinario ?? '');
    _correo = TextEditingController(text: c?.correo ?? '');
    _motivo = TextEditingController(text: c?.motivo ?? '');
    _notas = TextEditingController(text: c?.notas ?? '');

    _fecha = c?.fecha ?? DateTime.now();
    _hora = _leerHora(c?.hora ?? '10:00');
    _estado = c?.estado ?? 'Pendiente';

    if (c != null) {
      _mascota = widget.mascotas.where((m) => m.id == c.mascotaId).firstOrNull;
    } else if (widget.mascotas.length == 1) {
      _mascota = widget.mascotas.first;
    }
  }

  @override
  void dispose() {
    _veterinario.dispose();
    _correo.dispose();
    _motivo.dispose();
    _notas.dispose();
    super.dispose();
  }

  TimeOfDay _leerHora(String hora) {
    final partes = hora.split(':');
    if (partes.length < 2) return const TimeOfDay(hour: 10, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 10,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  String _formatearFecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
      '${f.month.toString().padLeft(2, '0')}/${f.year}';

  Future<void> _seleccionarFecha() async {
    final sel = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Seleccionar fecha de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: _temaTurquesa,
    );
    if (sel != null && mounted) {
      setState(() {
        _fecha = sel;
        _error = null;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final sel = await showTimePicker(
      context: context,
      initialTime: _hora,
      helpText: 'Seleccionar hora de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: _temaTurquesa,
    );
    if (sel != null && mounted) {
      setState(() {
        _hora = sel;
        _error = null;
      });
    }
  }

  Widget _temaTurquesa(BuildContext context, Widget? child) {
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
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final notas = _notas.text.trim();
    final hora =
        '${_hora.hour.toString().padLeft(2, '0')}:'
        '${_hora.minute.toString().padLeft(2, '0')}';

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await widget.onSave(
        CitaFormData(
          mascota: _mascota!,
          veterinario: _veterinario.text.trim(),
          correo: _correo.text.trim(),
          motivo: _motivo.text.trim(),
          fecha: DateTime(_fecha.year, _fecha.month, _fecha.day),
          hora: hora,
          estado: _estado,
          notas: notas.isEmpty ? null : notas,
        ),
      );
      if (mounted) Navigator.of(context).pop();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ENCABEZADO
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_note_outlined,
                    color: turquesa,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _esEdicion
                          ? 'Editar cita veterinaria'
                          : 'Registrar cita veterinaria',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _guardando ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // FORMULARIO
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MASCOTA
                      _etiqueta('Mascota'),
                      DropdownButtonFormField<Mascota>(
                        initialValue: _mascota,
                        isExpanded: true,
                        decoration: _decoracion(icono: Icons.pets),
                        items: widget.mascotas
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m.nombrePet,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _guardando
                            ? null
                            : (m) => setState(() {
                                  _mascota = m;
                                  _error = null;
                                }),
                        validator: (m) =>
                            m == null ? 'Selecciona una mascota.' : null,
                      ),

                      const SizedBox(height: 22),

                      // VETERINARIO
                      _etiqueta('Nombre del veterinario'),
                      _campo(
                        controller: _veterinario,
                        icono: Icons.person_outline,
                        hint: 'Escribe el nombre del veterinario',
                      ),

                      const SizedBox(height: 22),

                      // MOTIVO
                      _etiqueta('Motivo de consulta'),
                      _campo(
                        controller: _motivo,
                        icono: Icons.medical_information_outlined,
                        hint: 'Escribe el motivo de la consulta',
                      ),

                      const SizedBox(height: 22),

                      // FECHA
                      _etiqueta('Fecha de la cita'),
                      _selector(
                        icono: Icons.calendar_month,
                        texto: _formatearFecha(_fecha),
                        onTap: _guardando ? null : _seleccionarFecha,
                      ),

                      const SizedBox(height: 22),

                      // HORA
                      _etiqueta('Hora de la cita'),
                      _selector(
                        icono: Icons.access_time,
                        texto: _hora.format(context),
                        onTap: _guardando ? null : _seleccionarHora,
                      ),

                      const SizedBox(height: 22),

                      // NOTAS
                      _etiqueta('Notas (opcional)'),
                      TextFormField(
                        controller: _notas,
                        enabled: !_guardando,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: _decoracion(
                          icono: Icons.notes,
                          hint: 'Escribe alguna nota...',
                          iconoArriba: true,
                        ),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // BOTONES
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _guardando
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: turquesa,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _esEdicion ? 'Actualizar cita' : 'Guardar cita',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers de UI ----------

  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _decoracion({
    required IconData icono,
    String? hint,
    bool iconoArriba = false,
  }) {
    return InputDecoration(
      hintText: hint,
      alignLabelWithHint: true,
      prefixIcon: iconoArriba
          ? Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: Icon(icono, color: turquesa),
            )
          : Icon(icono, color: turquesa),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: turquesa, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required IconData icono,
    String? hint,
    TextInputType teclado = TextInputType.text,
    bool validarCorreo = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      enabled: !_guardando,
      decoration: _decoracion(icono: icono, hint: hint),
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      validator: (valor) {
        final texto = valor?.trim() ?? '';
        if (texto.isEmpty) return 'Este campo es obligatorio.';
        if (validarCorreo &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto)) {
          return 'Ingresa un correo válido.';
        }
        return null;
      },
    );
  }

  Widget _selector({
    required IconData icono,
    required String texto,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icono, color: turquesa),
            const SizedBox(width: 12),
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 15)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}