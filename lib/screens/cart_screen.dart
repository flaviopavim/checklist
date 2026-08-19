import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shopping_provider.dart';
import '../widgets/empty_state.dart';
import 'list_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeList = context.watch<ShoppingProvider>().activeList;

    if (activeList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carrinho')),
        body: const EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'Seu carrinho está vazio',
          message:
              'Adicione itens a partir das sugestões ou da aba de itens para começar uma nova compra.',
        ),
      );
    }

    return ListDetailScreen(listId: activeList.id);
  }
}
