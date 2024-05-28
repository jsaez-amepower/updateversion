#!/bin/bash

# Function to parse parameters and update version numbers accordingly
parse_parameters() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
			--help|-help|-h|--h)
cat <<- 'EOF'
Overview
The updateversion.sh script is a bash script designed to update a version file in your project with version information retrieved from Git. 
Additionally, it allows you to tag your Git repository based on the version information in the version file -> [filename].[fileextension].

Prerequisites

    Git installed on your system.
    Basic knowledge of working with Git repositories and bash scripting.

Steps

    Download the Script: Download the updateversion.sh script and place it in your project directory.

    Make the Script Executable: Ensure that the script has executable permissions. If not, you can set the permissions using the chmod command:

    $ chmod +x updateversion.sh

Run the script without any parameters to see the version major, minor, patch, and commit number.
	$ ./updateversion.sh

Update [filename].[fileextension]: Run the script with file parameters to update the version file in your project directory with version information retrieved from Git:

	$ ./updateversion.sh -f filename.fileextension

Optional: Increment Major Version: To increment the major version number by 1 and reset the minor and patch versions to 0, you can use the --major +1 option:

	$ ./updateversion.sh -f filename.fileextension --major +1

Optional: Set Major Version: To set the major version number to a specific value and reset the minor and patch versions to 0, you can use the --major new_major_number option:

	$ ./updateversion.sh -f filename.fileextension --major 2

Optional: Increment Minor Version: To increment the minor version number by 1 and reset the patch version to 0, you can use the --minor +1 option:

	$ ./updateversion.sh -f filename.fileextension --minor +1

Optional: Set Minor Version: To set the minor version number to a specific value and reset the patch version to 0, you can use the --minor new_minor_number option:

	$ ./updateversion.sh -f filename.fileextension --minor 5

Optional: Tag the Repository: To tag your Git repository based on the version information in the version file, use the --tag option:

	$ ./updateversion.sh --tag


Optional: Tag the Repository and upload the tag: To tag your Git repository based on the version information in the version file, use the --tag option:

	$ ./updateversion.sh --tag 1



Verify Changes: After running the script with the desired options, verify that the version file has been updated correctly and that the Git repository has been tagged accordingly.
EOF
				exit 0
				;;
            --major)
                if [[ "$2" == +* ]]; then
                    VERSION_MAJOR=$((VERSION_MAJOR + ${2:1}))
                    VERSION_MINOR=0
                    VERSION_PATCH=0
                elif [[ "$2" =~ ^[0-9]+$ ]]; then
                    VERSION_MAJOR=$2
                    VERSION_MINOR=0
                    VERSION_PATCH=0
                else
                    echo "Error: Invalid argument for --major. Please provide a positive integer or a relative value." >&2
                    exit 1
                fi
                shift 2
                ;;
            --minor)
                if [[ "$2" == +* ]]; then
                    VERSION_MINOR=$((VERSION_MINOR + ${2:1}))
                    VERSION_PATCH=0
                elif [[ "$2" =~ ^[0-9]+$ ]]; then
                    VERSION_MINOR=$2
                    VERSION_PATCH=0
                else
                    echo "Error: Invalid argument for --minor. Please provide a positive integer or a relative value." >&2
                    exit 1
                fi
                shift 2
                ;;
			--build)
                if [[ "$2" == +* ]]; then
                    BUILD_INCREMENT=${2:1}
                else
                    echo "Error: Invalid argument for --build. Please provide a positive integer +X" >&2
                    exit 1
                fi
                shift 2
                ;;
            --tag|-t|--t)
				if [[ "$2" == 1 ]]; then
                    PUSHTAG=true
					shift
                fi
                TAG=true
                shift
                ;;
			--file|-f|--f)
				if [ -z "$2" ]; then
					echo "Error: No filename provided" >&2
					exit 1
				else
					FILENAME="$2"
					shift 
                fi
                shift
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                exit 1
                ;;
        esac
    done
}

# Get the branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Get the commit ID (first 8 characters)
COMMIT_ID=$(git rev-parse HEAD)
COMMIT_ID_SHORT=$(git rev-parse --short=10 HEAD)
# Get the latest tag name and count commits since last tag
VERSION_TAG=$(git describe --tags --abbrev=0)
COMMITS_SINCE_TAG=$(git rev-list ${VERSION_TAG}..HEAD --count)

# Parse the tag to extract version numbers. Assuming the tag is in the format vMAJOR.MINOR
# For example, v0.2
IFS='.' read -ra VERSION_PARTS <<< "${VERSION_TAG#v}"
VERSION_MAJOR=${VERSION_PARTS[0]}
VERSION_MINOR=${VERSION_PARTS[1]}

# The patch version is based on the number of commits since the last tag update
VERSION_PATCH=${COMMITS_SINCE_TAG}

# Parse parameters if any
parse_parameters "$@"

# Output the version and commit information
echo "VERSION_MAJOR: $VERSION_MAJOR"
echo "VERSION_MINOR: $VERSION_MINOR"
echo "VERSION_PATCH: $VERSION_PATCH"
echo "Commit: $COMMIT_ID"

