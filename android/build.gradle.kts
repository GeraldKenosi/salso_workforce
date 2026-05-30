import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    buildDir = file("${rootProject.projectDir.parentFile}/build/${project.name}")
}

subprojects {

    // --- AGP 8+ requires each Android module to have a namespace.
    // Some Flutter plugins may not declare it, so we add a safe fallback.
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                val current = getNamespace.invoke(androidExt) as String?

                if (current.isNullOrBlank()) {
                    setNamespace.invoke(androidExt, project.group.toString())
                }
            } catch (_: Throwable) {
                // Ignore if this Android extension doesn't expose namespace in this AGP version.
            }

            // Force Android compileOptions Java version to 17 (via reflection).
            try {
                val getCompileOptions = androidExt.javaClass.getMethod("getCompileOptions")
                val compileOptions = getCompileOptions.invoke(androidExt)

                val javaVersionClass = Class.forName("org.gradle.api.JavaVersion")
                val java17 = javaVersionClass.getField("VERSION_17").get(null)

                val setSource = compileOptions.javaClass.getMethod("setSourceCompatibility", javaVersionClass)
                val setTarget = compileOptions.javaClass.getMethod("setTargetCompatibility", javaVersionClass)

                setSource.invoke(compileOptions, java17)
                setTarget.invoke(compileOptions, java17)
            } catch (_: Throwable) {
                // Ignore if compileOptions reflection fails for any module.
            }
        }
    }

    // Force Kotlin JVM target to 17 using compilerOptions (no kotlinOptions).
    tasks.withType(KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    // Force Java compile target/source to 17 without using --release
    // (AGP warns that --release breaks Android bootclasspath setup). [1](https://salsoza-my.sharepoint.com/personal/gerald_salsoza_onmicrosoft_com/Documents/Microsoft%20Copilot%20Chat%20Files/user_service.dart)
    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}