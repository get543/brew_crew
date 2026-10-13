import 'package:flutter/material.dart';
import 'package:brew_crew/models/menu_item.dart';
import 'package:brew_crew/services/menu_service.dart';

class MenuManagement extends StatelessWidget {
  const MenuManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MenuService();
    return StreamBuilder<List<MenuItemModel>>(
      stream: service.allItems,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No menu items. Use the sparkle button to load examples.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              child: SwitchListTile(
                title: Text(item.itemName),
                subtitle: Text(
                  '\$${item.basePrice.toStringAsFixed(2)} | ${item.milkOptions.join(', ')}',
                ),
                value: item.isAvailable,
                onChanged: (value) => service.setAvailability(item.id, value),
                secondary: Text(item.isAvailable ? 'Live' : 'Off'),
              ),
            );
          },
        );
      },
    );
  }
}

class MenuManagementActions extends StatelessWidget {
  const MenuManagementActions({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MenuService();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Load example menu',
          icon: const Icon(Icons.auto_awesome),
          onPressed: () async {
            await service.seedExampleMenu();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Example menu loaded')),
              );
            }
          },
        ),
        IconButton(
          tooltip: 'Add menu item',
          icon: const Icon(Icons.add),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _AddMenuItemDialog(),
          ),
        ),
      ],
    );
  }
}

class _AddMenuItemDialog extends StatefulWidget {
  const _AddMenuItemDialog();

  @override
  State<_AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<_AddMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _milkController = TextEditingController(text: 'Whole milk, Oat milk');
  final _sugarsController = TextEditingController(text: '0, 1, 2, 3');

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _milkController.dispose();
    _sugarsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add menu item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => double.tryParse(value ?? '') == null ? 'Enter a price' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _milkController,
                decoration: const InputDecoration(labelText: 'Milk options, comma separated'),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _sugarsController,
                decoration: const InputDecoration(labelText: 'Sugar levels, comma separated'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final sugars = _sugarsController.text
                .split(',')
                .map((value) => int.tryParse(value.trim()))
                .whereType<int>()
                .toList();
            final milk = _milkController.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList();
            await MenuService().addItem(
              itemName: _nameController.text.trim(),
              basePrice: double.parse(_priceController.text),
              availableSugars: sugars.isEmpty ? [0] : sugars,
              milkOptions: milk.isEmpty ? ['Whole milk'] : milk,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
