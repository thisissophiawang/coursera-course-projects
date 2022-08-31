#include <iostream>
#include <cmath>
using namespace std;

const int ZERO = 0;
const int ONE = 1;
const int TWO = 2;

void printDivisors(int num);
//Prints the divisors for a given number

int main() {
    int num;

    cout << "Please enter a positive integer >= 2: ";
    cin >> num;
    if (num < TWO) {
        cout << "The number should be greater than 2\n";
        return ONE;
    }

    printDivisors(num);
    return ZERO;
}

void printDivisors(int num) {
    for (int n = 1; n < sqrt(num); n++) {
        if (num % n == ZERO) {
            cout << n << " ";
        }
    }

    for (int n = sqrt(num); n >= 1; n--) {
        if (num % n == ZERO) {
            cout << num / n << " ";
        }
    }
}
