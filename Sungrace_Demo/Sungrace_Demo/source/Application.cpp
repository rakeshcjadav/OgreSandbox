#include "pchDemo.h"
#include "Application.h"
#include "FrameListener.h"
#include <GL\gl.h>

#pragma comment(lib, "opengl32.lib")

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
	miscParam["colourDepth"] = "32";

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

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "sungrace//materials//programs", "FileSystem", "sungrace", false);
	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "sungrace//materials//scripts", "FileSystem", "sungrace", false);
	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "sungrace//materials//textures", "FileSystem", "sungrace", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("sungrace");

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "cubenew", "FileSystem", "cubenew", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("cubenew");

	ResourceGroupManager::getSingleton().addResourceLocation(GetMediaPath() + "ground", "FileSystem", "ground", false);
	ResourceGroupManager::getSingleton().initialiseResourceGroup("ground");

	CreateScene();

	// shadow params
	//m_pSceneManager->setShadowTechnique(Ogre::SHADOWTYPE_TEXTURE_ADDITIVE_INTEGRATED);
	//m_pSceneManager->setShadowCasterRenderBackFaces(false);
	//m_pSceneManager->setShadowTexturePixelFormat(Ogre::PF_FLOAT32_RGB);
	//m_pSceneManager->setShadowTextureCasterMaterial("Ogre/DepthShadowmap/Caster/Float");
	//m_pSceneManager->setShadowTextureReceiverMaterial("Ogre/DepthShadowmap/Receiver/Float");
	//m_pSceneManager->setShadowTextureSelfShadow(true);
	//m_pSceneManager->setShadowTextureSize(1024);

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
		m_pSceneManager->setAmbientLight(ColourValue(1.0f, 1.0f, 1.0f));
	else
		m_pSceneManager->setAmbientLight(ColourValue(1.0f, 1.0f, 1.0f));

	Ogre::SceneNode * pNode = nullptr;
	Light * light = nullptr;

	CreateCubeFromPlanes();
	CreateCube(Ogre::Vector3(150.0f, 50.0f, 200.0f), false, 0.4f);
	//CreateCube(Ogre::Vector3(100.0f, 50.0f, 0.0f));
	//CreateCube(Ogre::Vector3(200.0f, 50.0f, 0.0f));
	//CreateCube(Ogre::Vector3(300.0f, 50.0f, 0.0f));
	//CreateCube(Ogre::Vector3(400.0f, 50.0f, 0.0f), false, 0.2f);

	if (m_bSunLight)
	{
		light = m_pSceneManager->createLight();
		light->setDiffuseColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(0.03f, 0.03f, 0.03f, 0.0f));
		light->setPosition(Ogre::Vector3(0.0f, 100.0f, 0.0f));
		light->setDirection(Ogre::Vector3(1.0f, -1.0f, -1.0f));
		light->setType(Light::LT_DIRECTIONAL);
	}
	
	if (m_bPointLights)
	{
		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(100.f, 100.0f, 100.0f));
		light->setDiffuseColour(Ogre::ColourValue(1.0f, 0.0f, 0.0f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(1.0f, .0f, .0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(500.f, 1.0f, 0.009f, 0.0009f);
		light->setCastShadows(true);
		
		/**
		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(150.0f, 300.0f, -200.0f));
		light->setDiffuseColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setType(Light::LT_POINT);
		light->setAttenuation(700.f, 1.0f, 0.005f, 0.0002f);
		*/
		
		light = m_pSceneManager->createLight();
		light->setPosition(Ogre::Vector3(-350.0f, 100.0f, 350.0f));
		light->setDirection(Ogre::Vector3(0.0f, -1.0f, 0.5f));
		light->setDiffuseColour(Ogre::ColourValue(0.5f, 0.5f, 1.0f, 1.0f));
		light->setSpecularColour(Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		light->setCastShadows(true);
		light->setType(Light::LT_SPOTLIGHT);
		light->setAttenuation(500.f, 1.0f, 0.45f, 0.075f);
		light->setSpotlightRange(Ogre::Radian(Ogre::Degree(80.0f)), Ogre::Radian(Ogre::Degree(90.0f)), 1.0f);
		
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
		params->setNamedConstant("ambient", Ogre::ColourValue(0.1f, 0.1f, 0.1f, 1.0f));

		params = mat->getTechnique(0)->getPass("lighting")->getFragmentProgramParameters();
		params->setNamedConstant("diffuse", Ogre::ColourValue(0.2f, 0.2f, 0.2f, 1.0f));
		params->setNamedConstant("specular", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 0.0f));

		params = mat->getTechnique(0)->getPass("diffuse")->getFragmentProgramParameters();

		params = mat->getTechnique(0)->getPass("environment")->getFragmentProgramParameters();
		params->setNamedConstant("reflection", 0.0f);
	}
	ground->setMaterialName("groundplane_material");
	pNode->setScale(100.0f, 100.0f, 100.0f);
	pNode->attachObject(ground);

	pNode = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(300.0f, 100.0f, 0.0f));
	Entity * sphere = m_pSceneManager->createEntity("sphere", Ogre::SceneManager::PrefabType::PT_SPHERE);
	sphere->setRenderQueueGroupAndPriority(RENDER_QUEUE_MAIN, 1);
	/*
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

		params = mat->getTechnique(0)->getPass("diffuse")->getFragmentProgramParameters();
		params->setNamedConstant("Reflection", 0.0f);
	}
	*/
	glLineWidth(2.0f);
	Ogre::MaterialPtr matf = Ogre::MaterialManager::getSingleton().getByName("cubemapping");
	sphere->setMaterialName("cubemapping");
	//pNode->setScale(10.0f, 10.0f, 10.0f);
	pNode->attachObject(sphere);
}

