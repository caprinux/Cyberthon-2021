#include <stdlib.h>
#include <stdio.h>

int main()
{
  int i;
  int lol;
  for ( i = 0; i <= 4; ++i ) { 
    lol = rand() & 0xF;
    printf("%d\n", lol);
  }

}

