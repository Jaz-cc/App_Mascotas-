import 'package:flutter/material.dart';

class VacunaUpdateModal extends StatefulWidget {
  final DateTime? fechaInicial;
  final String estadoInicial;
  final String observacionesIniciales;

  final Future<void> Function(
    DateTime fecha,
    String estado,
    String observaciones,
  ) onGuardar;

  const VacunaUpdateModal({
    super.key,
    this.fechaInicial,
    this.estadoInicial = 'No aplicada',
    this.observacionesIniciales = '',
    required this.onGuardar,
  });

  static Future<bool?> show(
    BuildContext context, {
    DateTime? fechaInicial,
    String estadoInicial = 'No aplicada',
    String observacionesIniciales = '',
    required Future<void> Function(
      DateTime fecha,
      String estado,
      String observaciones,
    ) onGuardar,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VacunaUpdateModal(
        fechaInicial: fechaInicial,
        estadoInicial: estadoInicial,
        observacionesIniciales: observacionesIniciales,
        onGuardar: onGuardar,
      ),
    );
  }

  @override
  State<VacunaUpdateModal> createState() =>
      _VacunaUpdateModalState();
}

class _VacunaUpdateModalState
    extends State<VacunaUpdateModal> {
  static const Color turquesa = Color(0xFF4FC3B8);

  late DateTime fecha;
  late String estado;
  late TextEditingController observacionesController;

  bool guardando = false;
  String? error;

  final List<String> estados = [
    'No aplicada',
    'Aplicada',
    'Próxima dosis',
  ];

  @override
  void initState() {
    super.initState();

    fecha = widget.fechaInicial ?? DateTime.now();

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

    if (seleccionada != null && mounted) {
      setState(() {
        fecha = seleccionada;
        error = null;
      });
    }
  }

  Future<void> guardar() async {
    setState(() {
      guardando = true;
      error = null;
    });

    try {
      await widget.onGuardar(
        fecha,
        estado,
        observacionesController.text.trim(),
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
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 550,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ENCABEZADO
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24, 20, 12, 16,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.vaccines_outlined,
                    color: turquesa,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Actualizar vacuna',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: guardando
                        ? null
                        : () => Navigator.pop(context, false),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FECHA
                    const Text(
                      'Fecha de la vacuna',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: guardando
                          ? null
                          : seleccionarFecha,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: turquesa,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formatearFecha(fecha),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ESTADO
                    const Text(
                      'Estado de la vacuna',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: estado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.check_circle_outline,
                          color: turquesa,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: estados.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: guardando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                setState(() {
                                  estado = valor;
                                  error = null;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 22),

                    // OBSERVACIONES
                    const Text(
                      'Observaciones',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: observacionesController,
                      enabled: !guardando,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Escribe alguna observación...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 55),
                          child: Icon(
                            Icons.notes,
                            color: turquesa,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (error != null) {
                          setState(() => error = null);
                        }
                      },
                    ),

                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        error!,
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
                        onPressed: guardando
                            ? null
                            : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
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
                        onPressed: guardando ? null : guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: turquesa,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: guardando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Guardar cambios',
                                style: TextStyle(
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
}
