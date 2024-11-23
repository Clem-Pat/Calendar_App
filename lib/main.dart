import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'diner.dart';
import 'invite.dart';
import 'plat.dart';
import 'card.dart'; 
import 'package:diacritic/diacritic.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Supprimer le logo "DEBUG"
      title: 'Guest Diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = ""; // Search query for filtering
  final dbHelper = DatabaseHelper.instance;
  List<Widget> dinerCards = []; // Liste des cartes de dîners
  List<Widget> platCards = []; // Liste des cartes de plats
  List<Widget> allDinerCards = [];
  String _selectedFilter = 'Par Dîner';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await dbHelper.deleteAll(); // Supprimer les données existantes
    await _fillInDatabase(); // Remplir la base de données
    //await dbHelper.printAllTables(); // Imprimer toutes les tables pour débogage
  }

  Future<void> _fillInDatabase() async {
    // Ajouter des diners
    List<Diner> diners = [
      Diner(name: 'Dîner Pacques', date: '2024-04-01'),
      Diner(name: 'Dîner Noël', date: '2024-12-25'),
      Diner(name: 'Dîner Arradon', date: '2024-01-13')
    ];
    List<int> dinerIds = [];
    for (Diner diner in diners) {
      int id = await dbHelper.insertDiner(diner);
      dinerIds.add(id);
    }

    // Ajouter des invités
    List<Invite> attendees = [
      Invite(first_name: 'Jean', name: 'Doe'),
      Invite(first_name: "Carine", name: "Patrizio"),
      Invite(first_name: "Jean", name: "Dupont"),
      Invite(first_name: "Marie", name: "Durand"),
      Invite(first_name: "Pierre", name: "Martin"),
      Invite(first_name: "Paul", name: "Bernard")
    ];
    List<int> inviteIds = [];
    for (Invite invite in attendees) {
      int id = await dbHelper.insertInvite(invite);
      inviteIds.add(id);
    }

    // Ajouter des relations diner_invite
    List<Map<String, int>> dinerInvites = [
      {'diner_id': dinerIds[0], 'invite_id': inviteIds[0]},
      {'diner_id': dinerIds[0], 'invite_id': inviteIds[1]},
      {'diner_id': dinerIds[0], 'invite_id': inviteIds[2]},
      {'diner_id': dinerIds[0], 'invite_id': inviteIds[3]},
      {'diner_id': dinerIds[0], 'invite_id': inviteIds[1]},
      {'diner_id': dinerIds[1], 'invite_id': inviteIds[2]},
      {'diner_id': dinerIds[1], 'invite_id': inviteIds[3]},
      {'diner_id': dinerIds[2], 'invite_id': inviteIds[4]},
      {'diner_id': dinerIds[2], 'invite_id': inviteIds[5]}
    ];
    for (var relation in dinerInvites) {
      await dbHelper.insertDinerInvite(relation['diner_id']!, relation['invite_id']!);
    }

    // Ajouter des plats
    List<Plat> plats = [
      Plat(
        name: 'Spaghetti',
        description: 'Spaghetti bolognaise',
        ingredients: 'Pâtes, sauce tomate, viande hachée',
        recipe: '1. Cuire les pâtes\n2. Préparer la sauce\n3. Mélanger'
      ),
      Plat(
        name: 'Pizza',
        description: 'Pizza 4 fromages',
        ingredients: 'Pâte à pizza, mozzarella, gorgonzola, parmesan, emmental',
        recipe: '1. Préparer la pâte\n2. Ajouter les fromages\n3. Cuire'
      ),
      Plat(
        name: 'Salade',
        description: 'Salade César',
        ingredients: 'Salade, poulet, croûtons, parmesan, sauce César',
        recipe: '1. Préparer la salade\n2. Ajouter les ingrédients\n3. Assaisonner'
      ),
      Plat(
        name: 'Tarte',
        description: 'Tarte aux pommes',
        ingredients: 'Pâte brisée, pommes, sucre, beurre',
        recipe: '1. Préparer la pâte\n2. Éplucher les pommes\n3. Cuire'
      )
    ];
    List<int> platIds = [];
    for (Plat plat in plats) {
      int id = await dbHelper.insertPlat(plat);
      platIds.add(id);
    }

    // Ajouter des relations diner_plat
    List<Map<String, int>> dinerPlats = [
      {'diner_id': dinerIds[0], 'plat_id': platIds[0]},
      {'diner_id': dinerIds[1], 'plat_id': platIds[1]},
      {'diner_id': dinerIds[2], 'plat_id': platIds[2]},
      {'diner_id': dinerIds[2], 'plat_id': platIds[3]}
    ];
    for (var relation in dinerPlats) {
      await dbHelper.insertDinerPlat(relation['diner_id']!, relation['plat_id']!);
    }
  }

  Future<void> _showDinerDetailsDialog(int dinerId, BuildContext context) async {
    final diner = await dbHelper.queryDinerById(dinerId);
    final invites = await dbHelper.queryInvitesForDiner(dinerId);
    final inviteNames = invites.map((invite) => '${invite['first_name']} ${invite['name']}').toList();
    final plats = await dbHelper.queryPlatsForDiner(dinerId);
    final platNames = plats.map((plat) => plat['name']).toList();
    final recipes = plats.map((plat) => plat['recipe']).toList();

    final nameController = TextEditingController(text: diner['name']);
    final dateController = TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.parse(diner['date'])));
    final inviteControllers = inviteNames.map((name) => TextEditingController(text: name)).toList();
    final platControllers = platNames.map((name) => TextEditingController(text: name)).toList();
    final recipeControllers = recipes.map((recipe) => TextEditingController(text: recipe)).toList();

    bool isEditing = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Détails du dîner'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!isEditing) ...[
                      Text('Nom du dîner: ${nameController.text}'),
                      Text('Date: ${dateController.text}'),
                      SizedBox(height: 8.0),
                      Text(
                        'Invités:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...inviteNames.map((name) => Text('- $name')).toList(),
                      SizedBox(height: 8.0),
                      Text(
                        'Plats:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...platNames.map((name) => Text('- $name')).toList(),
                      if (recipes[0].isNotEmpty) ...[
                        SizedBox(height: 8.0),
                        Text(
                          'Recettes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipes.map((recipe) => Text('- $recipe')).toList(),
                      ],
                    ] else ...[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Nom du dîner'),
                      ),
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(labelText: 'Date (dd-MM-yyyy)'),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(diner['date']),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                            dateController.text = formattedDate;
                          }
                        },
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Invités:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...inviteControllers.map((controller) => TextField(
                        controller: controller,
                        decoration: InputDecoration(labelText: 'Invité'),
                      )),
                      TextButton(
                        child: Text('Ajouter un invité'),
                        onPressed: () {
                          setState(() {
                            inviteControllers.add(TextEditingController());
                          });
                        },
                      ),
                      if (platNames.isNotEmpty) ...[
                        SizedBox(height: 8.0),
                        Text(
                          'Plats:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...platControllers.asMap().entries.map((entry) {
                          int index = entry.key;
                          TextEditingController platController = entry.value;
                          return Column(
                            children: [
                              TextField(
                                controller: platController,
                                decoration: InputDecoration(labelText: 'Plat'),
                              ),
                              TextField(
                                controller: recipeControllers[index],
                                decoration: InputDecoration(labelText: 'Recette (optionnel)'),
                                maxLines: null, // Permettre un nombre illimité de lignes
                                keyboardType: TextInputType.multiline,
                              ),
                            ],
                          );
                        }).toList(),
                        TextButton(
                          child: Text('Ajouter un plat'),
                          onPressed: () {
                            setState(() {
                              platControllers.add(TextEditingController());
                              recipeControllers.add(TextEditingController());
                            });
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isEditing)
                  TextButton(
                    child: Text('Enregistrer'),
                    onPressed: () async {
                      final name = nameController.text;
                      final date = dateController.text;
                      final invites = inviteControllers.map((controller) => controller.text).toList();
                      final plats = platControllers.map((controller) => controller.text).toList();
                      final recipes = recipeControllers.map((controller) => controller.text).toList();

                      if (name.isEmpty || date.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Le nom et la date du dîner sont obligatoires.')),
                        );
                        return;
                      }

                      // Convertir la date au format attendu par la base de données
                      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
                      String dbFormattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

                      // Mettre à jour le dîner dans la base de données
                      final updatedDiner = Diner(id: dinerId, name: name, date: dbFormattedDate);
                      await dbHelper.updateDiner(updatedDiner);

                      // Mettre à jour les invités dans la base de données
                      await dbHelper.deleteInvitesForDiner(dinerId);
                      final inviteIds = <int>[];
                      for (var invite in invites) {
                        if (invite.isNotEmpty) {
                          final names = invite.split(' ');
                          final firstName = names[0];
                          final lastName = names.length > 1 ? names[1] : '';
                          final inviteObj = Invite(first_name: firstName, name: lastName);
                          final inviteId = await dbHelper.insertInvite(inviteObj);
                          inviteIds.add(inviteId);
                        }
                      }
                      for (var inviteId in inviteIds) {
                        await dbHelper.insertDinerInvite(dinerId, inviteId);
                      }

                      // Mettre à jour les plats dans la base de données
                      await dbHelper.deletePlatsForDiner(dinerId);
                      final platIds = <int>[];
                      for (int i = 0; i < plats.length; i++) {
                        if (plats[i].isNotEmpty) {
                          final platObj = Plat(name: plats[i], description: '', ingredients: '', recipe: recipes[i]);
                          final platId = await dbHelper.insertPlat(platObj);
                          platIds.add(platId);
                        }
                      }
                      for (var platId in platIds) {
                        await dbHelper.insertDinerPlat(dinerId, platId);
                      }

                      // Recharger les cartes de dîners
                      await _loadCards(context);

                      Navigator.of(context).pop();
                    },
                  ),
                if (!isEditing)
                  TextButton(
                    child: Text('Modifier'),
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadCards(BuildContext context, {String searchQuery = ""}) async {
    final diners = await dbHelper.queryAllDiners();
    final allDinerCards = <Widget>[];
    final allPlatCards = <Widget>[];

    for (var diner in diners) {
      final dinerId = diner['id'];
      final invites = await dbHelper.queryInvitesForDiner(dinerId);
      final inviteNames = invites.map((invite) => '${invite['first_name']} ${invite['name']}').toList();
      final plats = await dbHelper.queryPlatsForDiner(dinerId);

      final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(diner['date']));
      final matchesQuery = removeDiacritics(diner['name'].toLowerCase()).contains(searchQuery) ||
          inviteNames.any((name) => removeDiacritics(name.toLowerCase()).contains(searchQuery)) ||
          formattedDate.contains(searchQuery);

      if (matchesQuery) {
        for (var plat in plats){
          allPlatCards.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajoute un padding vertical entre les cartes
              child: GestureDetector(
                onTap: () {
                  _showDinerDetailsDialog(dinerId, context);
                },
                child: PlatCard(
                  name: plat['name'],
                  date: diner['date'],
                  attendees: inviteNames,
                  filter: _selectedFilter,
                ),
              ),
            ),
          );
        }
        allDinerCards.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajoute un padding vertical entre les cartes
            child: Dismissible(
              key: Key(dinerId.toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmer la suppression"),
                      content: Text("Voulez-vous vraiment supprimer ce dîner ?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text("Supprimer"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) async {
                await dbHelper.deleteDiner(dinerId);
                setState(() {
                  allDinerCards.removeWhere((widget) {
                    final padding = widget as Padding;
                    final dismissible = padding.child as Dismissible;
                    return dismissible.key == Key(dinerId.toString());
                  });
                  dinerCards = List.from(allDinerCards);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () {
                  _showDinerDetailsDialog(dinerId, context);
                },
                child: DinerCard(
                  name: diner['name'],
                  date: diner['date'],
                  attendees: inviteNames,
                  filter: _selectedFilter,
                ),
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      this.allDinerCards = allDinerCards;
      this.dinerCards = allDinerCards; // Initialement, toutes les cartes sont affichées
      this.platCards = allPlatCards;
    });
  }

  Future<void> _showAddCardDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final attendeesControllers = <TextEditingController>[];
    final platsControllers = <TextEditingController>[];
    final recipesControllers = <TextEditingController>[]; // Ajout des contrôleurs pour les recettes

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Ajouter un dîner'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nom du dîner'),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'Date (dd-MM-yyyy)'),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                          dateController.text = formattedDate;
                        }
                      },
                    ),
                    ...attendeesControllers.map((controller) => TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Invité'),
                    )),
                    TextButton(
                      child: Text('Ajouter un invité'),
                      onPressed: () {
                        setState(() {
                          attendeesControllers.add(TextEditingController());
                        });
                      },
                    ),
                    ...platsControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController platController = entry.value;
                      return Column(
                        children: [
                          TextField(
                            controller: platController,
                            decoration: InputDecoration(labelText: 'Plat'),
                          ),
                          TextField(
                            controller: recipesControllers[index],
                            decoration: InputDecoration(labelText: 'Recette (optionnel)'),
                            maxLines: null, // Permettre un nombre illimité de lignes
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      );
                    }).toList(),
                    TextButton(
                      child: Text('Ajouter un plat'),
                      onPressed: () {
                        setState(() {
                          platsControllers.add(TextEditingController());
                          recipesControllers.add(TextEditingController()); // Ajouter un contrôleur pour la recette
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text('Ajouter'),
                  onPressed: () async {
                    final name = nameController.text;
                    final date = dateController.text;
                    final attendees = attendeesControllers.map((controller) => controller.text).toList();
                    final plats = platsControllers.map((controller) => controller.text).toList();
                    final recipes = recipesControllers.map((controller) => controller.text).toList();

                    if (name.isEmpty || date.isEmpty) {
                      // Afficher un message d'erreur si le nom ou la date est vide
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le nom et la date du dîner sont obligatoires.')),
                      );
                      return;
                    }

                    // Convertir la date au format attendu par la base de données
                    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
                    String dbFormattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

                    // Ajouter le dîner à la base de données
                    final diner = Diner(name: name, date: dbFormattedDate);
                    final dinerId = await dbHelper.insertDiner(diner);

                    // Ajouter les invités à la base de données
                    final inviteIds = <int>[];
                    for (var attendee in attendees) {
                      if (attendee.isNotEmpty) {
                        final names = attendee.split(' ');
                        final firstName = names[0];
                        final lastName = names.length > 1 ? names[1] : '';
                        final invite = Invite(first_name: firstName, name: lastName);
                        final inviteId = await dbHelper.insertInvite(invite);
                        inviteIds.add(inviteId);
                      }
                    }

                    // Ajouter les relations diner_invite
                    for (var inviteId in inviteIds) {
                      await dbHelper.insertDinerInvite(dinerId, inviteId);
                    }

                    // Ajouter les plats à la base de données
                    final platIds = <int>[];
                    for (int i = 0; i < plats.length; i++) {
                      if (plats[i].isNotEmpty) {
                        final platObj = Plat(name: plats[i], description: '', ingredients: '', recipe: recipes[i]);
                        final platId = await dbHelper.insertPlat(platObj);
                        platIds.add(platId);
                      }
                    }

                    // Ajouter les relations diner_plat
                    for (var platId in platIds) {
                      await dbHelper.insertDinerPlat(dinerId, platId);
                    }

                    // Recharger les cartes de dîners
                    await _loadCards(context);

                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //_loadCards(context);
    _loadCards(context, searchQuery: removeDiacritics(searchQuery.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: Text("Guest Diary"),
        actions: [
           Padding(
            padding: EdgeInsets.only(right: 16.0), // Ajuste la valeur pour déplacer le bouton
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddCardDialog(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Rechercher par nom ou par date",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              items: <String>['Par Dîner', 'Par Plat']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: dinerCards.length,
          //     itemBuilder: (context, index) {
          //       return dinerCards[index];
          //     },
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedFilter == 'Par Plat' ? platCards.length : dinerCards.length,
              itemBuilder: (context, index) {
                if (_selectedFilter == 'Par Plat') {
                  return platCards[index];
                } else {
                  return dinerCards[index];
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
