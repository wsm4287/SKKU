#include <stdio.h>

int a[30000];

void swap(int *x, int *y){
	int temp = *x;
	*x = *y;
	*y = temp;
}


int partition(int left, int right){
  int pivot;
  int low, high;

  low = left;
  high = right + 1;
  pivot = list[left]; 


  while(low < high){
    do {
      low++;
    } while (low<=right && list[low]<pivot);

    do {
      high--; 
    } while (high>=left && list[high]>pivot);
    if(low < high) swap(&list[low], &list[high]);

  }

  swap(&list[left], &list[high]);

  return high;
}

void quick(int left, int right){


  if(left<right){

    int q = partition(left, right); 

    quick(left, q-1);
    quick(q+1, right);
  }

}

int main(){

	int N;
	scanf("%d", &N);
	int i;
	for(i=0; i<N; i++) scanf("%d", &a[i]);


	quick(0,N-1);	

	for(i=0; i<N; i++) printf("%d ", a[i]);
	return 0;


}

