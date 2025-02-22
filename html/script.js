let selectedItem = null;

window.addEventListener('message', function (event) {
    if (event.data.action === "openShop") {
        document.getElementById('shopContainer').style.display = "block";

        // Show mouse cursor
        fetch(`https://${GetParentResourceName()}/setNuiFocus`, {
            method: 'POST',
            body: JSON.stringify({ focus: true }),
            headers: { 'Content-Type': 'application/json' }
        });


        let shopItems = document.getElementById('shopItems');
        shopItems.innerHTML = "";

        event.data.items.forEach(item => {
            let itemDiv = document.createElement('div');
            itemDiv.classList.add('shopItem');
            itemDiv.innerHTML = `
                <div class="item-container">
                    <img src="images/${item.item}.png" alt="${item.label}">
                </div>
                <h3 class="item-name">${item.label}</h3>
                <p class="item-price">$${item.price.toLocaleString()}</p>
                <button class="buyBtn" onclick="showInput('${item.item}')">Buy</button>
            `;
            shopItems.appendChild(itemDiv);
        });
    }
});

// player details code 👇

window.addEventListener("message", function (event) {
    if (event.data.action === "openShop") {
        document.getElementById("shopContainer").style.display = "block";

        // Request player data from server
        fetch(`https://${GetParentResourceName()}/requestPlayerData`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
        });

    } else if (event.data.action === "updatePlayerData") {
        // Update player name and cash in UI
        document.getElementById("playerName").textContent = event.data.playerName;
        document.getElementById("playerBalance").textContent = ` ${event.data.playerCash.toLocaleString()}$`;
    }
});
// end of player details 👆

// Ensure elements exist before using them
function getElement(id) {
    return document.getElementById(id) || console.error(`Element '${id}' not found!`);
}

// Show input and blur background
function showInput(item) {
    selectedItem = item;
    let overlay = getElement("blurOverlay");
    let inputBox = getElement("purchaseInputBox");

    if (overlay && inputBox) {
        overlay.style.display = "block";
        inputBox.style.display = "block";
    }
}

// Confirm purchase and hide input + overlay
document.getElementById("confirmPurchaseBtn")?.addEventListener("click", function () {
    let amount = parseInt(document.getElementById("purchaseAmount")?.value, 10) || 1;

    if (!selectedItem) {
        console.error("No item selected for purchase.");
        return;
    }

    fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: 'POST',
        body: JSON.stringify({ item: selectedItem, amount }),
        headers: { 'Content-Type': 'application/json' }
    }).then(() => {
        closeInput();
    });
});

// Close input box and remove blur
function closeInput() {
    let overlay = getElement("blurOverlay");
    let inputBox = getElement("purchaseInputBox");

    if (overlay && inputBox) {
        overlay.style.display = "none";
        inputBox.style.display = "none";
    }
}

// Close UI when ESC is pressed
document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        closeInput();
        closeShop();
    }
});

function closeShop() {
    document.getElementById('shopContainer').style.display = "none";
    
    // Hide mouse cursor
    fetch(`https://${GetParentResourceName()}/setNuiFocus`, {
        method: 'POST',
        body: JSON.stringify({ focus: false }),
        headers: { 'Content-Type': 'application/json' }
    });

    fetch(`https://${GetParentResourceName()}/closeShop`, { method: 'POST' });
}
// Click outside to close input box
document.getElementById("blurOverlay")?.addEventListener("click", function () {
    closeInput();
});

// Close input when Cancel is clicked
document.getElementById("cancelPurchaseBtn")?.addEventListener("click", function () {
    closeInput();
});
