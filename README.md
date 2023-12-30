## INTRODUCTION
Introducing an innovative laundry application that aims to revolutionize and streamline the laundry management routine effortlessly. This open-source project is meticulously crafted to simplify and elevate the process of laundry ordering and business control, boasting a user-friendly interface and a plethora of convenient features.

## INSTALLATION
Go to the **<> Code** button and copy the project [link](https://github.com/robbyyehezkiel/Suitmedia-Application) . <br>
![Clone](https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/7a1e8df3-3b68-46b1-b718-c3fa010d1cc8)<br>
Open terminal or command prompt on your local machine. <br>

Use the **git clone command** followed by the URL you copied.
```
git clone https://github.com/robbyyehezkiel/Suitmedia-Application.git
```

## FEATURE
 1. Palindrome validation: Create and manage palindrome input forms to validate whether the input is a palindrome or not.
 2. API Handle: Implement API handle to show all users list with first & last name, email, avatar json parse.
 3. Screen Navigation: Implements intent data navigation from user input and also handles clicks
 4. Unit Testing: Testing for palindrome

## EXAM CRITERIA

1. **Application Overview**
   - This application consists of 3 screens.

2. **First Screen**
   + It has two `inputText`s and two buttons.
   + One `inputText` for name input and the other for input sentence text to check whether the sentence is a palindrome.<br>
     Example: 
     - `isPalindrome(“kasur rusak”) -> true`
     - `isPalindrome(“step on no pets”) -> true`
     - `isPalindrome(“put it up”) -> true`
     - `isPalindrome(“suitmedia”) -> false`
   + A button with a “Check” title below the inputTexts
   + Show as dialog with message “isPalindrome” if it’s palindrome and message “not   palindrome” if it’s not palindrome when clicking the button check
   + And a button with a “Next” title below the Check Button.
   + Go to the Second Screen when clicking the Next button.

4. **Second Screen**
   * It has a static “Welcome” text label/text view.
   * Two dynamic labels/text views to show the name from the first screen and the selected user name.
   * It has a button “Choose a User”.
   * Action click button “Choose a User” to go to the Third Screen.

5. **Third Screen**
   * It has a List/Table view of Users.
   * Collect data from the API from regres.in with email, first_name, last_name & avatar.
   * Add a pull-to-refresh and load the next page when scrolling to the bottom of the list. Prepare an empty state if the data is empty. Use the API with additional parameters `page` & `per_page` to get the next page data.
   * When a User on an item list is clicked, the Selected User Name label in the “Second Screen” will be replaced by the selected User’s name (don’t create a new screen, just continue the current screen).

6. **Illustration Wireframe Design**
   - Refer to the attached wireframe for design details.
   - https://www.figma.com/file/0QV3L03QMWI3p6g2DE97x9/KM-Test?node-id=0%3A1
   
7. **App Information**
   - This application is created using Flutter version 3.13.9.
   - Dependencies:
     - http: ^1.1.0
     - google_fonts: ^6.1.0
     - path_provider: ^2.1.1
     - logger: ^2.0.2+1

## SCREENSHOT!
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/afb94b14-2aea-4dad-a3ba-919f788ffe04" alt="Screenshot_20231228_234319" width="200">
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/61846dfb-bf09-4cc6-bdc4-be5206e07b7c" alt="Screenshot_20231228_234336" width="200">
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/a4fe011a-fe54-473b-8fff-9e143a5e67ec" alt="Screenshot_20231228_234343" width="200"><br>
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/1b47eb65-7f57-4feb-9b68-9225bbb23585" alt="Screenshot_20231228_234351" width="200">
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/580a5743-8538-4847-beef-6dd13d144285" alt="Screenshot_20231228_234408" width="200">
<img src="https://github.com/robbyyehezkiel/Suitmedia-Application/assets/107051384/a84586b2-f1a0-43a3-b1ac-f2b83ea5e4d2" alt="Screenshot_20231228_234400" width="200">