if [ -n "$FILENAME" ]
then

	# Extract the file extension
	EXTENSION="${FILENAME##*.}"

	# Using a case statement to determine the file extension
	case "$EXTENSION" in
		h)
			# Extract the patch number using grep and awk
			VERSION_PATCH_FILE=$(grep '^#define VERSION_PATCH' "../$FILENAME" | awk '{print $3}' | grep -o '[0-9]*')
			# Print the build number
			BUILD_RESET=0
			if [ -n "$VERSION_PATCH_FILE" ]; then
				if [ "$VERSION_PATCH" != "$VERSION_PATCH_FILE" ]; then
					BUILD_RESET=1
				fi
			fi

			# Extract the build number using grep and awk
			VERSION_BUILD=$(grep '^#define VERSION_BUILD' "../$FILENAME" | awk '{print $3}' | grep -o '[0-9]*')
			# Print the build number
			if [ "$BUILD_RESET" -eq 1 ]; then
				echo "build reset to 0"
				VERSION_BUILD=0
			elif [ -z "$VERSION_BUILD" ]; then
				VERSION_BUILD=0
			elif [ -n "$BUILD_INCREMENT" ]; then
				VERSION_BUILD=$(($VERSION_BUILD + $BUILD_INCREMENT))
			fi
			
			cat > $FILENAME <<EOF
#define VERSION_MAJOR      ${VERSION_MAJOR} //based on git tag
#define VERSION_MINOR      ${VERSION_MINOR} //based on git tag
#define VERSION_PATCH      ${VERSION_PATCH} //based on the number of commits since the git tag was updated
#define VERSION_BUILD      ${VERSION_BUILD} //based on the number of builds since a commit was made

#define VERSION_BRANCH     "${BRANCH_NAME}"
#define VERSION_COMMIT     0x${COMMIT_ID}
#define VERSION_COMMIT_SHORT     0x${COMMIT_ID_SHORT}
#define VERSION_COMMIT_STR     "${COMMIT_ID}"

#define VERSION_STRING "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
EOF
			# Copy version.h to the parent directory
			cp $FILENAME ../$FILENAME 2>/dev/null
		;;
		v)			
		
			# Extract the patch number using grep and awk
			VERSION_PATCH_FILE=$(grep '// Patch:' $FILENAME | awk '{print $3}' | grep -o '[0-9]*')
			# Print the build number
			BUILD_RESET=0
			if [ -n "$VERSION_PATCH_FILE" ]; then
				if [ "$VERSION_PATCH" != "$VERSION_PATCH_FILE" ]; then
					BUILD_RESET=1
				fi
			fi
			
			# Extract the patch number using grep and awk
			VERSION_BUILD=$(grep '// Build:' $FILENAME | awk '{print $3}' | grep -o '[0-9]*')
			# Print the build number
			if [ "$BUILD_RESET" -eq 1 ]; then
				echo "build reset to 0"
				VERSION_BUILD=0
			elif [ -z "$VERSION_BUILD" ]; then
				VERSION_BUILD=0
			elif [ -n "$BUILD_INCREMENT" ]; then
				VERSION_BUILD=$(($VERSION_BUILD + $BUILD_INCREMENT))
			fi
		
			# Concatenate version numbers into a 24-bit value
			VERSION_OUT=$((VERSION_MAJOR << 20 | VERSION_MINOR << 14 | VERSION_PATCH << 8 | VERSION_BUILD))
			VERSION_OUT=$(printf '%x\n' $VERSION_OUT)
			# Create Verilog file
			cat > $FILENAME <<EOF
module version (
	output wire [23:0] version_out,
	output wire [39:0] commit_out,
	output wire [31:0] version_upper32,
	output wire [31:0] version_lower32
);

// v$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH
// Major: $VERSION_MAJOR
// Minor: $VERSION_MINOR
// Patch: $VERSION_PATCH
// Build: $VERSION_BUILD
// Branch: $BRANCH_NAME

// version_out = (VERSION_MAJOR << 20 | VERSION_MINOR << 14 | VERSION_PATCH << 8 | VERSION_BUILD)
localparam [23:0] CONST_VERSION_OUT = 24'h$VERSION_OUT;
localparam [39:0] CONST_COMMIT_OUT = 40'h$COMMIT_ID_SHORT;

// Continuous assignments for wire outputs
assign version_out = CONST_VERSION_OUT;
assign commit_out = CONST_COMMIT_OUT;

// Make version_upper32 to be: lower 8 bits from commit_out and version_out
assign version_upper32 = {CONST_VERSION_OUT[23:0], CONST_COMMIT_OUT[39:32]};

// version_lower32: upper 32 bits of commit_out
assign version_lower32 = CONST_COMMIT_OUT[31:0];

endmodule
EOF
		;;
		*)
			echo "Unknown file extension: .$EXTENSION"
			# Handle any unknown file extensions here
		;;
	esac
	
fi
echo "VERSION_BUILD: $VERSION_BUILD"


# Tag the repository if --tag option is specified
if [[ $TAG == true ]]; then

    # Construct tag name
    TAG_NAME="v$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

    # Tag the repository
    git tag -a "$TAG_NAME" -m "Version $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"
    echo "Repository tagged with $TAG_NAME"
	
	if [[ $PUSHTAG == true ]]; then
		git push origin "$TAG_NAME"
	fi
fi