void CApplication::CreateCube(const Ogre::Vector3 & vPos, bool bHideFrontFace, float fAlpha)
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
	
	//Entity * cube = m_pSceneManager->createEntity(strEntityName, "cube.mesh");
	Entity * cube = m_pSceneManager->createEntity(strEntityName, Ogre::SceneManager::PrefabType::PT_CUBE); //
	if(bHideFrontFace)
		cube->getSubEntity(0)->setVisible(false);
	cube->setRenderQueueGroup(RENDER_QUEUE_MAIN);
	Ogre::MaterialPtr matBase = Ogre::MaterialManager::getSingleton().getByName("default");
	Ogre::MaterialPtr mat;
	//params;
	if (!matBase.isNull())
	{
		mat = matBase->clone(strMaterialName);
		Ogre::GpuProgramParametersSharedPtr paramsFirstPass = mat->getTechnique(0)->getPass("ambient")->getFragmentProgramParameters();
		paramsFirstPass->setNamedConstant("u_constantAmbientColor", Ogre::ColourValue(0.4f, .4f, .4f, 1.0f));
		//paramsFirstPass->setNamedConstant("u_reflectivity", 1.0f);

		Ogre::GpuProgramParametersSharedPtr paramsSecondPass = mat->getTechnique(0)->getPass("lighting")->getFragmentProgramParameters();
		//paramsSecondPass->setNamedConstant("diffuse", Ogre::ColourValue(0.75164f, 0.60648f, 0.22648f, 1.0f));
		//paramsSecondPass->setNamedConstant("specular", Ogre::ColourValue(0.628281f, 0.555802f, 0.366065f, 1.4f));
		//paramsSecondPass->setNamedConstant("specularStrength", 0.13f);
		paramsSecondPass->setNamedConstant("u_specular_exponent", Ogre::ColourValue(2.0f, 2.0f, 2.0f, 220.0f));

		Ogre::GpuProgramParametersSharedPtr paramsThirdPass = mat->getTechnique(0)->getPass("diffuse")->getFragmentProgramParameters();
		//mat->getTechnique(0)->getPass("diffuse")->getTextureUnitState("DiffuseMap")->setTextureName("white_bg_1080p.jpg");

		Ogre::GpuProgramParametersSharedPtr paramsFourthPass = mat->getTechnique(0)->getPass("environment")->getFragmentProgramParameters();
		
		float alpha = fAlpha;
		float reflection = 0.3f;
		if (iIndex % 3 == 0)
		{
			if (alpha < 1.0f)
			{
				mat->getTechnique(0)->getPass(0)->setSceneBlending(SBT_TRANSPARENT_ALPHA);
				mat->getTechnique(0)->getPass(0)->setDepthWriteEnabled(false);
				//mat->setCullingMode(Ogre::CULL_NONE);
			}
			
			paramsFirstPass->setNamedConstant("u_alphaBlendFactor", alpha);

			paramsSecondPass->setNamedConstant("u_specular_exponent", Ogre::ColourValue(0.628281f, 0.555802f, 0.366065f, 115.0f));
			paramsSecondPass->setNamedConstant("u_alphaBlendFactor", alpha);
			paramsSecondPass->setNamedConstant("u_reflectivity", reflection);
			//paramsSecondPass->setNamedConstant("specularStrength", 1.5f);

			paramsThirdPass->setNamedConstant("u_alphaBlendFactor", alpha);
			paramsThirdPass->setNamedConstant("u_reflectivity", reflection);
			//mat->getTechnique(0)->getPass("diffuse")->getTextureUnitState("DiffuseMap")->setTextureName("white_bg_1080p.jpg");

			paramsFourthPass->setNamedConstant("u_alphaBlendFactor", alpha);
			paramsFourthPass->setNamedConstant("u_reflectivity", reflection);
			
		}
	}
	cube->setMaterialName(strMaterialName);
	cube->setCastShadows(true);
	pNode->attachObject(cube);
	pNode->setScale(Ogre::Vector3(1.0f));

	pNode->setScale(pNode->getScale() - Ogre::Vector3(0.00008f));

	iIndex++;
}

