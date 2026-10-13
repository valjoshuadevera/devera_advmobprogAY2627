import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

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
            // Enhancement 2: Details page shows complete product information after a card is clicked.
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                height: 260.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image, size: 48.sp),
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: product.title,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 8.h),
            CustomText(text: product.description, fontSize: 14.sp),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                Chip(label: Text(product.category)),
                Chip(label: Text(product.availabilityStatus)),
                Chip(label: Text('Stock: ${product.stock}')),
              ],
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: '\$${product.price.toStringAsFixed(2)}',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Rating: ${product.rating.toStringAsFixed(1)}',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8.h),
            CustomText(text: product.warrantyInformation, fontSize: 13.sp),
            SizedBox(height: 4.h),
            CustomText(text: product.shippingInformation, fontSize: 13.sp),
          ],
        ),
      ),
    );
  }
}
