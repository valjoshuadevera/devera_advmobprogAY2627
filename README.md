# devera_advmovprog_ay2627

## ephemeral vs app state 
The comments helped me understand what each part of the code does and why it's needed. I also learned the difference between using setState for temporary changes like the counter and Provider for managing the apps theme. Overall, the comments made the code easier to follow, especially for someone still learning Flutter.
 


## Lab Activity 2

The Product class stores ang details ng product tulad ng name, price, brand, at stock. The `fromJson()` method converts JSON data into Dart objects. Yung ibang classes naman ay para sa additional details tulad ng dimensions, reviews, at product metadata.

## Lab Activity 3

The CartScreen displays the cart ng user, including the product image, title, quantity, total, and discount. Kapag pinindot yung product, pupunta siya sa CartProductDetailScreen para makita yung complete details, including the price and discounted total. Dinagdag din sa Lab Act 3 yung pagkuha ng cart gamit ang user ID at yung Confirm Order button, na magpapakita ng success message kapag successful ang request or error message kapag may naging problem.

## Lab Activity 4

The SignInScreen sends the username and password sa UserService para mag-login. The UserService calls the authentication API, converts the response into a User model, and saves the user details using SharedPreferences. Yung ProfileScreen naman ay kumukuha ng saved user data para ipakita ang name, username, image, email, gender, and ID. Natutunan ko rin kung paano gamitin yung saved user ID para makuha ang tamang cart ng user instead of using a hard-coded ID.flutter pub add firebase_core

## Lab Activity 5
Ang Lab Activity 5 ay tungkol sa pag-integrate ng DummyJSON at Firebase Authentication sa Flutter application. Sa DummyJSON, ginagamit pa rin ang existing login system kung saan ang username at password ay ipinapadala sa API para makuha ang user information, access token, at refresh token. Ang user ID na naka-save ay ginagamit din para makuha ang cart ng specific user.

Sa Firebase Authentication naman, puwedeng gumawa ng account at mag-login gamit ang email at password. Kapag successful ang login, sine-save ang importanteng user information tulad ng Firebase UID, email, display name, at session data para magamit sa profile at iba pang features ng application. May signup screen din para sa mga bagong user na gustong gumawa ng Firebase account.

Ang UserService ang nagsisilbing central service para sa authentication at account management. Dito hinahandle ang sign in, sign up, logout, pag-update ng username, pagpapalit ng password, at pag-delete ng account. Sa pamamagitan ng Firebase, mas madaling ma-manage ang user accounts at authentication sessions habang napapanatili ang existing DummyJSON features na kailangan sa laboratory activities.