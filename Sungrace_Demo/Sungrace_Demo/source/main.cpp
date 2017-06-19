#include "pchDemo.h"
#include "Application.h"

Ogre::map<String, String>::type		g_mapCmdArgByValue;

bool ParseCmdLineArgs(int argc, char **argv)
{
	for (int i = 1; i < argc; i++)
	{
		Ogre::String strKey(argv[i]);
		Ogre::String strValue;
		if (Ogre::StringUtil::startsWith(strKey, "-"))
		{
			strKey = strKey.substr(1, strKey.length());
			strValue = argv[++i];
			Ogre::StringUtil::toLowerCase(strKey);
			g_mapCmdArgByValue[strKey] = strValue;
		}
	}
	return true;
}

Ogre::String GetCommadLineArg(Ogre::String strKey)
{
	Ogre::StringUtil::toLowerCase(strKey);
	return g_mapCmdArgByValue[strKey];
}

bool GetCommadLineArgAsBool(Ogre::String strKey)
{
	Ogre::String strValue = GetCommadLineArg(strKey);
	Ogre::StringUtil::toLowerCase(strValue);
	return Ogre::StringConverter::parseBool(strValue);
}

void main(int argc, char ** argv)
{
	if (!ParseCmdLineArgs(argc, argv))
		return;

	CApplication * pApp = new CApplication(GetCommadLineArgAsBool("sunlight"), GetCommadLineArgAsBool("pointlights"));
	pApp->Run();

	delete pApp;
}