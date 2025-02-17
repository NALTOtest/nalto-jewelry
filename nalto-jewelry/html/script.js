console.log("[DEBUG] Script file loaded");

window.addEventListener('load', function() {
    console.log("[DEBUG] Window fully loaded");
    
    // Test if we can find our elements
    const container = document.getElementById("armor-container");
    const text = document.getElementById("armor-text");
    console.log("[DEBUG] Container element:", container);
    console.log("[DEBUG] Text element:", text);
});

window.addEventListener('message', function(event) {
    console.log("[DEBUG] Received message:", event.data);
    
    const data = event.data;
    const container = document.getElementById("armor-container");
    const text = document.getElementById("armor-text");

    if (!container || !text) {
        console.error("[DEBUG] Elements not found!");
        return;
    }

    switch (data.action) {
        case "showArmorUI":
            console.log("[DEBUG] Showing Armor UI", data);
            container.classList.remove("hidden");
            text.textContent = Math.round(data.armor) + "%";
            break;

        case "updateArmorUI":
            console.log("[DEBUG] Updating Armor UI", data);
            text.textContent = Math.round(data.armor) + "%";
            break;

        case "hideArmorUI":
            console.log("[DEBUG] Hiding Armor UI");
            container.classList.add("hidden");
            break;

        default:
            console.log("[DEBUG] Unknown action:", data.action);
            break;
    }
});

// Test that we can manipulate the UI
function testUI() {
    const container = document.getElementById("armor-container");
    const text = document.getElementById("armor-text");
    
    if (container && text) {
        container.classList.remove("hidden");
        text.textContent = "TEST";
        console.log("[DEBUG] Test UI manipulation successful");
    } else {
        console.error("[DEBUG] Test UI manipulation failed - elements not found");
    }
}

// Run test after a short delay
setTimeout(testUI, 1000);