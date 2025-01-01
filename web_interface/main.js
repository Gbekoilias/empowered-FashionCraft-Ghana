// Entry point for the web application

// Variables
const appElement = document.getElementById('app'); // Main application element
let initData = {}; // Variable to hold initial data

// Function to initialize the application
function initializeApp() {
    console.log("Initializing application...");

    // Fetch initial data (e.g., from an API)
    fetchInitialData()
        .then(data => {
            initData = data; // Store fetched data
            renderApp(); // Render the application with initial data
        })
        .catch(error => {
            console.error("Error fetching initial data:", error);
            appElement.innerHTML = "<p>Error loading data. Please try again later.</p>";
        });
}

// Function to fetch initial data from an API
function fetchInitialData() {
    return new Promise((resolve, reject) => {
        // Simulating an API call with a timeout
        setTimeout(() => {
            const sampleData = {
                title: "Welcome to Our Web Application",
                description: "This is a simple web app using vanilla JavaScript."
            };
            resolve(sampleData); // Resolve with sample data
        }, 1000);
    });
}

// Function to render the application UI
function renderApp() {
    appElement.innerHTML = `
        <h1>${initData.title}</h1>
        <p>${initData.description}</p>
        <button id="actionButton">Click Me!</button>
    `;

    // Set up event listener for button click
    const actionButton = document.getElementById('actionButton');
    actionButton.addEventListener('click', handleButtonClick);
}

// Function to handle button click events
function handleButtonClick() {
    alert("Button clicked!"); // Display an alert when the button is clicked
}

// Initialize the application when the DOM content is fully loaded
document.addEventListener('DOMContentLoaded', initializeApp);
