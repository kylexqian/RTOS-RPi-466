ignore_local_config:
	git update-index --assume-unchanged local_config

include local_config

submodules_init:
	@echo "Downloading sources. This may take a while on first run..."
	git submodule init
	git submodule update
	git submodule update --rebase --remote `git submodule status | awk '{ print $$2 }'`
	cd rtos_lib && git update-index --assume-unchanged user_entry/user.c
	@echo "Sources downloaded!"

submodules_update:
	git submodule update --rebase --remote `git submodule status | awk '{ print $$2 }'`
	@echo "Sources updated!"
	
rtos_dev:
	cd rtos_lib/ && git pull --rebase origin working
	@echo "RTOS source updated!"

check_dependencies: ignore_local_config
	python3 scripts/check_dependencies.py
	@echo "All dependencies met!"

build_u-boot: submodules_init submodules_update
	cd boot && \
	$(MAKE) distclean && \
	$(MAKE) orangepi_pc_defconfig && \
	$(MAKE) all
	@echo "U-Boot built!"
	
setup: check_dependencies build_u-boot
	cd rtos_lib && \
	./config orange_pi
	@echo "Setup complete!"

clean:
	-rm entry_point/*.o

deep_clean: clean
	cd boot && $(MAKE) clean
	cd rtos_lib && $(MAKE) clean

_build:
	cd rtos_lib && $(MAKE)
	@echo "Compilation and deploy complete!"

build_dev: rtos_dev clean _build

build: submodules_update clean _build

