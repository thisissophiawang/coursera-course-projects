#include <iostream>
using namespace std;
 
int main() {
 
    int num1, num2;
    int addition, subtraction, multiplication, div, mod;
    double division;
 
    cout << "Please enter two positive integers, separated by a space: " << endl;
 
    cin >> num1 >> num2;
 
    addition = num1 + num2;
    subtraction = num1 - num2;
    multiplication = num1 * num2;
    division = (double) num1 / (double) num2;
    div = num1 / num2;
    mod = num1 % num2;
 
    cout << num1 << " + " << num2 << " = " << addition<< endl;
    cout << num1 << " - " << num2 << " = " << subtraction<< endl;
    cout << num1 << " * " << num2 << " = " << multiplication<< endl;
    cout << num1 << " / " << num2 << " = " << division<< endl;
    cout << num1 << " div " << num2 << " = " << div<< endl;
    cout << num1 << " mod " << num2 << " = " << mod<< endl;
 
    return 0;
}