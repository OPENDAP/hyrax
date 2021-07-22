
# CMakeLists.txt file for use with CLion's code discovery, etc., modes.
# Use the autotools configure, Makefiles, etc., for building the code.
# jhrg 12/5/19

cmake_minimum_required(VERSION 3.15)

project(hyrax_git)

# Edited. set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD 11)

include_directories(/usr/local/include)
include_directories(/usr/local/include/c++)

if (EXISTS /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/)
	include_directories(/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/)
endif()

# Added.
if (EXISTS /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk)
	# this is needed on OSX Bug Sur to find libSystem
	link_directories(/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib)
	include_directories(/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/libxml2)
	include_directories(/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/curl)
endif()

# Added for the sql handler and its use of unixODBC
if (EXISTS /usr/local/Cellar/openssl/1.0.2r)
	include_directories(/usr/local/Cellar/openssl/1.0.2r/include/)
endif()

# The Hyrax dependencies directories
include_directories(build/deps/include)

include_directories(build/deps/include/gridfields)
include_directories(build/deps/include/openjpeg-2.1)
include_directories(build/deps/include/unicode)

# More stuff for the sql handler, which is not formally part of the bes. jhrg 7/22/21
if (EXISTS build/include/sql)
	include_directories(build/include/sql)
	include_directories(build/include/sql/action)
	include_directories(build/include/sql/connector)
	include_directories(build/include/sql/container)
	include_directories(build/include/sql/DEM)
	include_directories(build/include/sql/DTM)
	include_directories(build/include/sql/handler)
	include_directories(build/include/sql/handler/connector)
	include_directories(build/include/sql/utils)
endif()

add_subdirectory(libdap4)
add_subdirectory(bes)

# Add STAREmaster in until it's moved into the hyrax-dependencies or elsewhere. jhrg 7/22/21
if (EXISTS STAREmaster)
	add_subdirectory(STAREmaster)
endif()

include_directories(bes)
include_directories(libdap4)

