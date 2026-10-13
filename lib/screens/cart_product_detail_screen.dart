import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../models/cart.dart';
import '../widgets/custom_text.dart';

class CartProductDetailScreen extends StatelessWidget {
  final CartProduct product;

  const CartProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: product.title, fontSize: 18.sp),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.thumbnail,
              width: double.infinity,
              height: 250.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            CustomText(
              text: product.title,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: '\$${product.price.toStringAsFixed(2)}',
              fontSize: 20.sp,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            CustomText(text: 'Quantity: ${product.quantity}', fontSize: 14.sp),
            SizedBox(height: 8.h),
            CustomText(
              text:
                  'Discount: ${product.discountPercentage.toStringAsFixed(0)}% off',
              fontSize: 14.sp,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Total: \$${product.total.toStringAsFixed(2)}',
              fontSize: 14.sp,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text:
                  'Discounted Total: \$${product.discountedTotal.toStringAsFixed(2)}',
              fontSize: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
