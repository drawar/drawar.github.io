---
layout: post
title:  "Counting Inversions - C++"
date:   2017-06-05
tags: algo cpp
comments: true
---

This is my implementation of the counting inversions algorithm for Stanford's MOOC [course on algorithm design and analysis][coursera]. One application of this algorithm is the analysis of rankings, where a numer of websites make use of a technique known as *collaborative filtering* to try to match your preferences for books, movies, restaurants, etc. with those of other people in their database. Once a website has identified people with similar taste to you, it can recommend new things that these people have liked. Amazon.com's recommendation engine ("Customers who bought this also bought...") is a perfect example of this.

First, let's define what an inversion is. For an array a and indices i < j, i, j form an inversion if a[i] > a[j]. A naive algorithm will make pairwise comparisons of array elements to figure out inversions but this will run in O(n^2) time where *n* is the size of the input array. We can do better than that by piggybacking on the merge sort algorithm, or to be exact, the merge subroutine in merge sort. The idea is everytime an element from the left subarray is appended to the output, no new inversions are encountered, since that element is smaller than everything remaining in the right subarray.  However, if an element from the right subarray is appended to the output, then it is smaller than all the remaining items in the left subarray, hence we increase the number of count of inversions by the number of elements remaining in the left subarray.

{% highlight cpp %}

#include <iostream>
#include <fstream>

using namespace std;

long int countSplitInv(int a[], int low, int mid, int high);

long int countInv(int a[], int low, int high) {
  if (low < high) {
    long int mid = low + (high - low)/2;
    long int left_inv = countInv(a, low, mid);
    long int right_inv = countInv(a, mid+1, high);
    long int split_inv = countSplitInv(a, low, mid, high);
    return left_inv + right_inv + split_inv;
  }
  return 0;
}

long int countSplitInv(int a[], int low, int mid, int high) {
  int n1 = mid - low + 1;
  int n2 = high - mid;
  
  int *left_a = new int[n1];
  int *right_a = new int[n2];
  
  for (int i = 0; i < n1; i++) 
    left_a[i] = a[low + i];
  for (int i = 0; i < n2; i++)
    right_a[i] = a[mid + 1 + i];
  
  int i = 0, j = 0;
  int k = low;
  long int count = 0;
  
  while (i < n1 && j < n2) {
    if (left_a[i] <= right_a[j]) {
      a[k] = left_a[i];
      i++;
    }
    
    else {
      a[k] = right_a[j];
      j++;
      count += n1 - i;
    }
    k++;
  }
  
  while (i < n1) {
    a[k] = left_a[i];
    k++;
    i++;
  }
  
  while (j < n2) {
    a[k] = right_a[j];
    k++;
    j++;
    count += n1 - i;
  }
  
  delete [] left_a;
  delete [] right_a;
  
  return count;
}

int main(int argc, char *argv[]) {
  int a[100000];
  int num;
  int i = 0;
  ifstream myfile (argv[1]);
  if (myfile.is_open())
  {
    while (myfile >> num)
    {
      a[i] = num;
      i++;
    }
    myfile.close();
  }
  long int count = countInv(a,0,100000);
  cout << count << '\n';
  return 0;
}

{% endhighlight %}


[coursera]: https://www.coursera.org/learn/algorithms-divide-conquer/home/welcome


