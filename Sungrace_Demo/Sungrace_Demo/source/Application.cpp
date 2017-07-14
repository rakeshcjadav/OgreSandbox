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
	if (m_bSunLight || m_bPointLights)
		m_pSceneManager->setAmbientLight(ColourValue(0.10f, 0.10f, 0.10f));
	else
		m_pSceneManager->setAmbientLight(ColourValue(1.0f, 1.0f, 1.0f));

	Ogre::SceneNode * pNode = nullptr;
	Light * light = nullptr;

	CreateCube(Ogre::Vector3(0.0f, 50.0f, 0.0f));
	CreateCube(Ogre::Vector3(0.0f, 150.0f, 0.0f));
	CreateCube(Ogre::Vector3(100.0f, 50.0f, 0.0f));
	CreateCube(Ogre::Vector3(100.0f, 150.0f, 0.0f));

	if (m_bSunLight)
	{
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(0.37f, 0.37f, 0.4f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.0f, 0.0f, 0.0f, 0.0f));
		light->setPosition(Ogre::Vector3(0.0f, 100.0f, 0.0f));
		light->setDirection(Ogre::Vector3(1.0f, -1.0f, -1.0f));
		light->setType(Light::LT_DIRECTIONAL);
	}
	
	if (m_bPointLights)
	{
		
		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(200.f, 300.0f, -200.0f));
		light->setDiffuseColour(Ogre::ColourValue(0.2f, 0.8f, 0.2f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(1000.f, 1.0f, 0.045f, 0.0075f);
		light->setCastShadows(true);
		
		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(-300.0f, 250.0f, 200.0f));
		light->setDiffuseColour(Ogre::ColourValue(0.4f, 0.3f, 0.3f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(800.f, 1.0f, 0.045f, 0.0075f);

		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(00.0f, 200.0f, -50.0f));
		light->setDiffuseColour(Ogre::ColourValue(0.2f, 0.2f, 0.5f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.0f, 0.0f, 0.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(300.f, 1.0f, 0.45f, 0.75f);
		
	}

	pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 0.0f, 0.0f));
	Entity * ground = m_pSceneManager->createEntity("ground", "ground.mesh");
	ground->setRenderQueueGroupAndPriority(RENDER_QUEUE_MAIN, 1);
	Ogre::MaterialPtr matBase = Ogre::MaterialManager::getSingleton().getByName("NoMaterial");
	Ogre::MaterialPtr mat;
	Ogre::GpuProgramParametersSharedPtr params;
	if (!matBase.isNull())
	{
		mat = matBase->clone("groundplane_material");
		params = mat->getTechnique(0)->getPass("ambient")->getFragmentProgramParameters();
		params->setNamedConstant("ambient", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));

		params = mat->getTechnique(0)->getPass("lighting")->getFragmentProgramParameters();
		params->setNamedConstant("diffuse", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		params->setNamedConstant("specular", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 0.0f));
	}
	ground->setMaterialName("groundplane_material");
	pNode->setScale(100.0f, 1.0f, 100.0f);
	pNode->attachObject(ground);
}

void CApplication::CreateCube(const Ogre::Vector3 & vPos, bool bHideFrontFace)
{
	static int iIndex = 0;
	
	char szEntityName[100];
	sprintf_s(szEntityName, "cube_%d", iIndex);
	Ogre::String strEntityName(szEntityName);

	char szMaterialName[100];
	sprintf_s(szMaterialName, "cube_%d_material", iIndex);
	Ogre::String strMaterialName(szMaterialName);

	Ogre::SceneNode * pNode = nullptr;
	pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(vPos);
	
	Entity * cube = m_pSceneManager->createEntity(strEntityName, "cube.mesh");
	//Entity * cube = m_pSceneManager->createEntity(strEntityName, Ogre::SceneManager::PrefabType::PT_SPHERE); //
	if(bHideFrontFace)
		cube->getSubEntity(0)->setVisible(false);
	cube->setRenderQueueGroup(RENDER_QUEUE_MAIN);
	Ogre::MaterialPtr matBase = Ogre::MaterialManager::getSingleton().getByName("NoMaterial");
	Ogre::MaterialPtr mat;
	//params;
	if (!matBase.isNull())
	{
		mat = matBase->clone(strMaterialName);
		Ogre::GpuProgramParametersSharedPtr paramsFirstPass = mat->getTechnique(0)->getPass("ambient")->getFragmentProgramParameters();
		paramsFirstPass->setNamedConstant("ambient", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));

		Ogre::GpuProgramParametersSharedPtr paramsSecondPass = mat->getTechnique(0)->getPass("lighting")->getFragmentProgramParameters();
		paramsSecondPass->setNamedConstant("diffuse", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		paramsSecondPass->setNamedConstant("specular", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 0.0f));
		paramsSecondPass->setNamedConstant("specularStrength", 0.5f);

		Ogre::GpuProgramParametersSharedPtr paramsThirdPass = mat->getTechnique(0)->getPass("diffuse")->getFragmentProgramParameters();

		float alpha = 0.20;
		if (iIndex % 3 == 0)
		{
			if (alpha < 1.0)
			{
				mat->getTechnique(0)->getPass(0)->setSceneBlending(SBT_TRANSPARENT_ALPHA);
				mat->setDepthWriteEnabled(false);
			}
			paramsFirstPass->setNamedConstant("alpha", alpha);

			paramsSecondPass->setNamedConstant("specular", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 140.0f));
			paramsSecondPass->setNamedConstant("alpha", alpha);

			paramsThirdPass->setNamedConstant("alpha", alpha);
		}
	}
	cube->setMaterialName(strMaterialName);
	cube->setCastShadows(true);
	pNode->attachObject(cube);
	pNode->setScale(Ogre::Vector3(1.0f));

	pNode->setScale(pNode->getScale() - Ogre::Vector3(0.0005f));

	iIndex++;
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