void CApplication::CreateCubeFromPlanes()
{
	Ogre::MaterialPtr matBase = Ogre::MaterialManager::getSingleton().getByName("default");
	Ogre::MaterialPtr mat;
	//params;
	if (!matBase.isNull())
	{
		mat = matBase->clone("CubeWithFaces");
		Ogre::GpuProgramParametersSharedPtr paramsFirstPass = mat->getTechnique(0)->getPass("ambient")->getFragmentProgramParameters();
		paramsFirstPass->setNamedConstant("u_constantAmbientColor", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 1.0f));
		//paramsFirstPass->setNamedConstant("u_reflectivity", 1.0f);

		Ogre::GpuProgramParametersSharedPtr paramsSecondPass = mat->getTechnique(0)->getPass("lighting")->getFragmentProgramParameters();
		//paramsSecondPass->setNamedConstant("diffuse", Ogre::ColourValue(0.75164f, 0.60648f, 0.22648f, 1.0f));
		//paramsSecondPass->setNamedConstant("specular", Ogre::ColourValue(0.628281f, 0.555802f, 0.366065f, 1.4f));
		//paramsSecondPass->setNamedConstant("specularStrength", 0.13f);
		paramsSecondPass->setNamedConstant("u_specular_exponent", Ogre::ColourValue(1.0f, 1.0f, 1.0f, 220.0f));

		Ogre::GpuProgramParametersSharedPtr paramsThirdPass = mat->getTechnique(0)->getPass("diffuse")->getFragmentProgramParameters();
		//mat->getTechnique(0)->getPass("diffuse")->getTextureUnitState("DiffuseMap")->setTextureName("white_bg_1080p.jpg");

		Ogre::GpuProgramParametersSharedPtr paramsFourthPass = mat->getTechnique(0)->getPass("environment")->getFragmentProgramParameters();

		float alpha = 0.59f;
		float reflection = 0.0f;
		if (alpha < 1.0f)
		{
			mat->getTechnique(0)->getPass(0)->setSceneBlending(SBT_TRANSPARENT_ALPHA);
			mat->getTechnique(0)->getPass(0)->setDepthWriteEnabled(false);
			mat->setCullingMode(Ogre::CULL_NONE);
		}

		paramsFirstPass->setNamedConstant("u_alphaBlendFactor", alpha);

		paramsSecondPass->setNamedConstant("u_specular_exponent", Ogre::ColourValue(0.628281f, 0.555802f, 0.366065f, 115.0f));
		paramsSecondPass->setNamedConstant("u_alphaBlendFactor", alpha);
		paramsSecondPass->setNamedConstant("u_reflectivity", reflection);
		//paramsSecondPass->setNamedConstant("specularStrength", 1.5f);

		paramsThirdPass->setNamedConstant("u_alphaBlendFactor", alpha);
		paramsThirdPass->setNamedConstant("u_reflectivity", reflection);
		//mat->getTechnique(0)->getPass("diffuse")->getTextureUnitState("DiffuseMap")->setTextureName("white_bg_1080p.jpg");

		paramsFourthPass->setNamedConstant("u_alphaBlendFactor", alpha);
		paramsFourthPass->setNamedConstant("u_reflectivity", reflection);

	}

	/**
	Ogre::Plane manualPlane(Ogre::Vector3(0.0f, 1.0f, 0.0f), 50.0f);
	Ogre::MeshManager::getSingleton().createPlane("plane", "General", manualPlane, 100, 100, 10, 10, true, 1, 1, 1, Vector3::UNIT_Z);

	// Top
	Ogre::Entity* face1 = m_pSceneManager->createEntity("plane_face_1", "plane");
	Ogre::SceneNode* nodeface1 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face1->setMaterialName("CubeWithFaces");
	nodeface1->attachObject(face1);

	// Bottom
	Ogre::Entity* face2 = m_pSceneManager->createEntity("plane_face_2", "plane");
	Ogre::SceneNode* nodeface2 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face2->setMaterialName("CubeWithFaces");
	nodeface2->rotate(Ogre::Vector3(1.0f, 0.0f, 0.0f), Ogre::Radian(Degree(180.0f)));
	nodeface2->attachObject(face2);

	Ogre::Plane manualPlane1(Ogre::Vector3(0.0f, 0.0f, 1.0f), 50.0f);
	Ogre::MeshManager::getSingleton().createPlane("plane1", "General", manualPlane1, 100, 100, 10, 10, true, 1, 1, 1, Vector3::UNIT_Y);

	// Front
	Ogre::Entity* face3 = m_pSceneManager->createEntity("plane_face_3", "plane1");
	Ogre::SceneNode* nodeface3 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face3->setMaterialName("CubeWithFaces");
	nodeface3->attachObject(face3);

	// Right
	Ogre::Entity* face4 = m_pSceneManager->createEntity("plane_face_4", "plane1");
	Ogre::SceneNode* nodeface4 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face4->setMaterialName("CubeWithFaces");
	nodeface4->rotate(Ogre::Vector3(0.0f, 1.0f, 0.0f), Ogre::Radian(Degree(90.0f)));
	nodeface4->attachObject(face4);

	// back
	Ogre::Entity* face5 = m_pSceneManager->createEntity("plane_face_5", "plane1");
	Ogre::SceneNode* nodeface5 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face5->setMaterialName("CubeWithFaces");
	nodeface5->rotate(Ogre::Vector3(0.0f, 1.0f, 0.0f), Ogre::Radian(Degree(180.0f)));
	nodeface5->attachObject(face5);

	// left
	Ogre::Entity* face6 = m_pSceneManager->createEntity("plane_face_6", "plane1");
	Ogre::SceneNode* nodeface6 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	face6->setMaterialName("CubeWithFaces");
	nodeface6->rotate(Ogre::Vector3(0.0f, 1.0f, 0.0f), Ogre::Radian(Degree(-90.0f)));
	nodeface6->attachObject(face6);
	*/

	float fSize = 50.0f;
	LoadCubeFace(Ogre::Vector3(-fSize, fSize, fSize), Ogre::Vector3(fSize, fSize, fSize), Ogre::Vector3(fSize, fSize, -fSize), "5", "CubeWithFaces");

	LoadCubeFace(Ogre::Vector3(-fSize, -fSize, fSize), Ogre::Vector3(fSize, -fSize, fSize), Ogre::Vector3(fSize, fSize, fSize), "1", "CubeWithFaces");
	LoadCubeFace(Ogre::Vector3(fSize, -fSize, fSize), Ogre::Vector3(fSize, -fSize, -fSize), Ogre::Vector3(fSize, fSize, -fSize), "2", "CubeWithFaces");
	LoadCubeFace(Ogre::Vector3(fSize, -fSize, -fSize), Ogre::Vector3(-fSize, -fSize, -fSize), Ogre::Vector3(-fSize, fSize, -fSize), "3", "CubeWithFaces");
	LoadCubeFace(Ogre::Vector3(-fSize, -fSize, -fSize), Ogre::Vector3(-fSize, -fSize, fSize), Ogre::Vector3(-fSize, fSize, fSize), "4", "CubeWithFaces");
	
	LoadCubeFace(Ogre::Vector3(-fSize, -fSize, fSize), Ogre::Vector3(-fSize, -fSize, -fSize), Ogre::Vector3(fSize, -fSize, -fSize), "6", "CubeWithFaces");

	LoadCubeEdges();
}

