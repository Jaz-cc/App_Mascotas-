import 'package:flutter/material.dart';

class MedicamentoModal {
  static const Color primario = Color(0xFF1F7A70);
  static const Color verdeClaro = Color(0xFFD1F0EE);
  static const Color fondo = Color(0xFFF5FAF9);
  static const Color tinta = Color(0xFF16302D);
  static const Color gris = Color(0xFF6B8581);

  static const List<String> frecuencias = [
    'Cada 4 horas',
    'Cada 6 horas',
    'Cada 8 horas',
    'Cada 12 horas',
    'Cada 24 horas',
    'Una vez al día',
    'Cada 2 días',
    'Una vez por semana',
    'Según indicación veterinaria',
    'Personalizada',
  ];

  static void show(
    BuildContext context, {
    bool esEdicion = false,
    Map<String, String>? datosIniciales,
    required Function(Map<String, String> datos) onSave,
  }) {
    final inicial = datosIniciales ?? {};

    final nameCtrl = TextEditingController(
      text: inicial['nombre'] ?? '',
    );
    final dosisCtrl = TextEditingController(
      text: inicial['dosis'] ?? '',
    );
    final frecCtrl = TextEditingController(
      text: inicial['frecuencia'] ?? '',
    );
    final vetCtrl = TextEditingController(
      text: inicial['veterinario'] ?? '',
    );
    final indicCtrl = TextEditingController(
      text: inicial['indicaciones'] ?? '',
    );

    final formKey = GlobalKey<FormState>();

    DateTime? fechaInicio = DateTime.tryParse(inicial['inicio'] ?? '');
    DateTime? fechaFin = DateTime.tryParse(inicial['fin'] ?? '');

    String? frecuenciaSeleccionada =
        frecuencias.contains(inicial['frecuencia'])
            ? inicial['frecuencia']
            : (inicial['frecuencia']?.isNotEmpty == true
                ? 'Personalizada'
                : null);

    if (frecuenciaSeleccionada == 'Personalizada') {
      // Conserva la frecuencia personalizada al editar.
    }

    // Recuperar los horarios existentes.
    final List<TimeOfDay> horarios = [];

    final horariosIniciales =
        inicial['horarios'] ?? inicial['horaAdministracion'] ?? '';

    for (final parte in horariosIniciales.split(',')) {
      final texto = parte.trim();
      final coincidencia = RegExp(r'^(\d{1,2}):(\d{2})$')
          .firstMatch(texto);

      if (coincidencia != null) {
        final hora = int.parse(coincidencia.group(1)!);
        final minuto = int.parse(coincidencia.group(2)!);

        if (hora < 24 && minuto < 60) {
          horarios.add(TimeOfDay(hour: hora, minute: minuto));
        }
      }
    }

    // Conserva formatos anteriores que no sean HH:mm.
    final horarioAnteriorNoParseable =
        horarios.isEmpty && horariosIniciales.isNotEmpty
            ? horariosIniciales
            : '';

    String formatoFecha(DateTime? fecha) {
      if (fecha == null) return 'Seleccionar fecha';

      return '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';
    }

    String formatoHora(TimeOfDay hora) {
      return '${hora.hour.toString().padLeft(2, '0')}:'
          '${hora.minute.toString().padLeft(2, '0')}';
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> seleccionarFecha({required bool inicio}) async {
              final actual = inicio ? fechaInicio : fechaFin;

              final seleccionada = await showDatePicker(
                context: context,
                initialDate: actual ??
                    (inicio
                        ? DateTime.now()
                        : fechaInicio ?? DateTime.now()),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                locale: const Locale('es', 'MX'),
                helpText: inicio
                    ? 'Fecha de inicio del tratamiento'
                    : 'Fecha de finalización',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: primario,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: tinta,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (seleccionada != null) {
                setModalState(() {
                  if (inicio) {
                    fechaInicio = seleccionada;

                    if (fechaFin != null &&
                        fechaFin!.isBefore(seleccionada)) {
                      fechaFin = null;
                    }
                  } else {
                    fechaFin = seleccionada;
                  }
                });
              }
            }

            Future<void> agregarHorario() async {
              final seleccionado = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                helpText: 'Selecciona la hora de administración',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: primario,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: tinta,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (seleccionado != null) {
                setModalState(() {
                  if (!horarios.any((h) =>
                      h.hour == seleccionado.hour &&
                      h.minute == seleccionado.minute)) {
                    horarios.add(seleccionado);
                    horarios.sort((a, b) {
                      final minutosA = a.hour * 60 + a.minute;
                      final minutosB = b.hour * 60 + b.minute;
                      return minutosA.compareTo(minutosB);
                    });
                  }
                });
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 540,
                  maxHeight: 760,
                ),
                child: Column(
                  children: [
                    // ENCABEZADO
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                      decoration: const BoxDecoration(
                        color: fondo,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              color: verdeClaro,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medication_outlined,
                              color: primario,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  esEdicion
                                      ? 'Editar medicamento'
                                      : 'Nuevo medicamento',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: tinta,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Organiza el tratamiento de tu mascota',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: gris,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFE5EFED)),

                    // FORMULARIO
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            _tituloSeccion(
                              'Información del medicamento',
                              Icons.medical_services_outlined,
                            ),

                            const SizedBox(height: 14),

                            _campo(
                              controller: nameCtrl,
                              label: 'Nombre del medicamento',
                              hint: 'Ej. Amoxicilina',
                              icono: Icons.medication,
                              requerido: true,
                            ),

                            const SizedBox(height: 14),

                            _campo(
                              controller: dosisCtrl,
                              label: 'Dosis',
                              hint: 'Ej. 1 tableta, 5 ml',
                              icono: Icons.straighten,
                              requerido: true,
                            ),

                            const SizedBox(height: 24),

                            _tituloSeccion(
                              'Administración',
                              Icons.access_time,
                            ),

                            const SizedBox(height: 14),

                            DropdownButtonFormField<String>(
                              value: frecuenciaSeleccionada,
                              isExpanded: true,
                              decoration: _decoracion(
                                'Frecuencia de administración',
                                Icons.repeat,
                              ),
                              hint: const Text('Selecciona la frecuencia'),
                              items: frecuencias.map((frecuencia) {
                                return DropdownMenuItem(
                                  value: frecuencia,
                                  child: Text(
                                    frecuencia,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (valor) {
                                setModalState(() {
                                  frecuenciaSeleccionada = valor;

                                  if (valor != 'Personalizada') {
                                    frecCtrl.text = '';
                                  }
                                });
                              },
                              validator: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Selecciona una frecuencia';
                                }

                                if (valor == 'Personalizada' &&
                                    frecCtrl.text.trim().isEmpty) {
                                  return 'Especifica la frecuencia';
                                }

                                return null;
                              },
                            ),

                            if (frecuenciaSeleccionada == 'Personalizada') ...[
                              const SizedBox(height: 12),
                              _campo(
                                controller: frecCtrl,
                                label: 'Frecuencia personalizada',
                                hint: 'Ej. Cada 3 días',
                                icono: Icons.edit_calendar_outlined,
                                requerido: true,
                              ),
                            ],

                            const SizedBox(height: 18),

                            const Text(
                              'Horarios de administración',
                              style: TextStyle(
                                color: tinta,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'Agrega una o varias horas para administrar el medicamento.',
                              style: TextStyle(
                                fontSize: 12,
                                color: gris,
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (horarios.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: horarios.map((hora) {
                                  return Chip(
                                    backgroundColor: verdeClaro,
                                    side: BorderSide.none,
                                    avatar: const Icon(
                                      Icons.access_time,
                                      color: primario,
                                      size: 17,
                                    ),
                                    label: Text(
                                      formatoHora(hora),
                                      style: const TextStyle(
                                        color: tinta,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 17,
                                      color: primario,
                                    ),
                                    onDeleted: () {
                                      setModalState(() {
                                        horarios.remove(hora);
                                      });
                                    },
                                  );
                                }).toList(),
                              )
                            else if (horarioAnteriorNoParseable.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: fondo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Horario registrado: $horarioAnteriorNoParseable',
                                  style: const TextStyle(
                                    color: tinta,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: fondo,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE0EBE8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: gris,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Todavía no agregas horarios.',
                                        style: TextStyle(
                                          color: gris,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 10),

                            OutlinedButton.icon(
                              onPressed: agregarHorario,
                              icon: const Icon(Icons.add_alarm),
                              label: const Text('Agregar horario'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primario,
                                side: const BorderSide(color: primario),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            _tituloSeccion(
                              'Duración del tratamiento',
                              Icons.calendar_month_outlined,
                            ),

                            const SizedBox(height: 14),

                            _selectorFecha(
                              titulo: 'Fecha de inicio',
                              fecha: formatoFecha(fechaInicio),
                              icono: Icons.calendar_today_outlined,
                              onTap: () =>
                                  seleccionarFecha(inicio: true),
                            ),

                            const SizedBox(height: 12),

                            _selectorFecha(
                              titulo: 'Fecha de finalización',
                              fecha: formatoFecha(fechaFin),
                              icono: Icons.event_available_outlined,
                              onTap: () =>
                                  seleccionarFecha(inicio: false),
                            ),

                            if (fechaInicio != null &&
                                fechaFin != null &&
                                fechaFin!.isBefore(fechaInicio!))
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Text(
                                  'La fecha final no puede ser anterior a la inicial.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            _tituloSeccion(
                              'Información adicional',
                              Icons.notes_outlined,
                            ),

                            const SizedBox(height: 14),

                            _campo(
                              controller: vetCtrl,
                              label: 'Veterinario (opcional)',
                              hint: 'Nombre del veterinario',
                              icono: Icons.person_outline,
                            ),

                            const SizedBox(height: 14),

                            _campo(
                              controller: indicCtrl,
                              label: 'Indicaciones adicionales',
                              hint: 'Ej. Administrar después de comer...',
                              icono: Icons.description_outlined,
                              maxLines: 3,
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: verdeClaro.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: primario,
                                    size: 20,
                                  ),
                                  SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'Registra la dosis y frecuencia indicadas por el veterinario. No modifiques el tratamiento sin consultarlo.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: tinta,
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

                    // BOTONES
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5EFED)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: gris,
                                side: const BorderSide(
                                  color: Color(0xFFD5E3E0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                if (horarios.isEmpty &&
                                    horarioAnteriorNoParseable.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Agrega al menos un horario de administración.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (fechaInicio == null ||
                                    fechaFin == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Selecciona las fechas del tratamiento.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (fechaFin!.isBefore(fechaInicio!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La fecha final no puede ser anterior a la inicial.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final frecuenciaFinal =
                                    frecuenciaSeleccionada == 'Personalizada'
                                        ? frecCtrl.text.trim()
                                        : frecuenciaSeleccionada!;

                                final horariosFinal = horarios.isNotEmpty
                                    ? horarios.map(formatoHora).join(', ')
                                    : horarioAnteriorNoParseable;

                                onSave({
                                  'nombre': nameCtrl.text.trim(),
                                  'dosis': dosisCtrl.text.trim(),
                                  'frecuencia': frecuenciaFinal,
                                  'horarios': horariosFinal,
                                  'inicio': fechaInicio!
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  'fin': fechaFin!
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  'veterinario': vetCtrl.text.trim(),
                                  'indicaciones': indicCtrl.text.trim(),
                                });

                                Navigator.pop(dialogContext);
                              },
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 19,
                              ),
                              label: Text(
                                esEdicion ? 'Guardar cambios' : 'Guardar',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primario,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
          },
        );
      },
    );
  }

  // TITULOS DE SECCIÓN
  static Widget _tituloSeccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, color: primario, size: 20),
        const SizedBox(width: 9),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: tinta,
          ),
        ),
      ],
    );
  }

  // CAMPOS DE TEXTO
  static Widget _campo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icono,
    bool requerido = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: _decoracion(label, icono).copyWith(
        hintText: hint,
      ),
      validator: requerido
          ? (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  // DECORACIÓN GENERAL
  static InputDecoration _decoracion(
    String label,
    IconData icono,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: gris,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icono,
        color: primario,
        size: 20,
      ),
      filled: true,
      fillColor: fondo,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCEAE7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCEAE7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primario,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  // SELECTOR DE FECHAS
  static Widget _selectorFecha({
    required String titulo,
    required String fecha,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    final seleccionada = fecha != 'Seleccionar fecha';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFFDCEAE7),
          ),
        ),
        child: Row(
          children: [
            Icon(icono, color: primario, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: gris,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fecha,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: seleccionada ? tinta : gris,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_month,
              color: primario,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
