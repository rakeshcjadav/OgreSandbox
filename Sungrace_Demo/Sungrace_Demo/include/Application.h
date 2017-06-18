#pragma once

// Forward declaration
class CFrameListener;

class CApplication
{
public:
									CApplication();
									~CApplication();
	bool							Init();
	void							Run();

private:
	void							CreateScene();
	Ogre::String					GetMediaPath();

private:

	Ogre::Root *					m_pRoot;
	Ogre::RenderWindow *			m_pRenderWindow;
	Ogre::Camera *					m_pCamera;
	Ogre::SceneManager *			m_pSceneManager;

	CFrameListener *				m_pFrameListener;
};

