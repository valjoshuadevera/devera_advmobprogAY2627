# devera_advmovprog_ay2627

**ephemeral vs app state The comments helped me understand what each part of the code does and why it's needed. I also learned the difference between using setState for temporary changes like the counter and Provider for managing the apps theme. Overall, the comments made the code easier to follow, especially for someone still learning Flutter.
 
 labact2
  
  The Product class stores ang details ng product tulad ng name, price, brand, at stock. The fromJson() method converts JSON data into Dart objects. Yung ibang classes naman ay para sa additional details tulad ng dimensions, reviews, at product metadata.
 labact 3 
 The CartScreen displays the cart ng user, including the product image, title, quantity, total, and discount. Kapag pinindot yung product, pupunta siya sa CartProductDetailScreen para makita yung complete details, including the price and discounted total. Dinagdag din sa Lab Act 3 yung pagkuha ng cart gamit ang user ID at yung Confirm Order button, na magpapakita ng success message kapag successful ang request or error message kapag may naging problem.