# Custom Audio Effects Box  
### Master's Thesis Project – Real-Time Audio Effect Processing with Raspberry Pi and ESP32  
**University of Portsmouth – MSc in Music Technology**

---

## Project Overview

This repository contains the source code and documentation for a custom-built **audio effects processor**, developed as part of a master's thesis project at University of Portsmouth. The system enables **real-time manipulation of audio effects** such as reverb, pitch shift, and noise through physical hardware controls and open-source software.

The device integrates:
- **SuperCollider** running on a Raspberry Pi for audio processing
- **ESP32 microcontroller** to collect user input via potentiometers and buttons
- **OSC protocol** for communication between hardware and audio engine
- External audio interfaces (DACs, USB audio cards) for high-fidelity I/O

---

## System Objectives

- Provide responsive, real-time audio effect control
- Enable physical interaction with effects via knobs and switches
- Maintain a modular, headless setup that auto-starts on boot
- Ensure low-latency audio processing using lightweight open-source tools

---

## Hardware Summary

- **Raspberry Pi** for central processing
- **ESP32** for reading hardware controls
- **Innomaker DAC** and/or **USB Audio Interface** for audio I/O
- **Potentiometers and Buttons** as physical effect controllers
- **LEDs** for basic feedback (optional)

---

## System Architecture

- ESP32 captures hardware control data and sends it to the Raspberry Pi via OSC
- Raspberry Pi routes control data to SuperCollider to dynamically adjust effect parameters


