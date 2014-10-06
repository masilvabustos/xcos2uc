
PLATFORMS=stm32vldiscovery

PLATFORM_DIR=$(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: $(PLATFORMS)

print-platforms:
	@echo $(PLATFORMS)

#stm32vldiscovery: 
#	$(MAKE) -f STM32VLDISCOVERY_PACKAGE_DIR=$(PLATFORM_DIR)/stm32vldiscovery

$(PLATFORMS): 
	$(MAKE) -f $(PLATFORM_DIR)/$@/GNUmakefile firmware.a

