import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nguyenhuuduy_2224802010789_lab4/controllers/auth_services.dart';
import 'package:nguyenhuuduy_2224802010789_lab4/controllers/crud_services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Stream<QuerySnapshot> _stream;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    _stream = CRUDService().getContacts();
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }
  searchContacts(String search) {
    _stream = CRUDService().getContacts(searchQuery: search);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().logout().then((value) {
                Navigator.pushReplacementNamed(context, "/login");
              });
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add");
        },
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (value) {
                searchContacts(value);
              },
              focusNode: _searchFocusNode,
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Search"),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return snapshot.data!.docs.isEmpty
                    ? const Center(child: Text("No Contacts Found"))
                    : ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return ListTile(
                            onTap: () {
                            },
                            leading: CircleAvatar(
                              child: Text(data["name"][0].toUpperCase()),
                            ),
                            title: Text(data["name"]),
                            subtitle: Text(data["phone"]),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {},
                            ),
                          );
                        }).toList(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}