# Farm-Expert App

## Overview
The **Farm-Expert App** is a comprehensive tool designed to assist farmers in managing their crops more effectively. By utilizing advanced AI technologies, the app allows farmers to detect crop diseases by capturing images of their crops and provides remedies or recommendations on how to treat the detected diseases. Additionally, the app features an AI-powered chatbot that can answer a wide range of farming-related questions, providing valuable insights and support.

## Features
- **Crop Disease Detection**: 
  - Farmers can capture images of their crops, and the app will analyze the images using a transformer model to detect any potential diseases.
  - The app provides detailed information about the detected disease and suggests remedies or preventive measures.

- **Farming Chatbot**: 
  - An AI-powered chatbot is integrated into the app, which can answer questions about various aspects of farming.
  - The chatbot is built using a Large Language Model (LLM) that understands and responds to farmers' queries in a natural, conversational manner.

## Technology Stack
- **Frontend**: Flutter for cross-platform mobile app development.
- **Backend**: Python-based Flask server for handling requests and integrating AI models.
- **AI Models**:
  - **Transformer Model**: Used for image analysis and crop disease detection.
  - **Large Language Model (LLM)**: Powers the chatbot, enabling it to provide contextual and accurate responses.
- **Database**: Firebase for storing user data, images, and interaction logs.
- **Deployment**: Docker for containerization, making the app easily deployable across different environments.
