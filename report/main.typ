#import "@preview/codly:1.1.1" as codly:
#import "util.typ" as util: code_figure, src_link


#set document(
	author: "Filipe Rodrigues",
	title: util.title,
	date: none
)
#set page(
	header: context {
		if counter(page).get().first() > 1 {
			image("images/tecnico-logo.png", height: 30pt)
		}
	},
	footer: context {
		if counter(page).get().first() > 1 {
			align(center, counter(page).display())
		}
	},
	margin: (x: 2cm, y: 30pt + 1.5cm)
)
#set text(
	font: "Libertinus Serif",
	lang: "en",
)
#set par(
	justify: true,
	leading: 0.65em,
)
#show link: underline

#show: codly.codly-init.with()

#include "cover.typ"
#pagebreak()

= Setup

For the setup, instead of using an LED, we connected the output to an oscilloscope, to be able to more easily embed the results without resorting to video.

The setup is shown in the following @setup-img:

#figure(
	image("images/setup.jpg", width: 50%),
	caption: [Setup for reading the output]
) <setup-img>

We then setup a basic project with no dependencies. The main file is situated in #src_link("main/main.c")

= Experiment

#let main_src = read("src/main/main.c")

== Step 1: Understand the Default Behavior

The first step consists of making the LED blink once per 2 seconds, with 1 second on and 1 second off.

We wrote a function, called `step1` to achieve this and ran it by uncommenting the call to it in `app_main`, as shown below in @step1-code:

#codly.codly(
	ranges: ((12, 23), (47, 47), (52, 52)),
	skips: ((23, 0), (47, 0)),
	highlights: (
		(line: 51, start: 3, end: 4, fill: red),
	),
)
#code_figure(
	raw(main_src, lang: "c", block: true),
	caption: "Step 1 code"
) <step1-code>

We saw the following output on the oscilloscope, shown in @step1-output:

#figure(
	image("images/step1-output.jpg", width: 60%),
	caption: [Step 1 oscilloscope output]
) <step1-output>

The time-scale is 1 second, as shown at the bottom of the oscilloscope (`M 1.00s`), and will remain 1 second for the rest of the experiments.

Using this, we can see that each state of the blink lasts for 1 second, as expected.

== Step 2: Modify the Blinking Interval

For this step, we modified the duration to 500 ms, as shown below in @step2-code:

#codly.codly(
	ranges: ((12, 12), (20, 20)),
	skips: ((12, 0),),
	highlights: (
		(line: 19, start: 20, end: 23, fill: red, tag: [
			#show: body => box(fill: color.green.lighten(80%), outset: 100em, body)
			#set text(fill: green.darken(50%))
			500
		]),
	),
)
#code_figure(
	raw(main_src, lang: "c", block: true),
	caption: "Step 2 code"
) <step2-code>

We saw the following output on the oscilloscope, shown in @step2-output:

#figure(
	image("images/step2-output.jpg", width: 60%),
	caption: [Step 2 oscilloscope output]
) <step2-output>

We now see each state lasts for 500 ms, as expected.

== Step 3: Different Patterns

For this step, we need to implement a blinker that blinks in fast succession 3 times, then stays off for 2 seconds. We decided on using 200 milliseconds for each state during the fast blinks.

We wrote a function, called `step3` to achieve this and ran it by commenting the previous call to `step1` and uncommenting the call to it in `app_main`, as shown below in @step3-code:

#codly.codly(
	ranges: ((25, 45), (47, 47), (52, 53)),
	skips: ((45, 0), (47, 0)),
	highlights: (
		(line: 51, start: 3, end: 4, fill: green),
		(line: 52, start: 3, end: 4, fill: red),
	),
)
#code_figure(
	raw(main_src, lang: "c", block: true),
	caption: "Step 3 code"
) <step3-code>

We saw the following output on the oscilloscope, shown in @step3-output:

#figure(
	image("images/step3-output.jpg", width: 60%),
	caption: [Step 3 oscilloscope output]
) <step3-output>

We now see 3 quick blinks, with each state lasting for 200 milliseconds, then it stays off for exactly 2 seconds, as expected.

= Discussion Questions

== Why is the `gpio_set_direction()` function necessary when initializing GPIO pins?

Each pin has a state that (primarily) monitors whether the pin can be read/written to.

Each pin supports several states, defined as `gpio_mode_t` @gpio-docs. In particular interest to us are the following:

- `GPIO_MODE_DISABLE`: Disables the pin
- `GPIO_MODE_INPUT`: Pin can only input
- `GPIO_MODE_OUTPUT`: Pin can only output
- `GPIO_MODE_INPUT_OUTPUT`: Pin can input and output

(There are some other modes related to whether the pin uses an open-drain)

The functions that read/write to the GPIOs then check the mode before performing the raw hardware read/writes.

When reading via `gpio_get_level`, if the mode isn't `GPIO_MODE_INPUT` or `GPIO_MODE_INPUT_OUTPUT`, the returned value is 0 @gpio-docs.

When writing via `gpio_set_level`, if the mode isn't `GPIO_MODE_OUTPUT` or `GPIO_MODE_INPUT_OUTPUT`, the write is ignored, as the only errors possibly returned are errors related to the GPIO number, but the documentation does not explicitly specify it.

The default mode is `GPIO_MODE_DISABLE`, as is specified by `gpio_reset_pin` @gpio-docs.

This means that before being able to read or write to the pin, we must set it's input/output mode.

== How does the ESP32 manage delays through `vTaskDelay()`? What is the significance of `portTICK_PERIOD_MS`?

`vTaskDelay` is part of `FreeRTOS` @vTaskDelay-docs. It receives a single argument, `xTicksToDelay`, an integer number of "ticks". When called, it suspends the current task, an abstraction of `FreeRTOS` similar to a thread, and only queues it again after the specified number of "ticks" has passed.

How long each "tick" is depends on the system, and a constant exists, `portTICK_PERIOD_MS` that specifies the number of milliseconds per tick.

We can then sleep for, for example, 1 second by dividing 1000 ms by `portTICK_PERIOD_MS`, as shown in @questions-vTaskDelay-code:

#codly.codly()
#code_figure(```c
const int ms = 1000;
vTaskDelay(ms / portTICK_PERIOD_MS);
```) <questions-vTaskDelay-code>

A big caveat is that the number of ticks is an integer, and so we can only ever sleep in multiples of `portTICK_PERIOD_MS`. For us, this constant is `10`, which means we can only ever sleep at least 10 `ms`.

If we attempt to sleep for less than that and call `vTaskDelay` by dividing the number of milliseconds by `portTICK_PERIOD_MS`, we'll instead not sleep and return immediately, since we'll be passing 0 as the number of ticks, due to C performing integer division, so we cannot yield for any shorter time than this constant.

== What are some real-world applications of GPIO control in embedded systems?

The voltage and current coming out of the GPIO is very small, and so can't be used to power any large circuitry, but it can instead be used to drive a relay that itself powers large circuitry, such as in home automation, for turning on a room's light, opening a garage door, and other typical smart-home appliances.

#bibliography("bibliography.yaml", style: "ieee", full: true)
