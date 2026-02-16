import 'dart:io';
import 'package:contact_app/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/database_service.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Contact _contact;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _refreshContact() async {
    final updatedContact = await _databaseService.getContact(_contact.id!);
    if (updatedContact != null && mounted) {
      setState(() {
        _contact = updatedContact;
      });
    }
  }

  // DELETE CONTACT FEATURE
  Future<void> _deleteContact() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${_contact.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoading = true);
      
      try {
        // Perform deletion
        await _databaseService.deleteContact(_contact.id!);
        
        if (mounted) {
          // Navigate back and indicate success
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_contact.name} deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting contact: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // EDIT CONTACT FEATURE
  Future<void> _editContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditContactScreen(contact: _contact),
      ),
    );
    
    if (result == true) {
      await _refreshContact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // TOGGLE FAVORITE
  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);
    
    final newFavoriteStatus = !_contact.isFavorite;
    await _databaseService.toggleFavorite(_contact.id!, newFavoriteStatus);
    await _refreshContact();
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newFavoriteStatus 
              ? 'Added to favorites' 
              : 'Removed from favorites'
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // CALL CONTACT
  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _contact.phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make phone call'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // SEND EMAIL
  Future<void> _sendEmail() async {
    if (_contact.email.isEmpty) return;
    
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: _contact.email,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send email'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // SEND SMS
  Future<void> _sendSMS() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: _contact.phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send message'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // OPEN MAPS
  Future<void> _openMaps() async {
    if (_contact.address == null || _contact.address!.isEmpty) return;
    
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: 'maps/search/',
      queryParameters: {'api': '1', 'query': _contact.address!},
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.name),
        actions: [
          // Favorite toggle button
          IconButton(
            icon: Icon(
              _contact.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _contact.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editContact,
          ),
          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteContact,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshContact,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // PROFILE SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Profile Image/Avatar
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                backgroundImage: _contact.photoUrl != null
                                    ? (_contact.photoUrl!.startsWith('http')
                                        ? NetworkImage(_contact.photoUrl!)
                                        : FileImage(File(_contact.photoUrl!)) as ImageProvider)
                                    : null,
                                child: _contact.photoUrl == null
                                    ? Text(
                                        _contact.name.isNotEmpty
                                            ? _contact.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              if (_contact.isFavorite)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Name
                          Text(
                            _contact.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          // Company/Job Title
                          if (_contact.company != null || _contact.jobTitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                [
                                  if (_contact.jobTitle != null && _contact.jobTitle!.isNotEmpty) 
                                    _contact.jobTitle!,
                                  if (_contact.company != null && _contact.company!.isNotEmpty) 
                                    'at ${_contact.company!}',
                                ].join(' '),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // QUICK ACTION BUTTONS
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              icon: Icons.phone_outlined,
                              label: 'Call',
                              onTap: _makePhoneCall,
                            ),
                            _buildActionButton(
                              icon: Icons.message_outlined,
                              label: 'Message',
                              onTap: _sendSMS,
                            ),
                            if (_contact.email.isNotEmpty)
                              _buildActionButton(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                onTap: _sendEmail,
                              ),
                            if (_contact.address != null && _contact.address!.isNotEmpty)
                              _buildActionButton(
                                icon: Icons.location_on_outlined,
                                label: 'Map',
                                onTap: _openMaps,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // CONTACT DETAILS CARD
                    Card(
                      child: Column(
                        children: [
                          // Phone
                          _buildDetailTile(
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            value: _contact.phoneNumber,
                            onTap: _makePhoneCall,
                          ),
                          
                          // Email (if available)
                          if (_contact.email.isNotEmpty) ...[
                            const Divider(height: 0),
                            _buildDetailTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: _contact.email,
                              onTap: _sendEmail,
                            ),
                          ],
                          
                          // Address (if available)
                          if (_contact.address != null && _contact.address!.isNotEmpty) ...[
                            const Divider(height: 0),
                            _buildDetailTile(
                              icon: Icons.location_on_outlined,
                              title: 'Address',
                              value: _contact.address!,
                              onTap: _openMaps,
                            ),
                          ],
                          
                          // Birthday (if available)
                          if (_contact.birthday != null) ...[
                            const Divider(height: 0),
                            _buildDetailTile(
                              icon: Icons.cake_outlined,
                              title: 'Birthday',
                              value: '${_contact.birthday!.day}/${_contact.birthday!.month}/${_contact.birthday!.year}',
                              onTap: null,
                            ),
                          ],
                          
                          // Company (if available)
                          if (_contact.company != null && _contact.company!.isNotEmpty) ...[
                            const Divider(height: 0),
                            _buildDetailTile(
                              icon: Icons.business_outlined,
                              title: 'Company',
                              value: _contact.company!,
                              onTap: null,
                            ),
                          ],
                          
                          // Job Title (if available)
                          if (_contact.jobTitle != null && _contact.jobTitle!.isNotEmpty) ...[
                            const Divider(height: 0),
                            _buildDetailTile(
                              icon: Icons.work_outlined,
                              title: 'Job Title',
                              value: _contact.jobTitle!,
                              onTap: null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: onTap != null
          ? IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: onTap,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}