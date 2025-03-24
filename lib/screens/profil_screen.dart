import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/reservation_screen.dart';
import '../screens/abonnement_screen.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController(text: "Nourhen");
  TextEditingController surnameController = TextEditingController(text: "Nefzi");
  TextEditingController emailController = TextEditingController(text: "nourhen@example.com");
  TextEditingController phoneController = TextEditingController(text: "+216 12345678");
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigation selon l'index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home_screen');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/reservation_screen');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/abonnement_screen');
          break;
        case 3:
          break; // Déjà sur la page profil
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isEditing = false;
                  });
                }
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: isEditing ? _buildEditForm() : _buildInfoView(),
            ),
            SizedBox(height: 20),
            _buildReservationsList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Réservation'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'Abonnement'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildInfoView() {
    return Column(
      children: [
        _infoCard("Nom", nameController.text),
        _infoCard("Prénom", surnameController.text),
        _infoCard("Email", emailController.text),
        _infoCard("Téléphone", phoneController.text),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _editableField("Nom", nameController),
          _editableField("Prénom", surnameController),
          _editableField("Email", emailController),
          _editableField("Téléphone", phoneController),
          _editableField("Mot de passe", passwordController, isPassword: true),
          _editableField("Confirmer le mot de passe", confirmPasswordController, isPassword: true, isConfirm: true),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller, {bool isPassword = false, bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Ce champ est obligatoire";
          }
          if (isConfirm && value != passwordController.text) {
            return "Les mots de passe ne correspondent pas";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReservationsList() {
    return Column(
      children: [
        Text("Mes Réservations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.local_parking, color: Colors.purple),
                title: Text("Réservation #${index + 1}"),
                subtitle: Text("Détails de la réservation ici..."),
              ),
            );
          },
        ),
      ],
    );
  }
}