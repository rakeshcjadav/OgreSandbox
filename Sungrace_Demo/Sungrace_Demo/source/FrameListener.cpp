#include "pchDemo.h"
#include "FrameListener.h"

CFrameListener::CFrameListener(Ogre::RenderWindow * pRenderWindow, Ogre::Camera * pCamera) :
	mTranslateVector(Vector3::ZERO), mCurrentSpeed(0), mMoveScale(0.0f), mRotScale(0.0f), mTimeUntilNextToggle(0),
	mMoveSpeed(100), mRotateSpeed(36)
{
	m_pRefRenderWindow = pRenderWindow;
	m_pRefCamera = pCamera;

	LogManager::getSingletonPtr()->logMessage("*** Initializing OIS ***");
	OIS::ParamList pl;
	size_t windowHnd = 0;
	std::ostringstream windowHndStr;

	m_pRefRenderWindow->getCustomAttribute("WINDOW", &windowHnd);
	windowHndStr << windowHnd;
	pl.insert(std::make_pair(std::string("WINDOW"), windowHndStr.str()));

	m_pInputManager = OIS::InputManager::createInputSystem(pl);

	//Create all devices (We only catch joystick exceptions here, as, most people have Key/Mouse)
	m_pKeyboard = static_cast<OIS::Keyboard*>(m_pInputManager->createInputObject(OIS::OISKeyboard, false));
	m_pMouse = static_cast<OIS::Mouse*>(m_pInputManager->createInputObject(OIS::OISMouse, false));

	//Set initial mouse clipping size
	windowResized(m_pRefRenderWindow);

	//Register as a Window listener
	WindowEventUtilities::addWindowEventListener(m_pRefRenderWindow, this);
}

CFrameListener::~CFrameListener()
{
	//Remove ourself as a Window listener
	WindowEventUtilities::removeWindowEventListener(m_pRefRenderWindow, this);
	windowClosed(m_pRefRenderWindow);

	// These are just ref so don't delete it.
	m_pRefRenderWindow = nullptr;
	m_pRefCamera = nullptr;
}

bool CFrameListener::frameStarted(const FrameEvent& evt)
{
	return true;
}

bool CFrameListener::frameRenderingQueued(const FrameEvent& evt)
{
	if (m_pRefRenderWindow->isClosed())	return false;

	mSpeedLimit = mMoveScale * evt.timeSinceLastFrame;

	//Need to capture/update each device
	m_pKeyboard->capture();
	m_pMouse->capture();

	Ogre::Vector3 lastMotion = mTranslateVector;

	//Check if one of the devices is not buffered
	if (!m_pMouse->buffered() || !m_pKeyboard->buffered())
	{
		// one of the input modes is immediate, so setup what is needed for immediate movement
		if (mTimeUntilNextToggle >= 0)
			mTimeUntilNextToggle -= evt.timeSinceLastFrame;

		// Move about 100 units per second
		mMoveScale = mMoveSpeed * evt.timeSinceLastFrame;
		// Take about 10 seconds for full rotation
		mRotScale = mRotateSpeed * evt.timeSinceLastFrame;

		mRotX = 0;
		mRotY = 0;
		mTranslateVector = Ogre::Vector3::ZERO;

	}

	//Check to see which device is not buffered, and handle it
	if (!m_pKeyboard->buffered())
		if (ProcessUnbufferedKeyInput(evt) == false)
			return false;
	if (m_pMouse && !m_pMouse->buffered())
		if (ProcessUnbufferedMouseInput(evt) == false)
			return false;

	// ramp up / ramp down speed
	if (mTranslateVector == Ogre::Vector3::ZERO)
	{
		// decay (one third speed)
		mCurrentSpeed -= evt.timeSinceLastFrame * 0.3f;
		mTranslateVector = lastMotion;
	}
	else
	{
		// ramp up
		mCurrentSpeed += evt.timeSinceLastFrame;

	}
	// Limit motion speed
	if (mCurrentSpeed > 1.0)
		mCurrentSpeed = 1.0;
	if (mCurrentSpeed < 0.0)
		mCurrentSpeed = 0.0;

	mTranslateVector *= mCurrentSpeed;

	if (!m_pMouse->buffered() || !m_pKeyboard->buffered())
		MoveCamera();

	return true;
}

