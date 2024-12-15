#include "driver/gpio.h"
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "soc/gpio_num.h"
#include "spi_flash_mmap.h"
#include <stdio.h>

/// Pin
const int PIN = GPIO_NUM_2;

void step1() {
	bool status = 0;
	while (1) {
		// Set it and toggle it
		gpio_set_level(PIN, status);
		status = !status;

		// Then sleep
		const int ms = 500;
		vTaskDelay(ms / portTICK_PERIOD_MS);
	}
}

void step2() {
	/// Pulse width (ms) for the inner loop
	const int ms_in = 200;

	/// Pulse width (ms) for the outer loop
	const int ms_out = 2000;

	while (1) {
		// Set it and toggle it
		for (int i = 0; i < 3; i++) {
			gpio_set_level(PIN, 1);
			vTaskDelay(ms_in / portTICK_PERIOD_MS);
			gpio_set_level(PIN, 0);
			vTaskDelay(ms_in / portTICK_PERIOD_MS);
		}

		// Note: We sleep `ms_out - ms_in` because we already slept for `ms_in`
		//       inside the loop.
		vTaskDelay((ms_out - ms_in) / portTICK_PERIOD_MS);
	}
}

void app_main(void) {
	// Initialize the pin
	gpio_reset_pin(PIN);
	gpio_set_direction(PIN, GPIO_MODE_OUTPUT);

	//step1();
	//step2();
}
