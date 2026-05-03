allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = project.file("../build")
subprojects {
    project.buildDir = project.file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
