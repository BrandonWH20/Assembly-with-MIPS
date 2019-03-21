------------------------
Lab 4: ASCII (HEX or 2SC) to Base 4 CMPE 012 Winter 2019
Holcombe, Brandon Bholcomb -------------------------
What was your approach to converting each ASCII input to two’s complement form?
Write the answer here.
the first step was converting from ascii to its actual binary value. 
converting binary to 2's comp was easy. I simply read each char, converted to the value (0 or 1)
and did a left logical shift, and then added that value. 
converting hex was harder, but it was essentially the same steps, except instead of 
shifting left 1 bit, I shifted left 4 bits. 
The next step was sign extending. my first attempt was trying to add the correct number to give 
me all the leading 1's. After that became terribly messy, I just did a logical shift, then an 
arithmetic shift. 

What did you learn in this lab? Write the answer here.
I learned accessing addresses and loading the value in that address are closely related, 
you simply cannot load a value if you don't have the address of which you want to load from. 
That was a little confusing at first.. Actually the whole time.
I thought using arrays would be a more crucial part of the lab, but was really only used in 
the final step. But the logic of traversing addresses lik one giant array helped. 

Did you encounter any issues? Were there parts of this lab you found enjoyable?
There were so many issues, I had no idea that I had to use logical shifts for the first few hours of working on this lab, and I was completely stumped on a lot of the converstion.

How would you redesign this lab to make it better? 
The lab seemed pretty fair, it did seem like it over generalized steps, but naybe thats just part of programming and life. Things are easier said than done. 

Did you collaborate with anyone on this lab? Please list who you collaborated with and the nature of your collaboration.
I worked with Danny Kaplan and Mark Kudryavtev, it was generally bouncing off ideas for ways we approached problems, and corner cases. 