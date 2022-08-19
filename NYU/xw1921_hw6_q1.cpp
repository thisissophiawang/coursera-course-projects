//The Fibonacci numbers sequence, Fn, is defined as follows:
//F1 is 1, F2 is 1, and Fn = Fn-1 + Fn-2 for n = 3, 4, 5, ...

#include <iostream>
using namespace std;

const int ZERO = 0;
const int ONE = 1;
const int TWO = 2;

int fib(int n);
//Takes a number n and returns the nth fibonacci number.

int main() {
    int num, numElement;
    cout << "Please enter a positive integer: ";
    cin >> num;

    numElement = fib(num);
    cout << numElement << ", ";

    return ZERO;
}

int fib(int n) {
    int sum, previous1 = 1, previous2 = 1;

    if ((n == ONE) || (n == TWO)) {
        return ONE;
    }
    else {
        for (int i = 3; i <= n; i++) {
            sum = previous1 + previous2;
            previous1 = previous2;
            previous2 = sum;
        }
        return sum;
    }
}
