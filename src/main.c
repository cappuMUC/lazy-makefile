#include <stdio.h>
#include "test.h"
#include "test2.h"

int main(int argc, char** argv)
{
#ifndef TESTING
	printf("Hello world!\r\n");
#else
	printf("Hello TESTING world!\r\n");
#endif
	foo();
	bar();
}
