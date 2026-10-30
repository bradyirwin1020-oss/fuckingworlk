# Aegis Minecraft 26.1.2 compile error fix

This patch fixes the Minecraft 26.1.2 client-API errors reported by GitHub Actions after Gradle successfully configured the Fabric Loom project.

## Changes

- Replaced `ClickType` / `handleInventoryMouseClick` with `ContainerInput` / `handleContainerInput`.
- Updated the Aegis screen click handler to `mouseClicked(MouseButtonEvent, boolean)` and use the event's `x()`, `y()`, and `button()` accessors.
- Replaced the removed `InputConstants.KEY_RIGHT_SHIFT` constant with `GLFW.GLFW_KEY_RIGHT_SHIFT`.
- Replaced `LocalPlayer.displayClientMessage(..., true)` with the 26.1 GUI overlay message API.
- Replaced direct access to the now-private inventory `selected` field with `getSelectedSlot()` and `setSelectedSlot(int)`.
- Removed the obsolete `net.minecraft.client.Mouse` mixin. CPS now counts physical mouse press transitions by polling GLFW during client ticks, and ignores clicks while a Minecraft screen is open.
- Removed the unused mixin config reference from `fabric.mod.json`.
- Synced the same source and Gradle files into the launcher's embedded project copy.

## Apply

Extract this patch into the root of the existing Aegis repository, preserving folder paths. Do not replace the working `.github/workflows/build.yml`.

Then commit and push the source changes. GitHub Actions should run the existing build workflow.

## Verification status

The patch was checked for stale references to the old API names, `fabric.mod.json` was parsed as JSON, and the existing workflow was confirmed to remain unchanged. A full Minecraft 26.1.2 Gradle compilation was not run in this environment because it only has Java 21; the project requires Java 25. The next GitHub Actions run is required to confirm compiler success.
