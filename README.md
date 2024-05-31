# ![Climaguate logo](/frontend/Client/wwwroot/images/logo.png)
By Eduardo Pivaral | <a href="https://www.linkedin.com/in/eduardo-pivaral/" target="_blank">LinkedIn</a> | <a href="https://x.com/Edu_Pivaral" target="_blank">Twitter/X</a>

<a href="https://climaguate.com/" target="_blank">www.climaguate.com</a> is a weather forecast website for Guatemala.
It provides up-to-date information about the weather in different regions of the country, including temperatures, atmospheric conditions, and short-term and long-term forecasts.

This website is a personal open-source project that demonstrates a full cloud solution with CI/CD and scalability using:
- Static web application using Azure and Blazor
- Database storage using Azure SQL database
- Information gathering using Azure Functions and Python
- CI/CD using GitHub Actions
- IaC using Terraform


## Architecture Diagram Explanation

The diagram illustrates the architecture for a weather data collection, processing, and presentation system named Climaguate. The system is composed of several components working together to gather, process, and present weather-related data to end-users. 

![Climaguate Architecture Diagram](climaguate.png)

### 1. Data Collection (Schedule Trigger)
This section is responsible for collecting weather data from various sources at scheduled intervals. It comprises three main Python-based crawlers:

- **WeatherCrawler**: Collects weather data from OpenWeatherMap.org in JSON format.
- **MapImageCrawler**: Fetches weather map images from NASA GOES.
- **NewsCrawler**: Gathers weather-related news from social media platforms like Twitter and Facebook in JSON format.

All these crawlers use Azure Functions for serverless execution. They retrieve the necessary API keys and connection strings from a Key Vault, ensuring secure access to external APIs.

### 2. Data Presentation
This section handles the processing and presentation of collected data. It involves:

- **SQL Database**: Stores the raw and processed weather data.
- **Data API Builder**: Converts the stored data into JSON format through an API, making it accessible for the web application.
- **Static Web App**: A front-end application built using .NET Core and C# that presents the data to users. The website ([www.climaguate.com](http://www.climaguate.com)) is the main interface for users to access the weather information.

### 3. CI/CD (Continuous Integration/Continuous Deployment)
This section ensures that the codebase and infrastructure are consistently tested, integrated, and deployed. It includes:

- **GitHub Codespaces**: Provides a web-based development environment in Visual Studio Code, it is configured with all the required extensions so work can be resumed anywhere.
- **GitHub Actions**: Automates the build and deployment processes.

Code is committed to the Epivaral/climaguate repository on GitHub, which triggers the CI/CD pipelines by GitHub Actions.
There is one action for each component on the solution, that matches the folder structure: Infrastructure, Backend, Database, and Frontend.

### 4. End-Users
This section represents the final consumers of the weather data. The end-users can access the data through various devices:

- **Desktop Browsers**: Accessing the web application through [www.climaguate.com](http://www.climaguate.com).
- **Mobile Devices**: Viewing the weather data on smartphones and tablets via a responsive web application or a potential mobile app.

Additionally, there is an **Email Service** (in development) that generates daily weather forecasts and sends them to subscribers via email, you will be able to suscribe to it from the website.

### Summary
The Climaguate system is designed to efficiently collect, process, and present weather information to users via a web application. It leverages serverless functions for data collection, a robust database for storage, a .NET-based front-end for presentation, and an automated CI/CD pipeline for continuous improvement and deployment. 

This architecture ensures scalability, security, and ease of use for both developers and end-users.


# Our Logo
<img src="/frontend/Client/wwwroot/images/chaac.png" alt="Image Description" align="right"/>
Chaac is the Maya god of rain. In Maya mythology, Chaac is considered an important deity who controls water and weather. He is depicted as a man with a large nose and sharp teeth, and carries a stone axe that he uses to strike the clouds and make it rain.

The ancient Maya relied on Chaac to ensure good harvests and maintain balance in nature. Even today, Chaac is revered in some indigenous communities in Guatemala as a symbol of fertility and prosperity.

The presence of Chaac in Climaguate is a reminder of the importance of water and weather in our lives. Through this website, we hope to provide accurate and useful information about the weather in Guatemala, so that people can be prepared and make informed decisions. 
Like Chaac, our goal is to help maintain balance and harmony in nature, and promote sustainability and environmental care.
