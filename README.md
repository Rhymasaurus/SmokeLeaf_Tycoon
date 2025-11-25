# SmokeLeaf Tycoon

This repo contains drop-in scripts for a Roblox tycoon experience. The package adds:

- A **cash system** with leaderstats, automatic income, and remote notifications for the HUD.
- A **gamepass shop GUI** that lists configured gamepasses and prompts purchases.
- **Ground purchase buttons** (tagged with `TycoonButton`) that players can buy using in-game currency.

## File layout

```
src/
├── ReplicatedStorage
│   ├── Constants.lua                -- Shared names and defaults used across scripts.
│   └── ShopConfig.lua               -- Gamepass catalog shown in the shop UI.
├── ServerScriptService
│   ├── GamepassService.lua          -- Handles prompting purchases from the shop.
│   ├── MoneyService.lua             -- Leaderstats, income loop, and purchase validation.
│   ├── TycoonRemotes.server.lua     -- Creates RemoteEvents/Functions under ReplicatedStorage.
│   └── TycoonServer.server.lua      -- Bootstraps services and validates button purchases.
├── StarterGui
│   └── TycoonHud.client.lua         -- Client HUD for cash + gamepass shop list.
└── StarterPlayer
    └── StarterPlayerScripts
        └── ButtonInteractor.client.lua -- Adds proximity prompts to ground buttons.
```

## How to use

1. Drop the contents of `src` into the matching Roblox services in Studio (e.g., the files inside `ServerScriptService` should be placed there).
2. Tag any purchasable part with `CollectionService` tag `TycoonButton` and add a `Configuration` folder with:
   - **Cost** (`NumberValue`): price in cash.
   - **Prefab** (`ObjectValue`, optional): points to a model in `ServerStorage` that will be cloned into the Workspace when bought.
3. Populate `ShopConfig.lua` with your real gamepass IDs and optional icons. The HUD will list them automatically.
4. Run the experience. Players receive starter cash and periodic income, see their balance in the HUD, can open proximity prompts on tagged ground buttons, and can buy gamepasses from the shop list.

## Notes

- Remote names and other shared values live in `Constants.lua` to avoid mismatches between client and server.
- The UI is created entirely via script, so no pre-built ScreenGuis are required.
