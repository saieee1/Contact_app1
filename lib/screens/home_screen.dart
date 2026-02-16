import 'package:contact_app/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../services/database_service.dart';
import '../widgets/contact_list_item.dart';
import 'add_edit_contact_screen.dart';
import 'contact_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  List<Contact> _contacts = [];
  List<Contact> _favoriteContacts = [];
  List<Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final contacts = await _databaseService.getAllContacts();
    final favorites = await _databaseService.getFavoriteContacts();
    setState(() {
      _contacts = contacts;
      _favoriteContacts = favorites;
      _filteredContacts = _currentIndex == 0 ? contacts : favorites;
    });
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _currentIndex == 0 ? _contacts : _favoriteContacts;
      });
    } else {
      setState(() {
        final sourceList = _currentIndex == 0 ? _contacts : _favoriteContacts;
        _filteredContacts = sourceList.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
              contact.phoneNumber.contains(query) ||
              contact.email.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: AnimationLimiter(
        child: _filteredContacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentIndex == 0
                          ? Icons.contacts_outlined
                          : Icons.favorite_outline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentIndex == 0
                          ? 'No contacts yet'
                          : 'No favorite contacts',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentIndex == 0)
                      TextButton(
                        onPressed: () => _navigateToAddContact(),
                        child: const Text('Add your first contact'),
                      ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: ContactListItem(
                          contact: _filteredContacts[index],
                          onTap: () => _navigateToContactDetail(_filteredContacts[index]),
                          onFavoriteToggle: () => _toggleFavorite(_filteredContacts[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddContact,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _filteredContacts = index == 0 ? _contacts : _favoriteContacts;
            _searchController.clear();
            _isSearching = false;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(Contact contact) async {
    final newFavoriteStatus = !contact.isFavorite;
    await _databaseService.toggleFavorite(contact.id!, newFavoriteStatus);
    await _loadContacts();
  }

  void _navigateToAddContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditContactScreen(),
      ),
    );
    if (result == true) {
      await _loadContacts();
    }
  }

  void _navigateToContactDetail(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailScreen(contact: contact),
      ),
    );
    if (result == true) {
      await _loadContacts();
    }
  }
}