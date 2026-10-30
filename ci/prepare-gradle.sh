#!/usr/bin/env bash
set -euo pipefail

# Normalize the root settings file before Gradle configures Fabric Loom.
# Deliberately omit dependencyResolutionManagement.repositoriesMode so Loom
# can add its LoomLocalRemappedMods project repository.
cat > settings.gradle <<'GRADLE'
pluginManagement {
    repositories {
        maven { url = 'https://maven.fabricmc.net/' }
        gradlePluginPortal()
        mavenCentral()
    }
}

rootProject.name = 'aegis-client'
GRADLE

if grep -Eq 'RepositoriesMode\.(PREFER_SETTINGS|FAIL_ON_PROJECT_REPOS)' settings.gradle; then
    echo 'ERROR: incompatible Gradle repository mode remains in settings.gradle.' >&2
    exit 1
fi

echo 'Active settings.gradle:'
cat settings.gradle
