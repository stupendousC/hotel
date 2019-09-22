1. What classes does each implementation include? Are the lists the same?
  Both A & B have 3 classes: CartEntry, ShoppingCart, and Order.  They have the same attributes but different methods.

2. Write down a sentence to describe each class.
  CartEntry instances correspond to an individual item and the purchase qty.
  ShoppingCart instances consists of a list of CartEntry instances, so it's really just the same as a real-life shopping cart.
  Order consist of one ShoppingCart instance, but also has a method that adds up the grand total price, which includes tax.

3. How do the classes relate to each other? It might be helpful to 4. draw a diagram on a whiteboard or piece of paper.
  CartEntry to ShoppingCart is many to 1.
  ShoppingCart to Order is 1 to 1.

5. What data does each class store? How (if at all) does this differ between the two implementations?
  Attributes for both A & B are the same
  CartEntry attribs: @unit_price and @quantity
  ShoppingCart attribs: @entries
  Order attribs: @cart

6. What methods does each class have? How (if at all) does this differ between the two implementations?
  Methods are where A & B differ...
  A has only 1 method, which is a total_price in the Order class.
  B has a price() in all 3 classes, which is better than A at SRP and keeping things loosely coupled.

7. Consider the Order#total_price method. In each implementation:

7.1. Is logic to compute the price delegated to "lower level" classes like ShoppingCart and CartEntry, or is it retained in Order?
  For A, the logic is dependent on knowledge on 'lower level' classes (need to know existence of @unit_price and @quantity in CartEntry instances). For B, the logic only depends on knowig the existence of the .price() method of the Cart instance.  

7.2. Does total_price directly manipulate the instance variables of other classes?
  For A, yes because it needs to directly access @unit_price and @qty from CartEntry.
  For B, yes because it needs to directly access price() in ShoppingCart.

8. If we decide items are cheaper if bought in bulk, how would this change the code? Which implementation is easier to modify?
Which implementation better adheres to the single responsibility principle?
  If the price for each item's subtotal changes depending on the qty, it would be a lot easier to calculate that for each CartEntry rather than wait till the end, so I prefer B.  By changing just the CartEntry.price() in B, it will keep the code cleaner. Any future changes in how that discount is implemented will only need to be taken care of within CartEntry, and we wouldn't have to worry about how it's going to ripple across ShoppingCart and Order codes.
  
9. Bonus question once you've read Metz ch. 3: Which implementation is more loosely coupled?
  B.


HOTEL discussion
1. Identify one place in your Hotel project where a class takes on multiple roles, or directly modifies the attributes of another class. 
  HotelFrontDesk, but it really has to, because someone has to bring all the diff classes together somehow.  

2. Describe in design-activity.md what changes you would need to make to improve this design, and how the resulting design would be an improvement.
  Jared pointed out a wacky redundancy in HotelFrontDesk.make_block, in the new_nightly_rate validation block, where I unnecessarily added a new instance variable that I didn't even use, I was just confused because that method dealt with pretty much ALL the classes and I got confused.  

  I really like how my codes for Block, Date_range, Reservation, and Room are pretty isolated and minimally dependent on each other.  However, because of that, my HotelFrontDesk feels rather bloated because it's left with the responsibility of tying everybody together.  For HotelFrontDesk, I have 14 methods in all, now I have time to DRY things up.  For starters, I could've DRY'd up all the validation codes instead of spelling everything out in each of these 14 methods, so that's what I'm going to do.