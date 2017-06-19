#include "pchDemo.h"
#include "Application.h"
#include "FrameListener.h"

CApplication::CApplication(bool _bSunLight, bool _bPointLights)
{
	m_bSunLight = _bSunLight;
	m_bPointLights = _bPointLights;
}

CApplication::~CApplication()
{
	if (m_pFrameListener)
		OGRE_DELETE m_pFrameListener;

	if (m_pRenderWindow)
		m_pRenderWindow->setHidden(true);

	m_pSceneManager->destroyCamera(m_pCamera);

	if (m_pRoot)
		OGRE_DELETE m_pRoot;
}

bool CApplication::Init()
{
	Ogre::String strPluginsConfig;

#ifdef _DEBUG
	strPluginsConfig = "plugins_debug.cfg";
#else
	strPluginsConfig = "plugins_release.cfg";
#endif
	
	m_pRoot = OGRE_NEW Ogre::Root(GetMediaPath() + "ogreconfigs/" + strPluginsConfig, GetMediaPath() + "ogreconfigs/ogre.cfg", "ogre.log");
	m_pRoot->restoreConfig();
	m_pRoot->initialise(false);

	Ogre::NameValuePairList miscParam;
	Ogre::ConfigOptionMap renderSystemConfig = m_pRoot->getRenderSystem()->getConfigOptions();

	miscParam["displayFrequency"] = renderSystemConfig["Display Frequency"].currentValue;
	miscParam["vsync"] = "yes";
	miscParam["FSAA"] = "8";
	miscParam["FSAAHint"] = "Quality";
	miscParam["border"] = "fixed";
	miscParam["hidden"] = "false";

	m_pRenderWindow = m_pRoot->createRenderWindow("Sungrace_demo", 1280, 720, false, &miscParam);

	m_pRenderWindow->setVSyncEnabled(false);

	m_pSceneManager = m_pRoot->createSceneManager(Ogre::ST_GENERIC, "ExampleSMInstance");

	// Create the camera
	m_pCamera = m_pSceneManager->createCamera("PlayerCam");

	m_pCamera->setPosition(Ogre::Vector3(0, 300, 400));
	m_pCamera->lookAt(Ogre::Vector3(0, 0, 0));
	m_pCamera->setNearClipDistance(5);

	// Create one viewport, entire window
	Viewport * pViewport = m_pRenderWindow->addViewport(m_pCamera);
	pViewport->setBackgroundColour(Ogre::ColourValue(0.0f, 0.0f, 0.10f));

	// Alter the camera aspect ratio to match the viewport
	m_pCamera->setAspectRatio(Real(pViewport->getActualWidth()) / Real(pViewport->getActualHeight()));

	// Initialise, parse scripts etc
	//ResourceGroupManager::getSingleton().initialiseAllResourceGroups();

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "shared", "FileSystem", "shared", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("shared");

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "cubenew", "FileSystem", "cubenew", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("cubenew");

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "ground", "FileSystem", "ground", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("ground");

	CreateScene();

	m_pFrameListener = new CFrameListener(m_pRenderWindow, m_pCamera);
	m_pRoot->addFrameListener(m_pFrameListener);

	return true;
}

void CApplication::Run()
{
	if (Init() == false)
		return;

	m_pRoot->startRendering();
}

void CApplication::CreateScene()
{
	m_pSceneManager->setAmbientLight(ColourValue(0.2f, 0.2f, 0.2f));

	Ogre::SceneNode * pNode = nullptr;
	Light * light = nullptr;

	CreateCube(Ogre::Vector3(0.0f, 50.05f, 0.0f));
	CreateCube(Ogre::Vector3(0.0f, 150.10f, 0.0f), true);
	CreateCube(Ogre::Vector3(100.05f, 50.05f, 0.0f), true);
	CreateCube(Ogre::Vector3(100.05f, 150.10f, 0.0f), true);

	if (m_bSunLight)
	{
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(0.3f, 0.3f, 0.2f, 1.0f));
		light->setPosition(Ogre::Vector3(0.0f, 100.0f, 0.0f));
		light->setDirection(Ogre::Vector3(-1.0f, -1.0f, 0.5f));
		light->setType(Light::LT_DIRECTIONAL);
	}
	
	if (m_bPointLights)
	{
		pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(300.f, 50.0f, 200.0f));
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(0.3f, 0.6f, 0.3f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.03f, 0.06f, 0.03f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(300.f, 1.0f, 0.045f, 0.0075f);
		pNode->attachObject(light);

		pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(-300.0f, 250.0f, 200.0f));
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(0.5f, 0.3f, 0.3f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.0f, 0.0f, 0.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(400.f, 1.0f, 0.045f, 0.0075f);
		pNode->attachObject(light);

		pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(00.0f, 200.0f, -50.0f));
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(0.2f, 0.2f, 0.5f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.0f, 0.0f, 0.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(500.f, 1.0f, 0.45f, 0.75f);
		pNode->attachObject(light);
	}

	pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 0.0f, 0.0f));
	Entity * ground = m_pSceneManager->createEntity("ground", "ground.mesh");
	ground->setRenderQueueGroupAndPriority(RENDER_QUEUE_MAIN, 1);
	pNode->setScale(100.0f, 1.0f, 100.0f);
	pNode->attachObject(ground);
}

void CApplication::CreateCube(const Ogre::Vector3 & vPos, bool bHideFrontFace)
{
	static int iIndex = 0;
	
	char szEntityName[100];
	sprintf_s(szEntityName, "cube_%d", iIndex++);
	Ogre::String strEntityName(szEntityName);

	Ogre::SceneNode * pNode = nullptr;
	pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(vPos);
	Entity * cube = m_pSceneManager->createEntity(strEntityName, "cube.mesh");
	if(bHideFrontFace)
		cube->getSubEntity(0)->setVisible(false);
	cube->setRenderQueueGroup(RENDER_QUEUE_MAIN);
	pNode->attachObject(cube);
}

Ogre::String CApplication::GetMediaPath()
{
	String strVarName("MEDIA_PATH");
	char value[1024];
	size_t size;
	getenv_s(&size, value, 1024, strVarName.c_str());
	Ogre::String strPath = Ogre::String(value);
	if (strPath.empty())
	{
		assert("Environment variable 'MEDIA_PATH' is not mentioned!\n" "Hint : MEDIA_PATH=$(ProjectDir)../media/");
	}
	return strPath;
}