void CApplication::LoadCubeFace(Ogre::Vector3 pt1,
								Ogre::Vector3 pt2,
								Ogre::Vector3 pt3,
								std::string sFace,
								Ogre::String sCubeFaceMat)
{
	Ogre::String osFace = sFace;
	Ogre::String mPlaneName = "mPlane" + osFace;
	Ogre::String mPlaneNameEntity = "mPlaneEntity" + osFace;
	Ogre::Plane manualPlane(pt1, pt2, pt3);
	if (sFace == "5" || sFace == "6")
	{
		Ogre::MeshPtr meshPtr = Ogre::MeshManager::getSingleton().createPlane(mPlaneName, "General", manualPlane, 100.0f, 100.0f, 10, 10,
			true, 1, 1.0f, 1.0f, Ogre::Vector3::UNIT_Z);
	}
	else
	{
		Ogre::MeshManager::getSingleton().createPlane(mPlaneName, "General", manualPlane, 100.0f, 100.0f, 10, 10,
			true, 1, 1.0f, 1.0f);
	}
	Ogre::Entity* ent = m_pSceneManager->createEntity(mPlaneNameEntity, mPlaneName);
	ent->setMaterialName(sCubeFaceMat);
	Ogre::SceneNode* node1 = m_pSceneManager->getRootSceneNode()->createChildSceneNode("node" + osFace, Ogre::Vector3(0.0f, 52.0f, 0.0f));
	node1->attachObject(ent);
}

