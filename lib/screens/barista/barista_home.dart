import 'package:flutter/material.dart';
import 'package:brew_crew/models/order.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:brew_crew/services/order_service.dart';
import 'package:brew_crew/screens/barista/menu_management.dart';

class BaristaHome extends StatefulWidget {
  const BaristaHome({super.key});

  @override
  State<BaristaHome> createState() => _BaristaHomeState();
}

class _BaristaHomeState extends State<BaristaHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Incoming orders' : 'Manage menu'),
        actions: [
          if (_selectedIndex == 1) const MenuManagementActions(),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? const _OrdersView() : const MenuManagement(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoffeeOrder>>(
      stream: OrderService().activeOrders,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text('No active orders.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => _OrderCard(order: snapshot.data![index]),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CoffeeOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final nextStatus = order.status == 'pending' ? 'brewing' : 'ready';
    final nextLabel = order.status == 'pending' ? 'Start brewing' : 'Mark ready';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.receipt_long),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text('Order : #${order.orderNumber}'),
                      const SizedBox(height: 2),
                      Text('Name : ${order.customerName}'),
                    ],
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const Divider(height: 28),
            Text('What to prepare :', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _OrderDetailChip(label: '${item.sugars} sugars'),
                              _OrderDetailChip(label: item.milk),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '\$${order.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            if (order.status != 'ready')
              FilledButton(
                onPressed: () => OrderService().updateStatus(order.id, nextStatus),
                child: Text(nextLabel),
              ),
            if (order.status == 'ready')
              OutlinedButton(
                onPressed: () => OrderService().updateStatus(order.id, 'completed'),
                child: const Text('Complete order'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      'pending' => scheme.tertiary,
      'brewing' => scheme.primary,
      'ready' => scheme.secondary,
      _ => scheme.outline,
    };
    return Chip(
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text(status.toUpperCase()),
    );
  }
}

class _OrderDetailChip extends StatelessWidget {
  final String label;

  const _OrderDetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
