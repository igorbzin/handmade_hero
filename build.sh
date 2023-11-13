#build.sh
#The build system for Handmade Hero
#

MAC_OS_LD_FLAGS="-framework AppKit"

# Define the output executable name
output_executable="handmade"

echo "Beginning build process.."
mkdir build
pushd build
#
# Find all .swift files and compile them into a single executable
find . -name "*.swift" -print0 | xargs -0 swiftc -o "$output_executable"

# Check if the compilation was successful
if [ -f "$output_executable" ]; then
	echo "Compilation successful. The executable is named '$output_executable'."
else
	echo "Compilation failed."
fi
popd
