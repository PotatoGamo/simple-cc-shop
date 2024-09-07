local public = "minecraft:chest_26" -- Product bought gets placed here, customer places payment
local stock = "minecraft:chest_27"  -- Items being sold are stored here
local bank = "minecraft:chest_28"   -- Payment gets transferred here
local sudopsw = "CHANGEME"

-- Shop inventory, modify as needed
local shopInventory = {
    { name = "minecraft:diamond", quantity = 5, price = 10 },  -- item1 costs 10 talons
    { name = "minecraft:iron_ingot", quantity = 10, price = 15 }, -- item2 costs 15 talons
}

local currency = "plutoniumextras:talons"

-- Colors
local bgColor = colors.black
local textColor = colors.white
local titleColor = colors.yellow
local itemColor = colors.green
local errorColor = colors.red



-- Function to move items from one chest to another
local function moveItems(source, dest, slot, count)
    source = peripheral.wrap(source)
    source.pushItems(dest, slot, count)
end

-- Function to search for an item by name in a chest and return its slot
local function findItem(itemName, source)
    source = peripheral.wrap(source)
    for slot, item in pairs(source.list()) do
        if item.name == itemName then
            return slot, item.count
        end
    end
    return -1, 0
end

-- Function to display the shop inventory
local function displayShop()
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
    term.clear()
    term.setCursorPos(1,1)
    
    term.setTextColor(titleColor)
    print("Welcome to the shop!")
    
    for i, item in ipairs(shopInventory) do
        term.setTextColor(itemColor)
        print(i .. ". " .. item.name .. " x " .. item.quantity .. " | Price: " .. item.price .. " talons")
    end
    
    term.setTextColor(textColor)
end

-- Function to handle purchases
local function processPurchase(itemIndex)
    local selectedItem = shopInventory[itemIndex]
    if not selectedItem then
        term.setTextColor(errorColor)
        print("Invalid selection.")
        sleep(1)
        return
    end

    local slot, stockCount = findItem(selectedItem.name, stock)
    if slot == -1 or stockCount < selectedItem.quantity then
        term.setTextColor(errorColor)
        print("Not enough stock available.")
        sleep(1)
        return
    end

    local talonSlot, talonCount = findItem(currency, public)
    if talonSlot == -1 or talonCount < selectedItem.price then
        term.setTextColor(errorColor)
        print("Insufficient payment.")
        sleep(1)
        return
    end
    
    -- Deduct the payment and move items
    moveItems(public, bank, talonSlot, selectedItem.price) -- Move payment to bank
    moveItems(stock, public, slot, selectedItem.quantity)  -- Move item to public chest

    term.setBackgroundColor(bgColor)
    term.setTextColor(itemColor)
    term.clear()
    term.setCursorPos(1,1)
    print("Thank you for your purchase!")
    sleep(1)
end


-- Function to handle password protection and termination prevention
local function main()
    while true do
        displayShop()
        print("Enter the number of the item you want to purchase:")
        local choice = tonumber(read())

        if choice then
            processPurchase(choice)
        else
            term.setTextColor(errorColor)
            print("Invalid input. Please enter a valid number.")
            sleep(1)
        end

        term.setTextColor(textColor)
        print(os.clock())
    end
end

-- Function to handle termination attempts
local function protectedMain()
    while true do
        local ok, err = pcall(main) -- Protect the main loop
        if not ok then
            -- There was an error! The contents of the error are stored in "err"
            if err == "Terminated" then
                term.clear()
                term.setCursorPos(1, 1)
                print("Enter password to exit:")
                local password = read("*")

                if password == sudopsw then
                    for i = 1, 3, 1 do
                        term.clear()
                        term.setCursorPos(1, 1)
                        print("Exiting.")
                        sleep(.2)
                        term.clear()
                        term.setCursorPos(1, 1)
                        print("Exiting..")
                        sleep(.2)
                        term.clear()
                        term.setCursorPos(1, 1)
                        print("Exiting...")
                        sleep(.2)
                    end
                    term.clear()
                    term.setCursorPos(1, 1)
                    break
                else
                    printError("Incorrect password. Returning to shop.")
                    sleep(2)
                end
            else
                printError("An unexpected error occurred: " .. err)
                sleep(2)
            end
        end
    end
end

protectedMain()
