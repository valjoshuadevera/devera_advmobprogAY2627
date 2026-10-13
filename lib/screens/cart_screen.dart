import 'package:devera_advmovprog_ay2627/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../widgets/custom_text.dart';
import 'cart_product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Future<List<Cart>> _cartsFuture;

  @override
  void initState() {
    super.initState();
    // Lab 3 Enhancement 3: Render one user's cart through the user-ID endpoint.
    _cartsFuture = CartService().getCartsByUserId(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Cart>>(
        future: _cartsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: 'Error: ${snapshot.error}',
                fontSize: 14.sp,
              ),
            );
          }

          final carts = snapshot.data ?? [];

          if (carts.isEmpty) {
            return Center(
              child: CustomText(text: 'No cart found.', fontSize: 14.sp),
            );
          }

          final cart = carts.first;

          return ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              CustomText(
                text: 'User #${cart.userId} Cart',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 14.h),
              ...cart.products.map((product) {
                return Card(
                  margin: EdgeInsets.only(bottom: 14.h),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12.r),
                    leading: Image.network(
                      product.thumbnail,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                    title: CustomText(
                      text: product.title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: CustomText(
                      text:
                          '${product.discountPercentage.toStringAsFixed(0)}% off - \$${product.total.toStringAsFixed(2)} total',
                      fontSize: 12.sp,
                    ),
                    trailing: CustomText(
                      text: product.quantity.toString(),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: () {
                      // Lab 3 Enhancement 1: Reuse the cart-product detail screen.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CartProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              }),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Subtotal:', fontSize: 14.sp),
                  CustomText(
                    text: '\$${cart.total.toStringAsFixed(2)}',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: 'Discounted Total:', fontSize: 14.sp),
                  CustomText(
                    text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Lab 3 Enhancement 3: Pass product values to add-to-cart.
                    await CartService().addCart(
                      userId: cart.userId,
                      productId: cart.products.first.id,
                      quantity: cart.products.first.quantity,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order confirmed successfully'),
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $error')));
                  }
                },
                child: const Text('Confirm Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}
