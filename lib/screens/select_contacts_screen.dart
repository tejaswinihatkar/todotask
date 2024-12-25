import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dnd_service.dart';

class SelectContactsScreen extends StatefulWidget {
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  Set<String> selectedContactIds = {};
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool isDNDEnabled = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _initialize() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final fetchedContacts = await ContactsService.getContacts();
      setState(() {
        contacts = fetchedContacts;
        filteredContacts = fetchedContacts;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Contacts permission denied';
        isLoading = false;
      });
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        final name = contact.displayName?.toLowerCase() ?? '';
        final phone = contact.phones?.first.value?.toLowerCase() ?? '';
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  Future<void> _toggleDND() async {
    if (selectedContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    final hasAccess = await DNDService.requestDNDAccess();
    if (!hasAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DND permission required')),
      );
      return;
    }

    setState(() {
      isDNDEnabled = !isDNDEnabled;
    });

    await DNDService.setDNDMode(
      enabled: isDNDEnabled,
      allowedContacts: selectedContactIds.toList(),
      allowedApps: [], // Add allowed apps if needed
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDNDEnabled ? 'DND Mode Enabled' : 'DND Mode Disabled'),
        backgroundColor: isDNDEnabled ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _toggleDND,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search contacts',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
 
            Expanded(
              child: Center(child: Text(errorMessage!)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final isSelected = selectedContactIds.contains(contact.identifier);
                  final phone = contact.phones?.first.value ?? 'No number';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(contact.displayName ?? 'No Name'),
                      subtitle: Text(phone),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedContactIds.add(contact.identifier!);
                            } else {
                              selectedContactIds.remove(contact.identifier);
                            }
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}