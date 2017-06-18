#pragma once

class CFrameListener : public FrameListener, public WindowEventListener
{

public:
	CFrameListener(Ogre::RenderWindow * pRenderWindow, Ogre::Camera * pCamera);
	~CFrameListener();

	// FrameListener
	virtual bool frameStarted(const FrameEvent& evt);
	virtual bool frameRenderingQueued(const FrameEvent& evt);
	virtual bool frameEnded(const FrameEvent& evt);

	// WindowEventListener
	virtual void windowResized(RenderWindow * pRenderWindow);
	virtual void windowClosed(RenderWindow * pRenderWindow);

	bool ProcessUnbufferedKeyInput(const FrameEvent& evt);
	bool ProcessUnbufferedMouseInput(const FrameEvent& evt);

private:
	void					MoveCamera();

private:
	Ogre::Camera *			m_pRefCamera;
	Ogre::RenderWindow *	m_pRefRenderWindow;

	//OIS Input devices
	OIS::InputManager*		m_pInputManager;
	OIS::Mouse*				m_pMouse;
	OIS::Keyboard*			m_pKeyboard;

	Vector3					mTranslateVector;
	Real					mCurrentSpeed;

	Real					mTimeUntilNextToggle;
	float					mMoveScale;
	float					mSpeedLimit;
	Degree					mRotScale;

	Radian					mRotX, mRotY;

	Real					mMoveSpeed;
	Degree					mRotateSpeed;
};