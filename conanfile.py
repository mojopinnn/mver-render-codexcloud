from conan import ConanFile


class MverConan(ConanFile):
    name = "mver"
    version = "0.1.0"

    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    requires = "qt/6.8.3"
    default_options = {
        "qt/*:shared": True,
    }
