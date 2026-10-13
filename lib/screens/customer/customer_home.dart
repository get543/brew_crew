import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brew_crew/models/menu_item.dart';
import 'package:brew_crew/models/order.dart';
import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/providers/cart_provider.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:brew_crew/services/menu_service.dart';
import 'package:brew_crew/services/order_service.dart';

class CustomerHome extends StatefulWidget {
  final AppUser user;

  const CustomerHome({super.key, required this.user});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const titles = ['Coffee menu', 'Your cart', 'Order tracker'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_tab]),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: [
        _MenuTab(user: widget.user),
        _CartTab(user: widget.user),
        _TrackerTab(userId: widget.user.uid),
      ][_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_cafe), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Orders'),
        ],
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  final AppUser user;

  const _MenuTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItemModel>>(
      stream: MenuService().items,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Could not load the menu.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text('The menu is empty.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_cafe)),
                title: Text(item.itemName),
                subtitle: Text('\$${item.basePrice.toStringAsFixed(2)}'),
                trailing: FilledButton(
                  onPressed: () => _showCustomization(context, item, user),
                  child: const Text('Customize'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCustomization(
    BuildContext context,
    MenuItemModel item,
    AppUser user,
  ) async {
    final orderItem = await showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CustomizationSheet(item: item, user: user),
    );
    if (orderItem != null && context.mounted) {
      context.read<CartProvider>().add(orderItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.itemName} added to cart')),
      );
    }
  }
}

class _CustomizationSheet extends StatefulWidget {
  final MenuItemModel item;
  final AppUser user;

  const _CustomizationSheet({required this.item, required this.user});

  @override
  State<_CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<_CustomizationSheet> {
  late int sugars;
  late String milk;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    sugars = widget.item.availableSugars.contains(widget.user.defaultSugars)
        ? widget.user.defaultSugars
        : widget.item.availableSugars.first;
    milk = widget.item.milkOptions.contains(widget.user.defaultMilk)
        ? widget.user.defaultMilk
        : widget.item.milkOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.item.itemName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: sugars,
            decoration: const InputDecoration(labelText: 'Sugars'),
            items: widget.item.availableSugars
                .map((value) => DropdownMenuItem(value: value, child: Text('$value sugars')))
                .toList(),
            onChanged: (value) => setState(() => sugars = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: milk,
            decoration: const InputDecoration(labelText: 'Milk'),
            items: widget.item.milkOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() => milk = value!),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity'),
              Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$quantity'),
                  IconButton(onPressed: () => setState(() => quantity++), icon: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              OrderItem(
                menuItemId: widget.item.id,
                itemName: widget.item.itemName,
                quantity: quantity,
                unitPrice: widget.item.basePrice,
                sugars: sugars,
                milk: milk,
              ),
            ),
            child: Text('Add - \$${(widget.item.basePrice * quantity).toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  final AppUser user;

  const _CartTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty) {
      return const Center(
        child: Text('Your cart is empty. Add a coffee from the menu.'),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.local_cafe),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${item.sugars} sugars  •  ${item.milk}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton.filledTonal(
                                tooltip: 'Decrease quantity',
                                onPressed: () => cart.changeQuantity(index, item.quantity - 1),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('${item.quantity}'),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Increase quantity',
                                onPressed: () => cart.changeQuantity(index, item.quantity + 1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _editItem(context, index, item),
                                icon: const Icon(Icons.tune),
                                label: const Text('Edit'),
                              ),
                              IconButton(
                                tooltip: 'Remove item',
                                onPressed: () => cart.removeAt(index),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order total'),
                      Text(
                        '\$${cart.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await OrderService().placeOrder(
                          userId: user.uid,
                          customerName: user.name,
                          items: cart.items,
                        );
                        cart.clear();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order placed')),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Place order'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editItem(BuildContext context, int index, OrderItem item) async {
    final updatedItem = await showModalBottomSheet<OrderItem>(
      context: context,
      showDragHandle: true,
      builder: (_) => _EditCartItemSheet(item: item),
    );
    if (updatedItem != null && context.mounted) {
      context.read<CartProvider>().updateAt(index, updatedItem);
    }
  }
}

class _EditCartItemSheet extends StatefulWidget {
  final OrderItem item;

  const _EditCartItemSheet({required this.item});

  @override
  State<_EditCartItemSheet> createState() => _EditCartItemSheetState();
}

class _EditCartItemSheetState extends State<_EditCartItemSheet> {
  late int sugars;
  late String milk;

  static const milkOptions = ['No milk', 'Whole milk', 'Oat milk', 'Almond milk'];

  @override
  void initState() {
    super.initState();
    sugars = widget.item.sugars;
    milk = milkOptions.contains(widget.item.milk) ? widget.item.milk : milkOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit ${widget.item.itemName}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: sugars,
            decoration: const InputDecoration(labelText: 'Sugars'),
            items: List.generate(
              6,
              (value) => DropdownMenuItem(value: value, child: Text('$value sugars')),
            ),
            onChanged: (value) => setState(() => sugars = value!),
          ),
          DropdownButtonFormField<String>(
            initialValue: milk,
            decoration: const InputDecoration(labelText: 'Milk'),
            items: milkOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() => milk = value!),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(context, widget.item.copyWith(sugars: sugars, milk: milk)),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}

class _TrackerTab extends StatelessWidget {
  final String userId;

  const _TrackerTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoffeeOrder>>(
      stream: OrderService().customerOrders(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load your orders.'));
        }
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders yet. Place your first order from the menu.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _CustomerOrderCard(order: snapshot.data![index]);
          },
        );
      },
    );
  }
}

class _CustomerOrderCard extends StatelessWidget {
  final CoffeeOrder order;

  const _CustomerOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderName, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        'Order #${order.orderNumber}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _CustomerStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            _OrderProgress(status: order.status),
            const Divider(height: 24),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${item.itemName} · ${item.sugars} sugars · ${item.milk}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.titleSmall),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerStatusChip extends StatelessWidget {
  final String status;

  const _CustomerStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      'pending' => scheme.tertiary,
      'brewing' => scheme.primary,
      'ready' => scheme.secondary,
      'completed' => scheme.outline,
      _ => scheme.outline,
    };
    return Chip(
      avatar: Icon(Icons.circle, size: 9, color: color),
      label: Text(_statusLabel(status)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _statusLabel(String value) {
    return switch (value) {
      'pending' => 'Pending',
      'brewing' => 'Brewing',
      'ready' => 'Ready',
      'completed' => 'Completed',
      _ => value,
    };
  }
}

class _OrderProgress extends StatelessWidget {
  final String status;

  const _OrderProgress({required this.status});

  @override
  Widget build(BuildContext context) {
    const steps = ['Pending', 'Brewing', 'Ready'];
    final currentStep = switch (status) {
      'brewing' => 1,
      'ready' || 'completed' => 2,
      _ => 0,
    };
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Column(
            children: [
              Icon(
                index <= currentStep ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: index <= currentStep ? scheme.secondary : scheme.outlineVariant,
              ),
              const SizedBox(height: 4),
              Text(steps[index], style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          if (index < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
                color: index < currentStep ? scheme.secondary : scheme.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}
