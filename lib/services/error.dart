import 'package:flutter/material.dart';

void pokaziGresku(BuildContext context, String poruka) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      // Ovo ga stavlja na dno ekrana, ali ispred popupa
      bottom: 0, 
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
          ),
          child: Text(
            poruka,
            style: TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  // Automatski ukloni nakon 2 sekunde
  Future.delayed(Duration(seconds: 2), () => entry.remove());
}