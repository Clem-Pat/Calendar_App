
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlatCard extends StatelessWidget {
  final String name;
  final String date;
  final List<String> attendees;
  final String filter;

  PlatCard({required this.name, required this.date, required this.attendees, required this.filter});

  @override
  Widget build(BuildContext context) {
    String attendeesText;
    if (attendees.length > 3) {
      attendeesText = '${attendees.sublist(0, 3).join(', ')}, +${attendees.length - 3}';
    } else {
      attendeesText = attendees.join(', ');
    }
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Réduction du padding
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Nom du plat
        subtitle: Text(
          attendeesText,
          style: TextStyle(color: Colors.grey[600]),
        ), // Noms des personnes présentes au diner lors duquel le plat a été servi
        trailing: Text(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
          style: TextStyle(color: Colors.grey[600]),
        ), // Date du dîner lors duquel le plat a été servi
      ),
    );
  }
}




class DinerCard extends StatelessWidget {
  final String name;
  final String date;
  final List<String> attendees;
  final String filter;

  DinerCard({required this.name, required this.date, required this.attendees, required this.filter});

  @override
  Widget build(BuildContext context) {
    String attendeesText;
    if (attendees.length > 3) {
      attendeesText = '${attendees.sublist(0, 3).join(', ')}, +${attendees.length - 3}';
    } else {
      attendeesText = attendees.join(', ');
    }
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Réduction du padding
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Nom du dîner
        subtitle: Text(
          attendeesText,
          style: TextStyle(color: Colors.grey[600]),
        ), // Noms des personnes présentes
        trailing: Text(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
          style: TextStyle(color: Colors.grey[600]),
        ), // Date du dîner
      ),
    );
  }
}

