// Logging Utils

reset = "\u001B[0m"
red = "\u001B[31m"
blue = "\u001B[34m"
green = "\u001B[32m"
purple = "\u001B[35m"
yellow = "\u001B[33m"
cyan = "\u001B[36m"

def logWithColor(message, color) {
    log.info "${color}${message}${reset}"
}
def logSuccess(message) {
    logWithColor(message, green)
}
def logWarning(message) {
    logWithColor(message, yellow)
}
def logError(message) {
    logWithColor(message, red)
}
def logInfo(message) {
    logWithColor(message, cyan)
}
def coloredTitle(sep = "") {
    return [
        "\uD83E\uDDEC ", // dna emoji
        "${blue}P${reset}",
        "${blue}R${reset}",
        "${blue}O${reset}",
        "${blue}T${reset}",
        "${blue}E${reset}",
        "${blue}I${reset}",
        "${blue}N${reset}",
        "${purple}A${reset}",
        "${purple}C${reset}",
        "${purple}T${reset}",
        "${purple}I${reset}",
        "${purple}V${reset}",
        "${purple}I${reset}",
        "${purple}T${reset}",
        "${purple}Y${reset}",
    ].join(sep)
}

// File Utils

def getAbsolute(path) {
    return new File(path).absolutePath
}

def mkdirs(path) {
    path = new File(new File(path).absolutePath)
    if (!path.exists()) {
        path.mkdirs()
    }
}