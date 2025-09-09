// Geolocation functions for Climaguate
// Global variables to store location
let currentPosition = null;

// Geolocation functionality for Climaguate
window.getUserLocation = function (dotNetHelper) {
    console.log('getUserLocation called');
    if (navigator.geolocation) {
        console.log('Geolocation is supported, getting position...');
        navigator.geolocation.getCurrentPosition(
            function (position) {
                console.log('Position obtained:', position.coords.latitude, position.coords.longitude);
                // Success - call back to .NET with coordinates
                dotNetHelper.invokeMethodAsync('OnLocationReceived', 
                    position.coords.latitude, 
                    position.coords.longitude);
            },
            function (error) {
                console.warn('Geolocation error:', error.message);
                // On error, let .NET handle the fallback
            },
            {
                enableHighAccuracy: true,
                timeout: 10000,
                maximumAge: 300000 // 5 minutes
            }
        );
    } else {
        console.warn('Geolocation is not supported by this browser');
        // Browser doesn't support geolocation, let .NET handle fallback
    }
};

// Separate functions for C# to call without generics
window.getLatitude = async function() {
    if (!currentPosition) {
        await window.getUserLocation();
    }
    return currentPosition ? currentPosition.latitude.toString() : "0";
};

window.getLongitude = async function() {
    if (!currentPosition) {
        await window.getUserLocation();
    }
    return currentPosition ? currentPosition.longitude.toString() : "0";
};
