// Geolocation functions for Climaguate

// Geolocation functionality for Climaguate
window.getUserLocation = function (dotNetHelper) {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function (position) {
                // Success - call back to .NET with coordinates
                dotNetHelper.invokeMethodAsync('OnLocationReceived', 
                    position.coords.latitude, 
                    position.coords.longitude);
            },
            function (error) {
                // Call .NET to handle the error and reset state
                dotNetHelper.invokeMethodAsync('OnLocationError', error.message);
            },
            {
                enableHighAccuracy: false,
                timeout: 5000,
                maximumAge: 60000
            }
        );
    } else {
        // Call .NET to handle the error
        dotNetHelper.invokeMethodAsync('OnLocationError', 'Geolocation not supported');
    }
};
