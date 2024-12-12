#include "driver/gpio.h"
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "spi_flash_mmap.h"
#include <stdio.h>

void app_main(void) {
	// Initialize the pin
	const int pin = GPIO_NUM_2;
	gpio_reset_pin(pin);
	gpio_set_direction(pin, GPIO_MODE_OUTPUT);

	/*
	bool status = 0;
	while (1) {
		// Set it and toggle it
		gpio_set_level(pin, status);
		status = !status;

		// Then sleep
		const int ms = 500;
		const int ticks = ms / portTICK_PERIOD_MS;
		vTaskDelay(ticks);
	}
	*/

	/*
	while (1) {
		const int ms_in = 200;
		const int ms_out = 2000;

		// Set it and toggle it
		for (int i = 0; i < 3; i++) {
			gpio_set_level(pin, 1);
			vTaskDelay(ms_in / portTICK_PERIOD_MS);
			gpio_set_level(pin, 0);
			vTaskDelay(ms_in / portTICK_PERIOD_MS);
		}

		vTaskDelay((ms_out - ms_in) / portTICK_PERIOD_MS);
	}
	*/
}
