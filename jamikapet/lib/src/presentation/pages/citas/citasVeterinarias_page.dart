import 'package:flutter/material.dart';
import 'package:jamikapet/src/models/consulta.dart';
import 'package:jamikapet/src/services/consulta_service.dart';
import 'package:jamikapet/src/presentation/pages/usuario/perfilUsuario_page.dart';
import 'package:jamikapet/src/presentation/pages/menu/menu_page.dart';
import 'package:jamikapet/src/presentation/pages/IAchat/ia_chat_page.dart';

class CitasVeterinariasPage extends StatefulWidget {
  const CitasVeterinariasPage({super.key});

  @override
  State<CitasVeterinariasPage> createState() => _CitasVeterinariasPageState();
}

class _CitasVeterinariasPageState extends State<CitasVeterinariasPage> {
  final int _selectedIndex = 1;
  bool _notificacionActiva = true;
  bool _cargando = true;
  List<Consulta> _listaConsultas = [];

  final TextEditingController _vetController = TextEditingController();
  final TextEditingController _clinicaController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _fechaHoraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarConsultas();
  }

  @override
  void dispose() {
    _vetController.dispose();
    _clinicaController.dispose();
    _motivoController.dispose();
    _fechaHoraController.dispose();
    super.dispose();
  }

  Future<void> _cargarConsultas() async {
    setState(() => _cargando = true);
    try {
      final consultas = await ConsultaService.obtenerConsultas();
      setState(() {
        _listaConsultas = consultas;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar citas: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilUsuarioPage()),
      );
    } else if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _mostrarDialogoNuevaCita() {
    _vetController.clear();
    _clinicaController.clear();
    _motivoController.clear();
    _fechaHoraController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar Cita / Veterinario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _vetController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Veterinario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _clinicaController,
                decoration: InputDecoration(
                  labelText: 'Clínica Veterinaria',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _motivoController,
                decoration: InputDecoration(
                  labelText: 'Motivo de Consulta',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medical_information_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fechaHoraController,
                decoration: InputDecoration(
                  labelText: 'Hora (Ej. 10:30 AM)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.access_time_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_vetController.text.trim().isEmpty) return;

                    final nuevaConsulta = Consulta(
                      mascotaId: '1',
                      veterinario: _vetController.text.trim(),
                      motivo: _motivoController.text.trim(),
                      fecha: DateTime.now(),
                      hora: _fechaHoraController.text.trim().isEmpty
                          ? '10:00 AM'
                          : _fechaHoraController.text.trim(),
                      notas: _clinicaController.text.trim().isNotEmpty
                          ? 'Clínica: ${_clinicaController.text.trim()}'
                          : null,
                    );

                    Navigator.pop(context);

                    try {
                      await ConsultaService.registrarConsulta(nuevaConsulta);
                      _cargarConsultas();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Cita registrada correctamente!'),
                          backgroundColor: Color(0xFF00695C),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar cita: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar Cita',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBackground = Color(0xFFE2F4F1);
    const headerColor = Color(0xFFC5ECE5);
    const darkText = Colors.black87;

    final proximaCita = _listaConsultas.isNotEmpty ? _listaConsultas.first : null;

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Citas Veterinarias',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
            : RefreshIndicator(
                onRefresh: _cargarConsultas,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Próxima Cita',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB2DFDB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2F1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.event, color: Color(0xFF00695C)),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          proximaCita != null
                                              ? '${proximaCita.fecha.day}/${proximaCita.fecha.month}/${proximaCita.fecha.year}'
                                              : 'Sin cita agendada',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          proximaCita?.hora ?? '--:--',
                                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.notifications_active_outlined,
                                        size: 20, color: Colors.teal),
                                    Switch(
                                      value: _notificacionActiva,
                                      activeColor: const Color(0xFF00695C),
                                      onChanged: (val) {
                                        setState(() => _notificacionActiva = val);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildDetailRow('Veterinario:', proximaCita?.veterinario ?? 'N/A'),
                            _buildDetailRow('Motivo:', proximaCita?.motivo ?? 'Sin motivo registrado'),
                            if (proximaCita?.notas != null)
                              _buildDetailRow('Notas:', proximaCita!.notas!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _mostrarDialogoNuevaCita,
                          icon: const Icon(Icons.add_circle_outline, color: darkText),
                          label: const Text(
                            'Registrar Nueva Cita / Veterinario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: darkText,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8E6CF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Color(0xFF81C784)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        'Historial de Citas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_listaConsultas.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('No hay historial de citas.'),
                          ),
                        )
                      else
                        ..._listaConsultas.map((item) => _buildHistorialCard(
                              fecha: '${item.fecha.day}/${item.fecha.month}/${item.fecha.year} - ${item.hora}',
                              veterinario: item.veterinario,
                              motivo: item.motivo,
                              notas: item.notas ?? 'Sin observaciones.',
                            )),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F7A70),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatIaPage()),
        ),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      bottomNavigationBar: _buildStandardBottomNavigationBar(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialCard({
    required String fecha,
    required String veterinario,
    required String motivo,
    required String notas,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fecha,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
            ],
          ),
          const Divider(height: 16),
          _buildDetailRow('Veterinario:', veterinario),
          _buildDetailRow('Motivo:', motivo),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notas: $notas',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE2F4F1),
        border: Border(top: BorderSide(color: Color(0xFFB2DFDB), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFE2F4F1),
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: const Color(0xFF616161),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            activeIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}