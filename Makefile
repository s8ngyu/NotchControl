ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

ADDITIONAL_OBJCFLAGS = -fobjc-arc

TWEAK_NAME = NotchControl
NotchControl_FILES = Tweak.xm headers/MarqueeLabel.m headers/UIImage+tintColor.m headers/UIImage+ScaledImage.m headers/AWeatherModel.xm
NotchControl_FRAMEWORKS += UIKit QuartzCore CoreLocation
NotchControl_EXTRA_FRAMEWORKS += Cephei
NotchControl_PRIVATE_FRAMEWORKS = MediaRemote Weather WeatherUI
NotchControl_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/headers

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ncprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
