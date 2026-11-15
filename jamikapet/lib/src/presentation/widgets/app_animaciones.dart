import 'package:flutter/material.dart';

/// Hace aparecer al hijo con un desvanecido y un ligero deslizamiento.
/// El [indice] escalona la entrada cuando hay varios elementos en lista.
class EntradaAnimada extends StatefulWidget {
  const EntradaAnimada({
    super.key,
    required this.child,
    this.indice = 0,
    this.desplazamiento = 24,
    this.duracion = const Duration(milliseconds: 480),
  });

  final Widget child;
  final int indice;
  final double desplazamiento;
  final Duration duracion;

  @override
  State<EntradaAnimada> createState() => _EntradaAnimadaState();
}

class _EntradaAnimadaState extends State<EntradaAnimada>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacidad;
  late final Animation<Offset> _posicion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duracion);

    final curva = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacidad = Tween<double>(begin: 0, end: 1).animate(curva);
    _posicion = Tween<Offset>(
      begin: Offset(0, widget.desplazamiento),
      end: Offset.zero,
    ).animate(curva);

    // Retraso escalonado, con tope para listas largas.
    final retraso = Duration(milliseconds: 70 * widget.indice.clamp(0, 8));
    Future.delayed(retraso, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacidad.value,
          child: Transform.translate(offset: _posicion.value, child: child),
        );
      },
    );
  }
}

/// Reduce un poco el tamaño del hijo mientras se mantiene presionado.
/// Usa Listener, así que no interfiere con InkWell ni GestureDetector.
class PresionAnimada extends StatefulWidget {
  const PresionAnimada({
    super.key,
    required this.child,
    this.escala = 0.97,
  });

  final Widget child;
  final double escala;

  @override
  State<PresionAnimada> createState() => _PresionAnimadaState();
}

class _PresionAnimadaState extends State<PresionAnimada> {
  bool _presionado = false;

  void _cambiar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _cambiar(true),
      onPointerUp: (_) => _cambiar(false),
      onPointerCancel: (_) => _cambiar(false),
      child: AnimatedScale(
        scale: _presionado ? widget.escala : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
