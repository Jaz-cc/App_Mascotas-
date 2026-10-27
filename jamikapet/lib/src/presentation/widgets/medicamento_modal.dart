import 'package:flutter/material.dart';

class MedicamentoModal {
  static void show(
    BuildContext context, {
    bool esEdicion = false,
    Map<String, String>? datosIniciales,
    required Function(Map<String, String> datos) onSave,
  }) {
    final nameCtrl = TextEditingController(text: datosIniciales?['nombre'] ?? '');
    final dosisCtrl = TextEditingController(text: datosIniciales?['dosis'] ?? '');
    final frecCtrl = TextEditingController(text: datosIniciales?['frecuencia'] ?? '');
    final horariosCtrl = TextEditingController(text: datosIniciales?['horarios'] ?? '');
    final inicioCtrl = TextEditingController(text: datosIniciales?['inicio'] ?? '');
    final finCtrl = TextEditingController(text: datosIniciales?['fin'] ?? '');
    final vetCtrl = TextEditingController(text: datosIniciales?['veterinario'] ?? '');
    final indicCtrl = TextEditingController(text: datosIniciales?['indicaciones'] ?? '');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 750,
              maxHeight: 700,
            ),
            child: Column(
              children: [
                // ==========================================
                // ENCABEZADO
                // ==========================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        color: Color(0xFF1F7A70),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          esEdicion ? 'Editar Medicamento' : 'Agregar Medicamento',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ==========================================
                // FORMULARIO
                // ==========================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildTextField(nameCtrl, 'Nombre del Medicamento', Icons.medical_services_outlined),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(dosisCtrl, 'Dosis', Icons.straighten)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(frecCtrl, 'Frecuencia', Icons.repeat)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(horariosCtrl, 'Horarios de administración', Icons.access_time),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(inicioCtrl, 'Fecha inicio', Icons.calendar_today)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(finCtrl, 'Fecha fin', Icons.event_available)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(vetCtrl, 'Veterinario', Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildTextField(indicCtrl, 'Indicaciones', Icons.notes, maxLines: 2),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // BOTÓN DE GUARDAR
                // ==========================================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;

                        onSave({
                          'nombre': nameCtrl.text.trim(),
                          'dosis': dosisCtrl.text.trim(),
                          'frecuencia': frecCtrl.text.trim(),
                          'horarios': horariosCtrl.text.trim(),
                          'inicio': inicioCtrl.text.trim(),
                          'fin': finCtrl.text.trim(),
                          'veterinario': vetCtrl.text.trim(),
                          'indicaciones': indicCtrl.text.trim(),
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F7A70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        esEdicion ? 'Guardar Cambios' : 'Agregar Medicamento',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1F7A70)),
      ),
    );
  }
}