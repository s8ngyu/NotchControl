ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

ADDITIONAL_OBJCFLAGS = -fobjc-arc

TWEAK_NAME = NotchControl
NotchControl_FILES = Tweak.xm
NotchControl_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
