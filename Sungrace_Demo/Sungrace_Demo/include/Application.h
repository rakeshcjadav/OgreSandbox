#pragma once

// Forward declaration
class CFrameListener;

class CApplication
{
public:
									CApplication(bool _bSunLight, bool _bPointLights);
									~CApplication();
	bool							Init();
	void							Run();

private:
	void							CreateScene();
	void							CreateCube(const Ogre::Vector3 & vPos, bool bHideFrontFace = false, float fAlpha = 1.0f);
	void							CreateCubeFromPlanes();
	void							LoadCubeFace(Ogre::Vector3 pt1,
													Ogre::Vector3 pt2,
													Ogre::Vector3 pt3,
													std::string sFace,
													Ogre::String sCubeFaceMat);
	void							LoadCubeEdges();
	Ogre::String					GetMediaPath();

private:

	Ogre::Root *					m_pRoot;
	Ogre::RenderWindow *			m_pRenderWindow;
	Ogre::Camera *					m_pCamera;
	Ogre::SceneManager *			m_pSceneManager;

	CFrameListener *				m_pFrameListener;

	bool							m_bSunLight;
	bool							m_bPointLights;
};

