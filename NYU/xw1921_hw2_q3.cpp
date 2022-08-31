#include <iostream>
using namespace std;
 
const int MINUTES_IN_DAY = 1440;
const int MINUTES_IN_HOUR = 60;
 
int main() {
    int daysJohnWorked, daysBillWorked, hoursJohnWorked, hoursBillWorked, minutesJohnWorked, minutesBillWorked;
  
    int totalHoursWorked, totalMinutesWorked, totalDaysWorked, remainingTime, totalTimeInMinutes;
 
    cout << "Please enter the number of days John has worked: ";
    cin >> daysJohnWorked;
    cout << "Please enter the number of hours John has worked: ";
    cin >> hoursJohnWorked;
    cout << "Please enter the number of minutes John has worked: ";
    cin >> minutesJohnWorked;
 
    cout << endl;
 
    cout << "Please enter the number of days Bill has worked: ";
    cin >> daysBillWorked;
    cout << "Please enter the number of hours Bill has worked: ";
    cin >> hoursBillWorked;
    cout << "Please enter the number of minutes Bill has worked: ";
    cin >> minutesBillWorked;
 
    totalTimeInMinutes = ( (daysJohnWorked + daysBillWorked ) * MINUTES_IN_DAY  ) +  ( (hoursJohnWorked + hoursBillWorked) * MINUTES_IN_HOUR ) + minutesJohnWorked + minutesBillWorked;
 
    cout << endl;
 
    totalDaysWorked = totalTimeInMinutes / MINUTES_IN_DAY;
    remainingTime = totalTimeInMinutes % MINUTES_IN_DAY;
 
    totalHoursWorked =  remainingTime / MINUTES_IN_HOUR;
    remainingTime = remainingTime % MINUTES_IN_HOUR;
 
    totalMinutesWorked = remainingTime;
 
    cout << endl;
 
    cout << "The total time both of them worked together is: " << totalDaysWorked << " days, " << totalHoursWorked << " hours and " << totalMinutesWorked << " minutes." << endl;
 
    cout << endl;
 
    return 0;
}
