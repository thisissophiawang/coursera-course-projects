//
//  main.cpp
//  xw1921_hw6_q2
//
//  Created by xinyi wang on 8/19/22.
//

#include <iostream>
using namespace std;

const int ONE = 1;
const int ZERO = 0;
const int TWO = 2;

void printShiftedTriangle(int n, int m, char symbol);
//Prints an n-line triangle, filled with symbol characters, shifted m spaces from the left
//margin.

void printPineTree (int n, char symbol);
//Prints a sequence of n triangles of increasing sizes filled with symbol character

int main() {
    int triangleCount;
    char symbol;

    cout << "Please enter the number of triangles in the tree: ";
    cin >> triangleCount;
    cout << "Please enter the character to fill the tree (eg: *, +, $, etc): ";
    cin >> symbol;

    printPineTree(triangleCount, symbol);
    return ZERO;
}

void printPineTree(int n, char symbol) {

    for (int triangleCount = 1, triangleSize = 2, marginSpace = n - ONE;
    triangleCount <= n; triangleSize++, triangleCount++, marginSpace--) {
        printShiftedTriangle(triangleSize, marginSpace, symbol);
    }
}

void printShiftedTriangle(int n, int m, char symbol) {
    int totalCharacters = (TWO * n) - ONE;
    int characterCount = 1, spaceCount = (totalCharacters - characterCount) / 2;

    for (int lineNumber = 1; lineNumber <= n; lineNumber++) {
        for (int marginSpace = ONE; marginSpace <= m; marginSpace++) {
            cout << " ";
        }

        for (int leftSpace = 1; leftSpace <= spaceCount; leftSpace++) {
            cout << " ";
        }

        for (int character = 1; character <= characterCount; character++) {
            cout << symbol;
        }

        for (int rightSpace = 1; rightSpace <= spaceCount; rightSpace++) {
            cout << " ";
        }

        cout << endl;
        characterCount += 2;
        spaceCount--;
    }

}