void CApplication::LoadCubeEdges()
{
	Ogre::ManualObject* edgeObject = m_pSceneManager->createManualObject("manual");
	//Ogre::MaterialPtr edgeObjectMaterial = Ogre::MaterialManager::getSingleton().create("manualMaterial","General"); 
	// edgeObjectMaterial->setReceiveShadows(false); 
	//edgeObjectMaterial->getTechnique(0)->setLightingEnabled(true); 
	//edgeObjectMaterial->getTechnique(0)->getPass(0)->setDiffuse(0,0,0,0); 
	//edgeObjectMaterial->getTechnique(0)->getPass(0)->setAmbient(0,0,0); 
	//edgeObjectMaterial->getTechnique(0)->getPass(0)->setSelfIllumination(0,0,0); 
	//edgeObjectMaterial->compile();

	edgeObject->begin("baseWhite", Ogre::RenderOperation::OT_LINE_LIST);
	float fSize = 50.0f;
	edgeObject->position(fSize, fSize, -fSize);
	edgeObject->position(fSize, fSize, fSize);

	edgeObject->position(fSize, fSize, fSize);
	edgeObject->position(-fSize, fSize, fSize);

	edgeObject->position(-fSize, fSize, fSize);
	edgeObject->position(-fSize, fSize, -fSize);

	edgeObject->position(-fSize, fSize, -fSize);
	edgeObject->position(fSize, fSize, -fSize);

	edgeObject->position(fSize, -fSize, -fSize);
	edgeObject->position(-fSize, -fSize, -fSize);

	edgeObject->position(-fSize, -fSize, -fSize);
	edgeObject->position(-fSize, -fSize, fSize);

	edgeObject->position(-fSize, -fSize, fSize);
	edgeObject->position(fSize, -fSize, fSize);

	edgeObject->position(fSize, -fSize, fSize);
	edgeObject->position(fSize, -fSize, -fSize);

	edgeObject->position(fSize, -fSize, -fSize);
	edgeObject->position(fSize, fSize, -fSize);

	edgeObject->position(fSize, -fSize, fSize);
	edgeObject->position(fSize, fSize, fSize);

	edgeObject->position(-fSize, -fSize, fSize);
	edgeObject->position(-fSize, fSize, fSize);

	edgeObject->position(-fSize, -fSize, -fSize);
	edgeObject->position(-fSize, fSize, -fSize);

	edgeObject->end();

	Ogre::SceneNode* mNode1 = m_pSceneManager->getRootSceneNode()->createChildSceneNode(Ogre::Vector3(0.0f, 52.0f, 0.0f));
	edgeObject->setMaterialName(0, "baseWhite");

	Ogre::MaterialPtr pOTLMat = Ogre::MaterialManager::getSingleton().getByName("baseWhite");
	//Ogre::GpuProgramParametersSharedPtr pixelShaderConstants =
		//pOTLMat->getTechnique(0)->getPass(0)->getFragmentProgramParameters();

	// Set OutlineColor to fragment shader
	//pixelShaderConstants->setNamedConstant("u_OutlineColor", Ogre::Vector4(0.7f, 0.7f, 0.7f, 1.0f));

	mNode1->attachObject(edgeObject);
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