bool CFrameListener::frameEnded(const FrameEvent& evt)
{
	return true;
}

void CFrameListener::windowResized(RenderWindow * pRenderWindow)
{
	unsigned int width, height, depth;
	int left, top;
	pRenderWindow->getMetrics(width, height, depth, left, top);

	const OIS::MouseState &ms = m_pMouse->getMouseState();
	ms.width = width;
	ms.height = height;
}

void CFrameListener::windowClosed(RenderWindow * pRenderWindow)
{
	if (pRenderWindow == m_pRefRenderWindow)
	{
		if (m_pInputManager)
		{
			m_pInputManager->destroyInputObject(m_pMouse);
			m_pInputManager->destroyInputObject(m_pKeyboard);

			OIS::InputManager::destroyInputSystem(m_pInputManager);
			m_pInputManager = 0;
		}
	}
}

bool CFrameListener::ProcessUnbufferedKeyInput(const FrameEvent& evt)
{
	if (m_pKeyboard->isKeyDown(OIS::KC_ESCAPE))
		return false;

	Real moveScale = mMoveScale;
	if (m_pKeyboard->isKeyDown(OIS::KC_LSHIFT))
		moveScale *= 10;

	if (m_pKeyboard->isKeyDown(OIS::KC_A))
		mTranslateVector.x = -moveScale;	// Move camera left

	if (m_pKeyboard->isKeyDown(OIS::KC_D))
		mTranslateVector.x = moveScale;	// Move camera RIGHT

	if (m_pKeyboard->isKeyDown(OIS::KC_UP) || m_pKeyboard->isKeyDown(OIS::KC_W))
		mTranslateVector.z = -moveScale;	// Move camera forward

	if (m_pKeyboard->isKeyDown(OIS::KC_DOWN) || m_pKeyboard->isKeyDown(OIS::KC_S))
		mTranslateVector.z = moveScale;	// Move camera backward

	if (m_pKeyboard->isKeyDown(OIS::KC_PGUP))
		mTranslateVector.y = moveScale;	// Move camera up

	if (m_pKeyboard->isKeyDown(OIS::KC_PGDOWN))
		mTranslateVector.y = -moveScale;	// Move camera down

	if (m_pKeyboard->isKeyDown(OIS::KC_RIGHT))
		m_pRefCamera->yaw(-mRotScale);

	if (m_pKeyboard->isKeyDown(OIS::KC_LEFT))
		m_pRefCamera->yaw(mRotScale);

	// Return true to continue rendering
	return true;
}

bool CFrameListener::ProcessUnbufferedMouseInput(const FrameEvent& evt)
{
	// Rotation factors, may not be used if the second mouse button is pressed
	// 2nd mouse button - slide, otherwise rotate
	const OIS::MouseState &ms = m_pMouse->getMouseState();
	if (ms.buttonDown(OIS::MB_Right))
	{
		mTranslateVector.x += ms.X.rel * 0.13f;
		mTranslateVector.y -= ms.Y.rel * 0.13f;
	}
	else
	{
		mRotX = Degree(-ms.X.rel * 0.13f);
		mRotY = Degree(-ms.Y.rel * 0.13f);
	}

	return true;
}

void CFrameListener::MoveCamera()
{
	// Make all the changes to the camera
	// Note that YAW direction is around a fixed axis (freelook style) rather than a natural YAW
	//(e.g. airplane)
	m_pRefCamera->yaw(mRotX);
	m_pRefCamera->pitch(mRotY);
	m_pRefCamera->moveRelative(mTranslateVector);
}