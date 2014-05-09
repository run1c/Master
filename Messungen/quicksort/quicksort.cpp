#include <stdio.h>

void qsort(int* list, int l, int h, int n, int max);

int main(){
	int unsorted[] = {1,8,2,5,1,3,5,9,6,0,4};
	int n = sizeof(unsorted)/sizeof(int);

	printf("Trying to sort %i elements...\n", n);
	qsort(unsorted, 0, n-1, 4, n-1);

	for (int i = 0; i < n; i++)
		printf("%i ", unsorted[i]);
	printf("\n");

	return 0;
}

void qsort(int* list, int l, int h, int n, int max){

	if (h < (max - n))
		return;

	if (l < h){	// termination condition: If the list has only one element left, the list is sorted
	
		// pivot is the last element in the list
		int pivot = list[h];
		int i = l, j = h - 1, buf = 0;

		printf("Sorting list [%i..%i] - ", l, h);
		
		while(i < j){
			// look for an element smaller than the pivot
			while ( (list[i] <= pivot) && (i < h) )
				i++;
			// look for an element bigger than the pivot
			while ( (list[j] > pivot) && (j > l) )
				j--;
			// put lower element in lower list and upper element in upper list by swapping
			if (i < j){
				buf = list[j];
				list[j] = list[i];
				list[i] = buf;
			}
				
		}	// now the list is divided; all elements smaller than the pivot are in list[l..i] and the others are in list[j..h]

		// put the pivot on the upper end of the lower list if neccessary
		if (list[i] > pivot){
			buf = list[i];
			list[i] = pivot;
			list[h] = buf;
		}
	
		for (int k = l; k <= h; k++)
			printf("%i ", list[k]);
		printf("\n");

		// recursion without the pivot!
		qsort(list, j+1, h, n, max);
		qsort(list, l, i-1, n, max);

	}

	return;
}
