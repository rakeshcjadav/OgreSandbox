#include "pchDemo.h"
#include "Application.h"

void main()
{
	CApplication * pApp = new CApplication();
	pApp->Run();

	delete pApp;
}